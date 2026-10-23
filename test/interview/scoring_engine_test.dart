import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/core/agent/prompts/prompt_source.dart';
import 'package:mockmate/core/agent/prompts/prompt_template.dart';
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/features/interview/domain/scoring/scoring_engine.dart';

import '../fakes/fakes.dart';

final Question _question = Question(
  id: 'q1',
  bankVersion: '2026.10.1',
  title: 'Go 的 GMP 模型',
  bodyMarkdown: '题干',
  topics: const <String>['go'],
  role: 'backend',
  level: 3,
  difficulty: 3,
  type: QuestionType.knowledge,
  answer: const QuestionAnswer(
    summary: 'summary',
    keyPoints: <String>['M 与 P 解耦', '本地运行队列', 'syscall 时 P 移交'],
    pitfalls: <String>['把 P 当线程'],
  ),
  updatedAt: DateTime.utc(2026),
);

String _json({
  List<Map<String, Object?>> points = const <Map<String, Object?>>[],
  List<Map<String, Object?>> errors = const <Map<String, Object?>>[],
  num correctness = 4,
  num depth = 4,
  num structure = 3,
}) {
  return jsonEncode(<String, Object?>{
    'points': points,
    'factualErrors': errors,
    'correctness': correctness,
    'depth': depth,
    'structure': structure,
    'coverage': 0,
    'comment': 'comment',
  });
}

Map<String, Object?> _point(
  String point,
  String verdict, [
  String evidence = '',
]) => <String, Object?>{
  'point': point,
  'verdict': verdict,
  'evidence': evidence,
};

Future<PromptRegistry> _registry() async {
  final content = await File('assets/prompts/scorer.rubric.md').readAsString();
  return PromptRegistry.load(
    InMemoryPromptSource(<String, String>{
      'assets/prompts/scorer.rubric.md': content,
    }),
  );
}

