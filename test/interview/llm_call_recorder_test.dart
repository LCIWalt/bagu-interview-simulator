import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/core/agent/cost/llm_call_recorder.dart';
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/core/db/app_database.dart';

import '../fakes/fakes.dart';

const ChatRequest _request = ChatRequest(
  model: 'deepseek-chat',
  messages: <ChatMessage>[ChatMessage.user('hi')],
);

Future<void> _insertSession(AppDatabase db, String id) {
  return db
      .into(db.sessions)
      .insert(
        SessionsCompanion.insert(
          id: id,
          mode: 'drill',
          configJson: '{}',
          startedAt: DateTime.utc(2026),
        ),
      );
}

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.memory();
    await _insertSession(db, 's1');
  });
  tearDown(() => db.close());

  test('records usage and latency without cost estimation', () async {
    final inner = FakeLlmClient(
      script: <FakeLlmTurn>[
        FakeLlmTurn(
          textChunks: <String>['hello'],
          usage: const LlmUsage(
            promptTokens: 1000,
            completionTokens: 500,
            totalTokens: 1500,
          ),
        ),
      ],
    );
    final recorder = LlmCallRecorder(
      inner: inner,
      db: db,
      role: 'scorer',
      providerId: 'provider-scorer',
      sessionId: 's1',
      now: () => DateTime.utc(2026, 10, 22, 10),
    );
    await recorder.chat(_request).toList();

    final calls = await db.select(db.llmCalls).get();
    expect(calls, hasLength(1));
    final call = calls.single;
    expect(call.sessionId, 's1');
    expect(call.role, 'scorer');
    expect(call.model, 'deepseek-chat');
    expect(call.tokensIn, 1000);
    expect(call.tokensOut, 500);
    expect(call.cost, 0);
    expect(call.error, isNull);

    final usage = await recorder.usageFor('s1');
    expect(usage.promptTokens, 1000);
    expect(usage.completionTokens, 500);
  });

  test('failure is recorded with a redacted error and no usage', () async {
    final inner = FakeLlmClient(
      script: <FakeLlmTurn>[
        FakeLlmTurn(error: const NetworkFailure('boom sk-secret123456')),
      ],
    );
    final recorder = LlmCallRecorder(
      inner: inner,
      db: db,
      role: 'scorer',
      providerId: 'p',
      sessionId: 's1',
    );
    await expectLater(
      recorder.chat(_request),
      emitsError(isA<NetworkFailure>()),
    );
    final call = (await db.select(db.llmCalls).get()).single;
    expect(call.error, isNotNull);
    expect(call.error, contains('boom'));
    expect(call.error, isNot(contains('sk-secret123456')));
    expect(call.tokensIn, 0);
  });

  test('works without a session and only writes llm_calls', () async {
    final recorder = LlmCallRecorder(
      inner: FakeLlmClient(
        script: <FakeLlmTurn>[
          FakeLlmTurn(
            usage: const LlmUsage(
              promptTokens: 10,
              completionTokens: 5,
              totalTokens: 15,
            ),
          ),
        ],
      ),
      db: db,
      role: 'interviewer',
      providerId: 'p',
    );
    await recorder.chat(_request).toList();
    expect(await db.select(db.llmCalls).get(), hasLength(1));
    expect((await db.select(db.sessions).getSingle()).cost, 0);
  });
}
