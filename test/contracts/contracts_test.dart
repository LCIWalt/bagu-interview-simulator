import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/core/contracts/contracts.dart';

import '../fakes/fakes.dart';

void main() {
  test('every contract has a working fake', () async {
    final LlmClient llm = FakeLlmClient(
      script: <FakeLlmTurn>[
        FakeLlmTurn(textChunks: <String>['a', 'b']),
      ],
    );
    final deltas = await llm
        .chat(
          const ChatRequest(
            model: 'm',
            messages: <ChatMessage>[ChatMessage.user('u')],
          ),
        )
        .toList();
    expect(
      deltas.whereType<LlmTextDelta>().map((LlmTextDelta d) => d.text).join(),
      'ab',
    );

    final SttProvider stt = const FakeSttProvider();
    expect(stt.capturesAudio, isFalse);
    expect(await stt.isAvailable(), isTrue);

    final TtsProvider tts = FakeTtsProvider();
    final chunks = await tts
        .synthesize('hello', const TtsConfig(), cancel: CancelToken())
        .toList();
    expect(chunks.last.isLast, isTrue);

    final SearchProvider search = FakeSearchProvider(
      hits: const <SearchHit>[
        SearchHit(url: 'https://a.dev', title: 'A', snippet: 's'),
      ],
    );
    expect(await search.search(const SearchQuery(query: 'q')), hasLength(1));
    expect(wrapUntrusted('x'), contains('<untrusted source="web">'));

    final EmbeddingProvider embedding = FakeEmbeddingProvider();
    expect(embedding.isAvailable, isTrue);
    expect(await embedding.embed('x'), hasLength(embedding.dimensions));

    final question = Question(
      id: 'q1',
      bankVersion: '2026.10.1',
      title: 't',
      bodyMarkdown: 'b',
      topics: const <String>['go'],
      role: 'backend',
      level: 3,
      difficulty: 3,
      type: QuestionType.knowledge,
      answer: const QuestionAnswer(summary: 's', keyPoints: <String>['k']),
    );
    final BankRepository bank = FakeBankRepository(
      questions: <Question>[question],
      manifest: BankManifest(
        schemaVersion: 1,
        bankVersion: '2026.10.1',
        minAppVersion: '0.5.0',
        generatedAt: DateTime.utc(2026),
        gitCommit: 'abc',
        questionCount: 1,
        experienceCount: 0,
        files: const <BankFileEntry>[],
        assets: const <BankAsset>[],
        signature: 'ed25519:xx',
      ),
    );
    expect(await bank.byId('q1'), same(question));
    final progress = await bank.update(channel: BankChannel.stable).toList();
    expect(progress.whereType<BankUpdated>(), hasLength(1));
    expect(progress.whereType<BankDownloading>().single.fraction, 0.5);

    final SessionRepository sessions = FakeSessionRepository();
    final session = await sessions.create(
      const SessionConfig(
        mode: SessionMode.drill,
        role: 'backend',
        level: 'mid',
      ),
    );
    expect(session.mode, SessionMode.drill);
    final turn = await sessions.appendAnswer(
      session.id,
      AnswerInput(
        questionId: 'q1',
        questionText: 't',
        text: 'answer',
        tStartedAt: DateTime.utc(2026),
      ),
    );
    expect(turn.seq, 1);
    expect(turn.answerText, 'answer');
    expect((await sessions.finish(session.id)).headline, 'fake report');
  });

  test('TurnScore total uses the documented weights', () {
    const score = TurnScore(
      correctness: 4,
      depth: 3,
      structure: 2,
      coverage: 0.5,
    );
    expect(score.total, closeTo(0.5 * 4 + 0.35 * 3 + 0.15 * 2, 1e-9));
  });

  test('CancelToken is idempotent and notifies listeners once', () {
    final token = CancelToken();
    var calls = 0;
    token.addListener(() => calls++);
    token.cancel();
    token.cancel();
    expect(calls, 1);
    expect(token.isCancelled, isTrue);
    expect(token.throwIfCancelled, throwsA(isA<CancelledFailure>()));
    token.addListener(() => calls++);
    expect(calls, 2);
  });
}
