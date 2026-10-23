import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/core/agent/prompts/prompt_template.dart';
import 'package:mockmate/features/interview/domain/factcheck/claim_extractor.dart';

import '../fakes/fakes.dart';

const String _prompt = '''
---
id: claim.extract
version: 1
model: m
temperature: 0.1
variables: [answerText]
---
{{answerText}}
''';

void main() {
  final prompts = PromptRegistry(<String, PromptTemplate>{
    'claim.extract': PromptTemplate.parse(_prompt, assetPath: 'test.md'),
  });

  test(
    'extracts quoted claims, drops fabricated ones and grades risk',
    () async {
      final answer = 'Go 1.22 起 loop var 每轮新变量，QPS 提升 30%。我觉得还行。';
      final client = FakeLlmClient(
        script: <FakeLlmTurn>[
          FakeLlmTurn(
            textChunks: <String>[
              jsonEncode(<String, Object?>{
                'claims': <Object?>[
                  <String, Object?>{
                    'text': 'Go 1.22 起 loop var 每轮新变量',
                    'risk': 'high',
                    'reasons': <String>['版本相关'],
                    'queries': <String>[
                      'Go 1.22 loop variable',
                      'Go 1.22 循环变量',
                    ],
                  },
                  <String, Object?>{
                    'text': 'QPS 提升 30%',
                    'risk': 'high',
                    'reasons': <String>['数字'],
                    'queries': <String>['Go QPS', 'Go performance'],
                  },
                  <String, Object?>{
                    'text': '我编造的断言',
                    'risk': 'high',
                    'reasons': <String>[],
                    'queries': <String>[],
                  },
                ],
              }),
            ],
          ),
        ],
      );
      final extractor = ClaimExtractor(
        client: client,
        prompts: prompts,
        model: 'm',
      );
      final claims = await extractor.extract(answerText: answer);
      expect(claims, hasLength(2));
      expect(claims.first.text, contains('loop var'));
      expect(claims.every((ExtractedClaim c) => c.isHighRisk), isTrue);
      expect(claims.first.queries, hasLength(2));
    },
  );

  test(
    'heuristic promotes version/number claims even if model says low',
    () async {
      final client = FakeLlmClient(
        script: <FakeLlmTurn>[
          FakeLlmTurn(
            textChunks: <String>[
              jsonEncode(<String, Object?>{
                'claims': <Object?>[
                  <String, Object?>{'text': 'P99 是 200ms', 'risk': 'low'},
                  <String, Object?>{'text': '闭包保存引用', 'risk': 'low'},
                ],
              }),
            ],
          ),
        ],
      );
      final claims = await ClaimExtractor(
        client: client,
        prompts: prompts,
        model: 'm',
      ).extract(answerText: 'P99 是 200ms，闭包保存引用');
      expect(claims.first.isHighRisk, isTrue);
      expect(claims.last.isHighRisk, isFalse);
    },
  );

  test('invalid JSON returns empty', () async {
    final client = FakeLlmClient(
      script: <FakeLlmTurn>[
        FakeLlmTurn(textChunks: <String>['nope']),
      ],
    );
    expect(
      await ClaimExtractor(
        client: client,
        prompts: prompts,
        model: 'm',
      ).extract(answerText: 'x'),
      isEmpty,
    );
  });
}