void main() {
  test(
    'computes coverage, applies the coverage ceiling and keeps evidence',
    () async {
      final client = FakeLlmClient(
        script: <FakeLlmTurn>[
          FakeLlmTurn(
            textChunks: <String>[
              _json(
                points: <Map<String, Object?>>[
                  _point('M 与 P 解耦', 'hit', 'M 与 P 解耦'),
                  _point('本地运行队列', 'partial', '本地运行队列'),
                  _point('syscall 时 P 移交', 'miss'),
                ],
              ),
            ],
          ),
        ],
      );
      final engine = ScoringEngine(
        client: client,
        prompts: await _registry(),
        model: 'deepseek-chat',
      );
      final score = await engine.score(
        question: _question,
        answerText: 'M 与 P 解耦，本地运行队列负责调度。',
      );

      expect(score.coverage, closeTo(0.5, 1e-9));
      expect(score.points.map((TurnScorePoint p) => p.verdict), <String>[
        'hit',
        'partial',
        'miss',
      ]);
      expect(score.correctness, closeTo(3, 1e-9)); // min(4, 1+4*0.5)
      expect(score.total, closeTo(0.5 * 3 + 0.35 * 4 + 0.15 * 3, 1e-9));
      expect(client.requests.single.forceJson, isTrue);
      expect(
        client.requests.single.messages.single.content,
        contains('Go 的 GMP 模型'),
      );
      expect(
        client.requests.single.messages.single.content,
        contains('1. M 与 P 解耦'),
      );
    },
  );

  test('drops hits without verbatim evidence', () async {
    final client = FakeLlmClient(
      script: <FakeLlmTurn>[
        FakeLlmTurn(
          textChunks: <String>[
            _json(
              points: <Map<String, Object?>>[
                _point('M 与 P 解耦', 'hit', '回答里没有这句话'),
                _point('本地运行队列', 'hit', '本地运行队列'),
                _point('syscall 时 P 移交', 'not_asked'),
              ],
              correctness: 5,
            ),
          ],
        ),
      ],
    );
    final engine = ScoringEngine(
      client: client,
      prompts: await _registry(),
      model: 'm',
    );
    final score = await engine.score(
      question: _question,
      answerText: '本地运行队列负责调度。',
    );
    expect(score.points.first.verdict, 'miss');
    expect(score.points.first.evidence, isEmpty);
    expect(score.coverage, closeTo(0.5, 1e-9));
    expect(score.correctness, closeTo(3, 1e-9));
  });

  test('excludes not_asked points from the denominator', () async {
    final client = FakeLlmClient(
      script: <FakeLlmTurn>[
        FakeLlmTurn(
          textChunks: <String>[
            _json(
              points: <Map<String, Object?>>[
                _point('M 与 P 解耦', 'hit', 'M 与 P 解耦'),
                _point('本地运行队列', 'not_asked'),
                _point('syscall 时 P 移交', 'not_asked'),
              ],
            ),
          ],
        ),
      ],
    );
    final score = await ScoringEngine(
      client: client,
      prompts: await _registry(),
      model: 'm',
    ).score(question: _question, answerText: 'M 与 P 解耦');
    expect(score.coverage, closeTo(1, 1e-9));
  });

  test(
    'penalises factual errors only when the quote is in the answer',
    () async {
      final client = FakeLlmClient(
        script: <FakeLlmTurn>[
          FakeLlmTurn(
            textChunks: <String>[
              _json(
                points: <Map<String, Object?>>[
                  _point('M 与 P 解耦', 'hit', 'M 与 P 解耦'),
                  _point('本地运行队列', 'not_asked'),
                  _point('syscall 时 P 移交', 'not_asked'),
                ],
                errors: <Map<String, Object?>>[
                  <String, Object?>{'quote': 'M 与 P 解耦', 'issue': '说法不准确'},
                  <String, Object?>{'quote': '编造的原文', 'issue': '无来源'},
                ],
                correctness: 5,
              ),
            ],
          ),
        ],
      );
      final score = await ScoringEngine(
        client: client,
        prompts: await _registry(),
        model: 'm',
      ).score(question: _question, answerText: 'M 与 P 解耦');
      expect(score.factualErrors, hasLength(1));
      expect(score.correctness, closeTo(4.5, 1e-9));
    },
  );

  test('retries once on invalid JSON and then succeeds', () async {
    final client = FakeLlmClient(
      script: <FakeLlmTurn>[
        FakeLlmTurn(textChunks: <String>['not json']),
        FakeLlmTurn(
          textChunks: <String>[
            _json(
              points: <Map<String, Object?>>[
                _point('M 与 P 解耦', 'hit', 'M 与 P 解耦'),
                _point('本地运行队列', 'miss'),
                _point('syscall 时 P 移交', 'miss'),
              ],
            ),
          ],
        ),
      ],
    );
    final score = await ScoringEngine(
      client: client,
      prompts: await _registry(),
      model: 'm',
    ).score(question: _question, answerText: 'M 与 P 解耦');
    expect(score.degraded, isFalse);
    expect(client.requests, hasLength(2));
  });

  test('degrades after two invalid responses', () async {
    final client = FakeLlmClient(
      script: <FakeLlmTurn>[
        FakeLlmTurn(textChunks: <String>['nope']),
        FakeLlmTurn(textChunks: <String>['still nope']),
      ],
    );
    final score = await ScoringEngine(
      client: client,
      prompts: await _registry(),
      model: 'm',
    ).score(question: _question, answerText: 'answer');
    expect(score.degraded, isTrue);
    expect(score.points, isEmpty);
    expect(score.comment, contains('still nope'));
  });

  test('accepts JSON wrapped in a markdown fence', () async {
    final body = _json(
      points: <Map<String, Object?>>[
        _point('M 与 P 解耦', 'hit', 'M 与 P 解耦'),
        _point('本地运行队列', 'miss'),
        _point('syscall 时 P 移交', 'miss'),
      ],
    );
    final client = FakeLlmClient(
      script: <FakeLlmTurn>[
        FakeLlmTurn(textChunks: <String>['```json\n$body\n```']),
      ],
    );
    final score = await ScoringEngine(
      client: client,
      prompts: await _registry(),
      model: 'm',
    ).score(question: _question, answerText: 'M 与 P 解耦');
    expect(score.degraded, isFalse);
  });

  test('missing point entries are treated as miss', () async {
    final client = FakeLlmClient(
      script: <FakeLlmTurn>[
        FakeLlmTurn(
          textChunks: <String>[
            _json(
              points: <Map<String, Object?>>[
                _point('M 与 P 解耦', 'hit', 'M 与 P 解耦'),
              ],
            ),
          ],
        ),
      ],
    );
    final score = await ScoringEngine(
      client: client,
      prompts: await _registry(),
      model: 'm',
    ).score(question: _question, answerText: 'M 与 P 解耦');
    expect(score.points.map((TurnScorePoint p) => p.verdict), <String>[
      'hit',
      'miss',
      'miss',
    ]);
    expect(score.coverage, closeTo(1 / 3, 1e-9));
  });
}
