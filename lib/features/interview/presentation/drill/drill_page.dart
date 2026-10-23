import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/failure_text.dart';
import '../../../../app/providers.dart';
import '../../../../core/contracts/contracts.dart';
import '../../../../core/design/glass.dart';
import '../../../../core/design/theme.dart';
import '../../../../core/design/tokens.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/drift_session_repository.dart';
import '../../domain/factcheck/claim_verifier.dart';
import '../../domain/selection/question_selector.dart';
import '../feedback/scoring_card.dart';

/// 练习模式（T-030）：一题一屏、先落盘后评分、单题评分卡。
class DrillPage extends ConsumerStatefulWidget {
  const DrillPage({super.key, this.questionId});

  final String? questionId;

  @override
  ConsumerState<DrillPage> createState() => _DrillPageState();
}

class _DrillPageState extends ConsumerState<DrillPage> {
  final TextEditingController _answer = TextEditingController();
  final QuestionSelector _selector = QuestionSelector();
  final Set<String> _askedIds = <String>{};
  final SessionConfig _config = const SessionConfig(
    mode: SessionMode.drill,
    role: 'backend',
    level: 'mid',
  );
  Timer? _ticker;

  Session? _session;
  Question? _question;
  TurnScore? _score;
  String? _turnId;
  String? _submittedText;
  DateTime _startedAt = DateTime.now();
  Duration _elapsed = Duration.zero;
  bool _busy = false;
  bool _scoringFailed = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _busy) return;
      setState(() => _elapsed = DateTime.now().difference(_startedAt));
    });
    unawaited(_loadQuestion(initialId: widget.questionId));
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _answer.dispose();
    super.dispose();
  }

  Future<void> _loadQuestion({String? initialId}) async {
    setState(() {
      _busy = true;
      _loadError = null;
    });
    try {
      final repo = ref.read(bankRepositoryProvider);
      final candidates = await repo.search(const QuestionQuery(limit: 100));
      final recent = await ref
          .read(sessionRepositoryImplProvider)
          .recentQuestionIds();
      Question? question;
      if (initialId != null) {
        question = await repo.byId(initialId);
      } else {
        question = _selector
            .select(
              candidates,
              QuestionSelectionContext(
                config: _config,
                askedIds: _askedIds,
                recentIds: recent.toSet(),
                lastScore: _score?.total,
                questionIndex: _askedIds.length,
              ),
            )
            ?.question;
      }
      if (question == null) {
        setState(() {
          _loadError = AppLocalizations.of(context).drillNoQuestion;
          _busy = false;
        });
        return;
      }
      _session ??= await ref.read(sessionRepositoryProvider).create(_config);
      if (!mounted) return;
      setState(() {
        _question = question;
        _score = null;
        _turnId = null;
        _submittedText = null;
        _scoringFailed = false;
        _answer.clear();
        _startedAt = DateTime.now();
        _elapsed = Duration.zero;
        _busy = false;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = '$error';
        _busy = false;
      });
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final question = _question;
    if (question == null) {
      _toast(l10n.drillNeedQuestion);
      return;
    }
    final text = _answer.text.trim();
    if (text.isEmpty) {
      _toast(l10n.drillAnswerEmpty);
      return;
    }
    final session = _session;
    if (session == null) return;
    setState(() {
      _busy = true;
      _scoringFailed = false;
    });
    try {
      final turn = await ref
          .read(sessionRepositoryProvider)
          .appendAnswer(
            session.id,
            AnswerInput(
              questionId: question.id,
              questionText: question.title,
              text: text,
              tStartedAt: _startedAt,
            ),
          );
      _turnId = turn.id;
      _submittedText = text;
      _askedIds.add(question.id);
      await _runScoring(turn.id, question, text);
    } on Failure catch (failure) {
      if (mounted) setState(() => _scoringFailed = true);
      if (mounted) showFailure(context, failure);
    } on Object catch (error) {
      if (mounted) {
        setState(() => _scoringFailed = true);
        _toast('$error');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _retryScoring() async {
    final question = _question;
    final turnId = _turnId;
    final text = _submittedText;
    if (question == null || turnId == null || text == null) return;
    setState(() {
      _busy = true;
      _scoringFailed = false;
    });
    try {
      await _runScoring(turnId, question, text);
    } on Failure catch (failure) {
      if (mounted) setState(() => _scoringFailed = true);
      if (mounted) showFailure(context, failure);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _runScoring(
    String turnId,
    Question question,
    String text,
  ) async {
    final engine = await ref.read(scoringEngineFactoryProvider)(
      _session?.id ?? '',
    );
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
    if (!mounted) return;
    setState(() {
      _score = score;
      _scoringFailed = false;
    });
  }

  Future<void> _finish() async {
    final session = _session;
    if (session != null) {
      try {
        await ref.read(sessionRepositoryProvider).finish(session.id);
        ref.invalidate(recentSessionsProvider);
      } on Failure {
        // 结束失败不阻塞离开。
      }
    }
    if (mounted) context.go('/');
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final question = _question;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.drillTitle),
        actions: <Widget>[
          TextButton(onPressed: _finish, child: Text(l10n.drillFinish)),
        ],
      ),
      body: AppBackdrop(
        child: question == null
            ? Center(
                child: _loadError == null
                    ? const CircularProgressIndicator()
                    : Padding(
                        padding: const EdgeInsets.all(MockSpace.s5),
                        child: GlassPanel(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(_loadError!, textAlign: TextAlign.center),
                              const SizedBox(height: MockSpace.s3),
                              GlassButton(
                                label: l10n.bankRetry,
                                icon: Icons.refresh,
                                onPressed: _loadQuestion,
                              ),
                            ],
                          ),
                        ),
                      ),
              )
            : ListView(
                padding: const EdgeInsets.all(MockSpace.s5),
                children: <Widget>[
                  GlassPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          question.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: MockSpace.s2),
                        Text(
                          l10n.drillTimer(_formatDuration(_elapsed)),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                        if (question.bodyMarkdown.trim().isNotEmpty &&
                            question.bodyMarkdown.trim() !=
                                question.title.trim()) ...<Widget>[
                          const SizedBox(height: MockSpace.s3),
                          SelectableText(question.bodyMarkdown),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: MockSpace.s4),
                  if (_score == null) ...<Widget>[
                    GlassPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          TextField(
                            controller: _answer,
                            minLines: 6,
                            maxLines: 14,
                            enabled: !_busy,
                            decoration: InputDecoration(
                              hintText: l10n.drillAnswerHint,
                            ),
                          ),
                          const SizedBox(height: MockSpace.s3),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  _busy ? l10n.drillScoring : '',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.hintColor,
                                  ),
                                ),
                              ),
                              GlassButton(
                                label: _busy
                                    ? l10n.drillScoring
                                    : l10n.drillSubmit,
                                icon: Icons.send_outlined,
                                busy: _busy,
                                onPressed: _busy ? null : _submit,
                              ),
                            ],
                          ),
                          if (_busy) ...<Widget>[
                            const SizedBox(height: MockSpace.s2),
                            const LinearProgressIndicator(minHeight: 2),
                          ],
                          if (_scoringFailed) ...<Widget>[
                            const SizedBox(height: MockSpace.s2),
                            Text(
                              l10n.drillScoringFailed,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                            const SizedBox(height: MockSpace.s2),
                            Align(
                              alignment: Alignment.centerRight,
                              child: GlassButton(
                                label: l10n.drillRetryScoring,
                                primary: false,
                                icon: Icons.refresh,
                                onPressed: _retryScoring,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ] else ...<Widget>[
                    ScoringCard(score: _score!, onAppeal: _appeal),
                    const SizedBox(height: MockSpace.s4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        GlassButton(
                          label: l10n.drillNext,
                          icon: Icons.arrow_forward,
                          onPressed: _loadQuestion,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  Future<void> _appeal(String point) async {
    final l10n = AppLocalizations.of(context);
    final note = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => _AppealDialog(
        hint: l10n.drillAppealHint,
        cancelLabel: l10n.commonCancel,
        submitLabel: l10n.drillSubmit,
        title: l10n.drillAppealTitle,
      ),
    );
    if (note == null || note.isEmpty || _turnId == null) return;
    await ref
        .read(sessionRepositoryImplProvider)
        .saveAppeal(_turnId!, point: point, userNote: note);
    if (mounted) _toast(l10n.drillAppealSaved);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _AppealDialog extends StatefulWidget {
  const _AppealDialog({
    required this.title,
    required this.hint,
    required this.cancelLabel,
    required this.submitLabel,
  });

  final String title;
  final String hint;
  final String cancelLabel;
  final String submitLabel;

  @override
  State<_AppealDialog> createState() => _AppealDialogState();
}

class _AppealDialogState extends State<_AppealDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        minLines: 2,
        maxLines: 5,
        decoration: InputDecoration(hintText: widget.hint),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.cancelLabel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: Text(widget.submitLabel),
        ),
      ],
    );
  }
}
