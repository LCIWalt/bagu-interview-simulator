import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/core/agent/prompts/prompt_template.dart';
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/core/db/app_database.dart' hide SessionMemory;
import 'package:mockmate/features/interview/data/drift_session_repository.dart';
import 'package:mockmate/features/interview/data/session_memory_store.dart';
import 'package:mockmate/features/interview/domain/memory/memory_extractor.dart';
import 'package:mockmate/features/interview/domain/memory/session_memory.dart';

import '../fakes/fakes.dart';

const String _prompt = '''
---
id: memory.extract
version: 1
model: m
temperature: 0.3
variables: [role, level, turnText]
---
{{role}} {{level}} {{turnText}}
''';

const String _json = '''
{
  "projects": [{"name": "订单系统", "stack": ["Kafka"], "claims": ["5万 QPS"]}],
  "claims": [{"text": "用 Kafka 扛 5 万 QPS"}],
  "numbers": ["5万 QPS"],
  "contradictions": [],
  "unanswered": ["为什么不用 RocketMQ"],
  "weakTopics": ["一致性"]
}
''';

void main() {
  const config = SessionConfig(
    mode: SessionMode.mock,
    role: 'backend',
    level: 'mid',
  );

  test('extracts structured memory and ignores invalid JSON', () async {
    final client = FakeLlmClient(
      script: <FakeLlmTurn>[
        FakeLlmTurn(textChunks: <String>[_json]),
        FakeLlmTurn(textChunks: <String>['not json']),
        FakeLlmTurn(textChunks: <String>['still bad']),
      ],
    );
    final extractor = MemoryExtractor(
      client: client,
      prompts: PromptRegistry(<String, PromptTemplate>{
        'memory.extract': PromptTemplate.parse(_prompt, assetPath: 'test.md'),
      }),
      model: 'm',
    );
    final result = await extractor.extract(
      config: config,
      turnText: 'Q: ...\nA: ...',
    );
    expect(result?.claims.single.text, '用 Kafka 扛 5 万 QPS');
    expect(result?.numbers, <String>['5万 QPS']);
    expect(result?.weakTopics, <String>['一致性']);

    expect(await extractor.extract(config: config, turnText: 'x'), isNull);
  });

  test('merges, dedupes and exports memory', () async {
    final db = AppDatabase.memory();
    final root = Directory.systemTemp.createTempSync('memory_export_');
    addTearDown(() async {
      await db.close();
      if (root.existsSync()) root.deleteSync(recursive: true);
    });
    final repo = DriftSessionRepository(db);
    final session = await repo.create(config);
    final store = SessionMemoryStore(db);

    final extraction = MemoryExtraction(
      projects: <MemoryProject>[
        const MemoryProject(
          name: '订单系统',
          stack: <String>['Kafka'],
          claims: <String>['5万 QPS'],
        ),
      ],
      claims: const <MemoryClaim>[MemoryClaim(text: '用 Kafka 扛 5 万 QPS')],
      numbers: const <String>['5万 QPS'],
      unanswered: const <String>['为什么不用 RocketMQ'],
      weakTopics: const <String>['一致性'],
    );
    await store.merge(session.id, extraction, turnSeq: 1, questionId: 'q1');
    await store.merge(
      session.id,
      MemoryExtraction(
        claims: <MemoryClaim>[
          const MemoryClaim(text: '用 Kafka 扛 5 万 QPS'),
          const MemoryClaim(text: 'P99 为 200ms'),
        ],
        weakTopics: const <String>['容量估算'],
      ),
      turnSeq: 2,
      questionId: 'q2',
    );

    final memory = await store.load(session.id);
    expect(memory?.claims, hasLength(2));
    expect(memory?.weakTopics, containsAll(<String>['一致性', '容量估算']));
    expect(memory?.askedQuestionIds, <String>['q1', 'q2']);
    expect(memory?.projects.single.name, '订单系统');

    final path = await store.export(session.id, root);
    final exported =
        jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
    expect(exported['sessionId'], session.id);
    expect(exported['claims'], hasLength(2));

    final summary = await store.latestSummary(excludeSessionId: 'other');
    expect(summary, contains('Kafka'));
  });

  test('memory model round-trips', () {
    const memory = SessionMemory(
      sessionId: 's1',
      role: 'backend',
      level: 'mid',
      mode: 'mock',
      numbers: <String>['200ms'],
      askedQuestionIds: <String>['q1'],
    );
    final decoded = SessionMemory.fromJson(
      jsonDecode(memory.encode()) as Map<String, dynamic>,
    );
    expect(decoded.sessionId, 's1');
    expect(decoded.numbers, <String>['200ms']);
    expect(decoded.askedQuestionIds.first, 'q1');
  });
}
