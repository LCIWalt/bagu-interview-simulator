import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/core/agent/prompts/prompt_template.dart';
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/features/interview/domain/interviewer_agent.dart';

import '../fakes/fakes.dart';

const String _prompt = '''
---
id: interviewer.system
version: 1
model: m
temperature: 0.7
variables: [role, company, level, style, mode, phase, remainMin, memorySummary]
---
你是 {{role}} 面试官，级别 {{level}}，风格 {{style}}，阶段 {{phase}}，剩余 {{remainMin}} 分钟。
{{company}} {{mode}} {{memorySummary}}
''';

void main() {
  const config = SessionConfig(
    mode: SessionMode.mock,
    role: 'backend',
    level: 'senior',
  );

  test('streams interviewer text and sends question context', () async {
    final client = FakeLlmClient(
      script: <FakeLlmTurn>[
        FakeLlmTurn(textChunks: <String>['好的，', '我们聊聊 GMP。']),
      ],
    );
    final agent = InterviewerAgent(
      client: client,
      prompts: PromptRegistry(<String, PromptTemplate>{
        'interviewer.system': PromptTemplate.parse(
          _prompt,
          assetPath: 'test.md',
        ),
      }),
      model: 'm',
    );
    final chunks = await agent
        .respond(
          config: config,
          phase: 'project',
          remainMinutes: 12,
          history: const <ChatMessage>[ChatMessage.user('我做过订单系统')],
          nextQuestionTitle: 'Go 的 GMP 模型',
        )
        .toList();

    expect(chunks.join(), '好的，我们聊聊 GMP。');
    final request = client.requests.single;
    expect(request.messages.first.content, contains('backend'));
    expect(request.messages.first.content, contains('senior'));
    expect(request.messages.first.content, contains('剩余 12 分钟'));
    expect(request.messages.last.content, contains('Go 的 GMP 模型'));
    expect(
      request.messages.any((ChatMessage m) => m.content == '我做过订单系统'),
      isTrue,
    );
  });

  test('respondText collects the full response', () async {
    final client = FakeLlmClient(
      script: <FakeLlmTurn>[
        FakeLlmTurn(textChunks: <String>['a', 'b', 'c']),
      ],
    );
    final agent = InterviewerAgent(
      client: client,
      prompts: PromptRegistry(<String, PromptTemplate>{
        'interviewer.system': PromptTemplate.parse(
          _prompt,
          assetPath: 'test.md',
        ),
      }),
      model: 'm',
    );
    final text = await agent.respondText(
      config: config,
      phase: 'warmup',
      remainMinutes: 20,
      history: const <ChatMessage>[],
      nextQuestionTitle: '自我介绍',
    );
    expect(text, 'abc');
  });
}
