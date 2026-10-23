import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../app/providers.dart';
import '../../../../core/contracts/contracts.dart';
import '../../../../core/design/glass.dart';
import '../../../../core/design/theme.dart';
import '../../../../core/design/tokens.dart';
import '../../../../core/platform/tts/tts_service.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/drift_session_repository.dart';
import '../../data/mock_resume_store.dart';
import '../../domain/factcheck/claim_verifier.dart';
import '../../domain/selection/question_selector.dart';
import '../../domain/session_clock.dart';
import '../../domain/session_flow.dart';
import '../../domain/turn_score_codec.dart';
import 'interviewer_avatar.dart';

class _Bubble {
  _Bubble(this.role, this.text);

  final String role;
  String text;
}

/// 实战模式（T-041/T-042）：题库驱动、全程静默评分、墙钟计时。
class MockLivePage extends ConsumerStatefulWidget {
  const MockLivePage({required this.sessionId, super.key});

  final String sessionId;

  @override
  ConsumerState<MockLivePage> createState() => _MockLivePageState();
}

class _MockLivePageState extends ConsumerState<MockLivePage>
    with WidgetsBindingObserver {
  final TextEditingController _answer = TextEditingController();
  final QuestionSelector _selector = QuestionSelector();
  final List<_Bubble> _messages = <_Bubble>[];
  final List<Future<void>> _pending = <Future<void>>[];
  final Set<String> _askedIds = <String>{};

  Session? _session;
  SessionFlow? _flow;
  SessionClock? _clock;
  Question? _current;
  MockPhase _phase = MockPhase.warmup;
  Timer? _ticker;
  bool _loading = true;
  bool _busy = false;
  bool _streaming = false;
  bool _finished = false;
  String? _error;
  int _questionIndex = 0;
  double? _lastScore;
  late final String _memorySummary;
  TtsService? _tts;
  bool _speaking = false;
  bool _ttsMuted = false;
  CancelToken? _ttsCancel;
  late final MockResumeStore _resumeStore;
  String? _turnId;
  Timer? _draftTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_init());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    _draftTimer?.cancel();
    _ttsCancel?.cancel();
    unawaited(_tts?.stop());
    _answer.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      final repo = ref.read(sessionRepositoryImplProvider);
      final session = await repo.byId(widget.sessionId);
      if (session == null || session.status != SessionStatus.active) {
        setState(() {
          _loading = false;
          _error = AppLocalizations.of(context).mockSessionMissing;
        });
        return;
      }
      final config = session.config;
      final flow = SessionFlow.create(config);
      final clock = SessionClock(
        startedAt: session.startedAt,
        total: Duration(minutes: config.durationMinutes),
      );
      _memorySummary =
          await ref
              .read(sessionMemoryStoreProvider)
              .latestSummary(excludeSessionId: session.id) ??
          '';
      _resumeStore = MockResumeStore(ref.read(databaseProvider));
      try {
        _tts = await ref.read(ttsServiceProvider.future);
      } on Object {
        _tts = null;
      }

      final turns = await repo.turnsFor(session.id);
      for (final turn in turns) {
        _askedIds.add(turn.questionId ?? '');
        _messages.add(
          _Bubble(
            'interviewer',
            '${_questionPrefix(turn.seq)}${turn.questionText}',
          ),
        );
        _messages.add(_Bubble('user', turn.answerText));
        final score = TurnScoreCodec.decode(turn.scoreJson);
        if (score != null) _lastScore = score.total;
      }
      _questionIndex = turns.length;

      final resume = await _resumeStore.load(session.id);
      Question? question;
      var resumed = false;
      if (resume != null &&
          !turns.any(
            (t) => t.id == resume.turnId || t.questionId == resume.questionId,
          )) {
        question = await ref
            .read(bankRepositoryProvider)
            .byId(resume.questionId);
        if (question != null) {
          resumed = true;
          _turnId = resume.turnId;
          _questionIndex = resume.questionIndex;
          _answer.text = resume.answer;
          _current = question;
          _askedIds.add(question.id);
          _messages.add(
            _Bubble(
              'interviewer',
              '${_questionPrefix(resume.questionIndex)}${question.title}',
            ),
          );
        } else {
          await _resumeStore.clear(session.id);
        }
      }

      if (!resumed) {
        final candidates = await ref
            .read(bankRepositoryProvider)
            .search(QuestionQuery(role: config.role, limit: 100));
        final recent = await repo.recentQuestionIds();
        final selection = _selector.select(
          candidates,
          QuestionSelectionContext(
            config: config,
            askedIds: _askedIds,
            recentIds: recent.toSet(),
            lastScore: _lastScore,
            questionIndex: _questionIndex,
          ),
        );
        if (!mounted) return;
        if (selection == null) {
          setState(() {
            _loading = false;
            _error = AppLocalizations.of(context).mockNoQuestion;
          });
          return;
        }
        question = selection.question;
        _current = question;
        _questionIndex = turns.length + 1;
        _askedIds.add(question.id);
        _turnId = _newTurnId();
        _messages.add(_Bubble('system', _phaseLabel(clock.phase)));
        if (turns.isEmpty) {
          _messages.add(
            _Bubble(
              'interviewer',
              '${_questionPrefix(_questionIndex)}${question.title}',
            ),
          );
          await _saveResume('');
          unawaited(
            _speak('${_questionPrefix(_questionIndex)}${question.title}'),
          );
        } else {
          await _saveResume('');
          await _askNext(question);
        }
      }

      _session = session;
      _flow = flow;
      _clock = clock;
      _phase = clock.phase;
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
      setState(() => _loading = false);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '$error';
      });
    }
  }

  String _newTurnId() =>
      't_${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(1 << 31).toRadixString(36)}';

  Future<void> _saveResume(String answer) async {
    final question = _current;
    final session = _session;
    final turnId = _turnId;
    if (question == null || session == null || turnId == null) return;
    await _resumeStore.save(
      session.id,
      MockResumeState(
        questionId: question.id,
        questionIndex: _questionIndex,
        turnId: turnId,
        answer: answer,
      ),
    );
  }

  void _onAnswerChanged(String value) {
    _draftTimer?.cancel();
    _draftTimer = Timer(
      const Duration(milliseconds: 500),
      () => _saveResume(value),
    );
  }

  Future<List<Question>> _candidates() {
    final config = _session!.config;
    return ref
        .read(bankRepositoryProvider)
        .search(QuestionQuery(role: config.role, limit: 100));
  }

  void _tick() {
    if (!mounted || _finished) return;
    final clock = _clock!;
    final phase = clock.phase;
    if (phase != _phase) {
      _phase = phase;
      if (phase != MockPhase.completed) {
        _messages.add(_Bubble('system', _phaseLabel(phase)));
      }
    }
    if (clock.expired) {
      _messages.add(_Bubble('system', AppLocalizations.of(context).mockTimeUp));
      unawaited(_finish());
      return;
    }
    setState(() {});
  }

  Future<void> _submit() async {
    final text = _answer.text.trim();
    final question = _current;
    final session = _session;
    if (text.isEmpty || question == null || session == null || _busy) return;
    setState(() => _busy = true);
    try {
      final turn = await ref
          .read(sessionRepositoryProvider)
          .appendAnswer(
            session.id,
            AnswerInput(
              id: _turnId,
              questionId: question.id,
              questionText: question.title,
              text: text,
              tStartedAt: _clock!.startedAt.add(_clock!.elapsed),
            ),
          );
      _messages.add(_Bubble('user', text));
      _answer.clear();
      _draftTimer?.cancel();
      await _resumeStore.clear(session.id);
      _turnId = null;
      _flow!.submitAnswer();
      final future = _scoreTurn(turn.id, question, text);
      _pending.add(future);
      unawaited(future.whenComplete(() => _pending.remove(future)));
      final memoryFuture = _extractMemory(turn.id, turn.seq, question, text);
      _pending.add(memoryFuture);
      unawaited(memoryFuture.whenComplete(() => _pending.remove(memoryFuture)));

      final candidates = await _candidates();
      final selection = _selector.select(
        candidates,
        QuestionSelectionContext(
          config: session.config,
          askedIds: _askedIds,
          lastScore: _lastScore,
          questionIndex: _questionIndex,
        ),
      );
      if (!mounted) return;
      if (selection == null || _finished) {
        await _finish();
        return;
      }
      _askedIds.add(selection.question.id);
      _questionIndex++;
      _current = selection.question;
      _turnId = _newTurnId();
      await _saveResume('');
      await _askNext(selection.question);
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$error')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _askNext(Question question) async {
    final l10n = AppLocalizations.of(context);
    final config = _session!.config;
    final fallback = '${_questionPrefix(_questionIndex)}${question.title}';
    final bubble = _Bubble('interviewer', '');
    _messages.add(bubble);
    setState(() => _streaming = true);
    try {
      final agent = await ref.read(interviewerAgentFactoryProvider)(
        _session!.id,
      );
      final history = <ChatMessage>[
        for (final message in _messages)
          if (message.role == 'user')
            ChatMessage.user(message.text)
          else if (message.role == 'interviewer' && message.text.isNotEmpty)
            ChatMessage.assistant(message.text),
      ];
      bubble.text = l10n.mockInterviewerTyping;
      await for (final chunk in agent.respond(
        config: config,
        phase: _phaseLabelText(_phase),
        remainMinutes: _clock!.remainingMinutes,
        history: history,
        nextQuestionTitle: question.title,
        memorySummary: _memorySummary,
      )) {
        if (bubble.text == l10n.mockInterviewerTyping) {
          bubble.text = '';
        }
        bubble.text += chunk;
        if (mounted) setState(() {});
      }
      bubble.text = '${bubble.text.trim()}\n\n$fallback';
      await _speak(bubble.text);
    } on Object {
      bubble.text = fallback;
    } finally {
      if (mounted) {
        setState(() => _streaming = false);
      }
    }
  }

  Future<void> _extractMemory(
    String turnId,
    int turnSeq,
    Question question,
    String text,
  ) async {
    try {
      final extractor = await ref.read(memoryExtractorFactoryProvider)(
        _session!.id,
      );
      final extraction = await extractor.extract(
        config: _session!.config,
        turnText: 'Q: ${question.title}\nA: $text',
      );
      if (extraction == null) return;
      await ref
          .read(sessionMemoryStoreProvider)
          .merge(
            _session!.id,
            extraction,
            turnSeq: turnSeq,
            questionId: question.id,
          );
    } on Object {
      // 记忆抽取失败不影响面试。
    }
  }

  Future<void> _speak(String text) async {
    final tts = _tts;
    if (tts == null || _ttsMuted || text.trim().isEmpty || _finished) return;
    final cancel = CancelToken();
    _ttsCancel?.cancel();
    _ttsCancel = cancel;
    if (mounted) setState(() => _speaking = true);
    try {
      await tts.speak(text, cancel: cancel);
    } on Object {
      // TTS 失败降级为纯文本。
    } finally {
      if (mounted && identical(_ttsCancel, cancel)) {
        setState(() => _speaking = false);
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) return;
    unawaited(_tts?.stop());
    if (mounted) setState(() => _speaking = false);
  }

  Future<void> _scoreTurn(String turnId, Question question, String text) async {
    try {
      final engine = await ref.read(scoringEngineFactoryProvider)(_session!.id);
      var score = await engine.score(question: question, answerText: text);
      try {
        final factCheck = await ref.read(factCheckServiceProvider.future);
        if (factCheck != null) {
          final verdicts = await factCheck.checkAnswer(answerText: text);
          score = applyFactCheckPenalty(score, verdicts);
        }
      } on Object {
        // 联网核查失败不阻断评分。
      }
      await ref.read(sessionRepositoryImplProvider).saveScore(turnId, score);
      _lastScore = score.total;
    } on Object {
      // 实战模式中途不暴露评分失败；结束后报告会缺这几题。
    }
  }

  Future<void> _finish() async {
    if (_finished) return;
    _finished = true;
    _ticker?.cancel();
    await _tts?.stop();
    if (_pending.isNotEmpty) {
      await Future.wait(
        _pending,
      ).timeout(const Duration(seconds: 10), onTimeout: () => const <void>[]);
    }
    final session = _session;
    if (session != null) {
      try {
        await ref.read(sessionRepositoryProvider).finish(session.id);
        try {
          final support = await getApplicationSupportDirectory();
          await ref
              .read(sessionMemoryStoreProvider)
              .export(session.id, support);
        } on Object {
          // 导出失败不阻塞报告。
        }
        ref.invalidate(recentSessionsProvider);
        ref.invalidate(mockReportProvider);
      } on Object {
        // 报告页会再次尝试。
      }
    }
    if (mounted) context.pushReplacement('/mock/report/${widget.sessionId}');
  }

  Future<void> _confirmFinish() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(l10n.mockFinishEarly),
        content: Text(l10n.mockEarlyFinishHint),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.mockFinishEarly),
          ),
        ],
      ),
    );
    if (confirmed == true) await _finish();
  }

  String _questionPrefix(int index) =>
      AppLocalizations.of(context).mockQuestionPrefix('$index');

  String _phaseLabel(MockPhase phase) {
    final l10n = AppLocalizations.of(context);
    return l10n.mockNextPhase(_phaseLabelText(phase));
  }

  String _phaseLabelText(MockPhase phase) {
    final l10n = AppLocalizations.of(context);
    return switch (phase) {
      MockPhase.warmup => l10n.mockPhaseWarmup,
      MockPhase.selfIntro => l10n.mockPhaseSelfIntro,
      MockPhase.project => l10n.mockPhaseProject,
      MockPhase.knowledge => l10n.mockPhaseKnowledge,
      MockPhase.systemDesign => l10n.mockPhaseSystemDesign,
      MockPhase.closing => l10n.mockPhaseClosing,
      MockPhase.completed => l10n.mockPhaseClosing,
    };
  }

  InterviewerAvatarState _avatarState() {
    if (_speaking) return InterviewerAvatarState.speaking;
    if (_busy || _streaming) return InterviewerAvatarState.thinking;
    if (_answer.text.trim().isNotEmpty) return InterviewerAvatarState.listening;
    return InterviewerAvatarState.idle;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final clock = _clock;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListenableBuilder(
              listenable: _answer,
              builder: (BuildContext context, Widget? child) =>
                  InterviewerAvatar(
                    state: _avatarState(),
                    size: 36,
                    semanticLabel: l10n.mockAvatarLabel,
                  ),
            ),
            const SizedBox(width: MockSpace.s2),
            Flexible(child: Text(l10n.mockLiveTitle)),
          ],
        ),
        actions: <Widget>[
          if (_tts != null)
            IconButton(
              tooltip: _ttsMuted ? l10n.mockUnmuteTts : l10n.mockMuteTts,
              onPressed: () {
                setState(() => _ttsMuted = !_ttsMuted);
                if (_ttsMuted) unawaited(_tts?.stop());
              },
              icon: Icon(_ttsMuted ? Icons.volume_off : Icons.volume_up),
            ),
          if (clock != null)
            Padding(
              padding: const EdgeInsets.only(right: MockSpace.s2),
              child: Center(
                child: Text(
                  l10n.mockRemaining(_format(clock.remaining)),
                  style: theme.textTheme.labelMedium,
                ),
              ),
            ),
          TextButton(
            onPressed: _finished ? null : _confirmFinish,
            child: Text(l10n.mockFinishEarly),
          ),
        ],
      ),
      body: AppBackdrop(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(MockSpace.s5),
                  child: GlassPanel(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: MockSpace.s3),
                        GlassButton(
                          label: l10n.mockReportBackHome,
                          onPressed: () => context.go('/'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Column(
                children: <Widget>[
                  if (_clock != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        MockSpace.s5,
                        MockSpace.s2,
                        MockSpace.s5,
                        0,
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: LinearProgressIndicator(
                              value: _clock!.progress,
                            ),
                          ),
                          const SizedBox(width: MockSpace.s3),
                          Text(
                            _phaseLabelText(_phase),
                            style: theme.textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(MockSpace.s5),
                      itemCount: _messages.length,
                      itemBuilder: (BuildContext context, int index) =>
                          _MessageBubble(message: _messages[index]),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      MockSpace.s5,
                      MockSpace.s2,
                      MockSpace.s5,
                      MockSpace.s5,
                    ),
                    child: GlassPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          TextField(
                            controller: _answer,
                            minLines: 2,
                            maxLines: 6,
                            enabled:
                                !_busy &&
                                !_streaming &&
                                !_speaking &&
                                !_finished,
                            decoration: InputDecoration(
                              hintText: l10n.mockYourAnswer,
                            ),
                            onChanged: _onAnswerChanged,
                            onSubmitted: (_) => _submit(),
                          ),
                          const SizedBox(height: MockSpace.s2),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GlassButton(
                              label: l10n.mockSubmit,
                              icon: Icons.send_outlined,
                              busy: _busy,
                              onPressed: _busy || _streaming || _finished
                                  ? null
                                  : _submit,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  String _format(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final _Bubble message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isUser = message.role == 'user';
    if (message.role == 'system') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: MockSpace.s2),
        child: Center(
          child: Text(
            message.text,
            style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor),
          ),
        ),
      );
    }
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.only(bottom: MockSpace.s3),
          child: GlassPanel(
            padding: const EdgeInsets.all(MockSpace.s3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  isUser ? l10n.mockYou : l10n.mockInterviewer,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
                const SizedBox(height: MockSpace.s1),
                SelectableText(message.text),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
