import 'package:mockmate/core/agent/prompts/prompt_template.dart';
import 'package:mockmate/core/contracts/contracts.dart';

/// 面试官 Agent（T-041）：只对话、不评分、不点评。
class InterviewerAgent {
  InterviewerAgent({
    required this.client,
    required this.prompts,
    required this.model,
    this.maxHistory = 8,
  });

  final LlmClient client;
  final PromptRegistry prompts;
  final String model;
  final int maxHistory;

  Stream<String> respond({
    required SessionConfig config,
    required String phase,
    required int remainMinutes,
    required List<ChatMessage> history,
    required String nextQuestionTitle,
    String memorySummary = '',
    CancelToken? cancel,
  }) async* {
    final template = prompts.require('interviewer.system');
    final system = template.render(<String, String>{
      'role': config.role,
      'company': '未指定',
      'level': config.level,
      'style': config.style.name,
      'mode': config.mode.name,
      'phase': phase,
      'remainMin': '$remainMinutes',
      'memorySummary': memorySummary.isEmpty ? '（暂无）' : memorySummary,
    });
    final request = ChatRequest(
      model: model,
      messages: <ChatMessage>[
        ChatMessage.system(system),
        ...history.length > maxHistory
            ? history.sublist(history.length - maxHistory)
            : history,
        ChatMessage.user(
          '接下来要问的题库题目是：「$nextQuestionTitle」。'
          '请先用一句话接住候选人的上一段回答（不评价对错），'
          '再用一到两句话提出这道题。不要给答案，不要评价。',
        ),
      ],
      temperature: template.temperature,
      maxTokens: 220,
    );
    await for (final delta in client.chat(request, cancel: cancel)) {
      if (delta is LlmTextDelta) yield delta.text;
      if (delta is LlmDoneDelta) break;
    }
  }

  Future<String> respondText({
    required SessionConfig config,
    required String phase,
    required int remainMinutes,
    required List<ChatMessage> history,
    required String nextQuestionTitle,
    String memorySummary = '',
    CancelToken? cancel,
  }) async {
    final buffer = StringBuffer();
    await for (final chunk in respond(
      config: config,
      phase: phase,
      remainMinutes: remainMinutes,
      history: history,
      nextQuestionTitle: nextQuestionTitle,
      memorySummary: memorySummary,
      cancel: cancel,
    )) {
      buffer.write(chunk);
    }
    return buffer.toString().trim();
  }
}
