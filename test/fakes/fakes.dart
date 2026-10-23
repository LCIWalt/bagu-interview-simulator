import 'dart:async';
import 'dart:typed_data';

import 'package:mockmate/core/contracts/contracts.dart';

/// 可编排的 LLM fake：按脚本逐条回放，CI 不依赖真实网络。
class FakeLlmClient implements LlmClient {
  FakeLlmClient({List<FakeLlmTurn>? script})
    : _script = script ?? <FakeLlmTurn>[];

  final List<FakeLlmTurn> _script;
  final List<ChatRequest> requests = <ChatRequest>[];
  int _cursor = 0;

  @override
  String get id => 'fake-llm';

  void enqueue(FakeLlmTurn turn) => _script.add(turn);

  @override
  Stream<LlmDelta> chat(ChatRequest req, {CancelToken? cancel}) async* {
    requests.add(req);
    if (_cursor >= _script.length) {
      throw const ParseFailure('fake script exhausted');
    }
    final turn = _script[_cursor++];
    if (turn.error != null) throw turn.error!;
    if (turn.delay != null) await Future<void>.delayed(turn.delay!);
    for (final piece in turn.textChunks) {
      cancel?.throwIfCancelled();
      yield LlmTextDelta(piece);
    }
    for (final call in turn.toolCalls) {
      cancel?.throwIfCancelled();
      yield LlmToolCallDelta(call);
    }
    if (turn.usage != null) yield LlmUsageDelta(turn.usage!);
    yield LlmDoneDelta(finishReason: turn.finishReason);
  }
}

class FakeLlmTurn {
  FakeLlmTurn({
    this.textChunks = const <String>[],
    this.toolCalls = const <ToolCall>[],
    this.usage,
    this.finishReason = 'stop',
    this.error,
    this.delay,
  });

  final List<String> textChunks;
  final List<ToolCall> toolCalls;
  final LlmUsage? usage;
  final String finishReason;
  final Failure? error;
  final Duration? delay;
}

class FakeSttProvider implements SttProvider {
  const FakeSttProvider({this.available = true});

  final bool available;

  @override
  String get id => 'fake-stt';

  @override
  bool get capturesAudio => false;

  @override
  Future<bool> isAvailable() async => available;
}

class FakeTtsProvider implements TtsProvider {
  FakeTtsProvider({this.fail = false});

  final bool fail;
  final List<String> spoken = <String>[];

  @override
  String get id => 'fake-tts';

  @override
  Future<TtsVoiceList> voices() async =>
      const TtsVoiceList(<TtsVoice>[TtsVoice(id: 'fake', name: 'Fake Voice')]);

  @override
  Stream<AudioChunk> synthesize(
    String text,
    TtsConfig cfg, {
    CancelToken? cancel,
  }) async* {
    if (fail) throw const NetworkFailure('tts unavailable');
    spoken.add(text);
    yield AudioChunk(bytes: Uint8List.fromList(const <int>[1, 2, 3]));
    yield AudioChunk(bytes: Uint8List(0), isLast: true);
  }
}

class FakeSearchProvider implements SearchProvider {
  FakeSearchProvider({List<SearchHit>? hits, this.page})
    : hits = hits ?? <SearchHit>[];

  final List<SearchHit> hits;
  final ExtractedPage? page;

  @override
  String get id => 'fake-search';

  @override
  Future<List<SearchHit>> search(SearchQuery q) async => hits;

  @override
  Future<ExtractedPage> fetch(String url) async {
    final p = page;
    if (p == null) throw const NetworkFailure('no page');
    return p;
  }
}

class FakeEmbeddingProvider implements EmbeddingProvider {
  FakeEmbeddingProvider({this.dim = 8, this.available = true});

  final int dim;
  final bool available;

  @override
  String get id => 'fake-embedding';

  @override
  String get model => 'fake-bge-$dim';

  @override
  int get dimensions => dim;

  @override
  bool get isAvailable => available;

  @override
  Future<List<double>> embed(String text) async =>
      List<double>.filled(dim, 0.1);

  @override
  Future<List<List<double>>> embedBatch(List<String> texts) async =>
      texts.map((_) => List<double>.filled(dim, 0.1)).toList(growable: false);
}

class FakeBankRepository implements BankRepository {
  FakeBankRepository({List<Question>? questions, this.manifest})
    : questions = questions ?? <Question>[];

  final List<Question> questions;
  final BankManifest? manifest;
  final List<BankChannel> updateCalls = <BankChannel>[];

  @override
  Future<BankManifest?> installed() async => manifest;

  @override
  Stream<BankUpdateProgress> update({
    required BankChannel channel,
    bool force = false,
  }) async* {
    updateCalls.add(channel);
    final m = manifest;
    if (m == null) {
      yield const BankUpdateFailed(
        NetworkFailure('no manifest'),
        rolledBack: false,
      );
      return;
    }
    yield const BankDownloading(receivedBytes: 5, totalBytes: 10);
    yield const BankVerifying('sha256');
    yield BankActivated(m);
  }

  @override
  Future<List<Question>> search(QuestionQuery q) async => questions;

  @override
  Future<Question?> byId(String id) async {
    for (final q in questions) {
      if (q.id == id) return q;
    }
    return null;
  }
}

/// 显式成功的更新事件（契约里用 [BankUpdated]；这里提供别名避免 fake 误用）。
typedef BankActivated = BankUpdated;

class FakeSessionRepository implements SessionRepository {
  FakeSessionRepository({this.report});

  final SessionReport? report;
  final List<AnswerInput> answers = <AnswerInput>[];
  int _seq = 0;

  @override
  Future<Session> create(SessionConfig cfg) async => Session(
    id: 's-1',
    mode: cfg.mode,
    config: cfg,
    startedAt: DateTime.utc(2026),
    status: SessionStatus.active,
  );

  @override
  Future<Turn> appendAnswer(String sessionId, AnswerInput input) async {
    answers.add(input);
    _seq++;
    return Turn(
      id: 't-$_seq',
      sessionId: sessionId,
      seq: _seq,
      questionId: input.questionId,
      questionText: input.questionText,
      answerText: input.text,
      tStartedAt: input.tStartedAt,
      tSubmittedAt: input.tSubmittedAt ?? DateTime.utc(2026),
      createdAt: DateTime.utc(2026),
    );
  }

  @override
  Future<SessionReport> finish(String sessionId) async =>
      report ??
      SessionReport(
        sessionId: sessionId,
        headline: 'fake report',
        dimensions: const <String, double>{
          'correctness': 3,
          'depth': 3,
          'structure': 3,
        },
        turns: const <Turn>[],
        weakestTopics: const <String>[],
        sevenDayPlan: const <String>[],
        interviewerView: 'fake',
      );
}
