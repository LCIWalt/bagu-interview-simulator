import 'cancel_token.dart';

/// 对话消息角色。
enum ChatRole { system, user, assistant, tool }

/// 模型发起的一次工具调用（参数已解析为 JSON 对象）。
class ToolCall {
  const ToolCall({
    required this.id,
    required this.name,
    required this.arguments,
  });

  final String id;
  final String name;
  final Map<String, Object?> arguments;

  @override
  String toString() => 'ToolCall($name, $id)';
}

/// 一条对话消息。
class ChatMessage {
  const ChatMessage({
    required this.role,
    this.content = '',
    this.toolCalls = const <ToolCall>[],
    this.toolCallId,
    this.name,
  });

  const ChatMessage.system(this.content)
    : role = ChatRole.system,
      toolCalls = const <ToolCall>[],
      toolCallId = null,
      name = null;

  const ChatMessage.user(this.content)
    : role = ChatRole.user,
      toolCalls = const <ToolCall>[],
      toolCallId = null,
      name = null;

  const ChatMessage.assistant(
    this.content, {
    this.toolCalls = const <ToolCall>[],
  }) : role = ChatRole.assistant,
       toolCallId = null,
       name = null;

  const ChatMessage.tool({
    required this.content,
    required this.toolCallId,
    this.name,
  }) : role = ChatRole.tool,
       toolCalls = const <ToolCall>[];

  final ChatRole role;
  final String content;
  final List<ToolCall> toolCalls;
  final String? toolCallId;
  final String? name;
}

/// 暴露给模型的工具 schema（JSON Schema 白名单）。
class ToolDefinition {
  const ToolDefinition({
    required this.name,
    required this.description,
    required this.parameters,
    this.strict = true,
  });

  final String name;
  final String description;
  final Map<String, Object?> parameters;
  final bool strict;
}

/// 一次 chat 请求。模型名由配置注入，不硬编码。
class ChatRequest {
  const ChatRequest({
    required this.model,
    required this.messages,
    this.temperature = 0.7,
    this.maxTokens,
    this.tools = const <ToolDefinition>[],
    this.forceJson = false,
    this.extraBody = const <String, Object?>{},
  });

  final String model;
  final List<ChatMessage> messages;
  final double temperature;
  final int? maxTokens;
  final List<ToolDefinition> tools;

  /// 是否要求 `response_format: {"type":"json_object"}`（评分官用）。
  final bool forceJson;

  /// provider 私有参数（如 `thinking`），由配置决定，默认空。
  final Map<String, Object?> extraBody;
}

/// token 用量，落库到 `llm_calls`。
class LlmUsage {
  const LlmUsage({
    this.promptTokens = 0,
    this.completionTokens = 0,
    this.totalTokens = 0,
    this.cachedPromptTokens = 0,
  });

  final int promptTokens;
  final int completionTokens;
  final int totalTokens;
  final int cachedPromptTokens;

  LlmUsage operator +(LlmUsage other) => LlmUsage(
    promptTokens: promptTokens + other.promptTokens,
    completionTokens: completionTokens + other.completionTokens,
    totalTokens: totalTokens + other.totalTokens,
    cachedPromptTokens: cachedPromptTokens + other.cachedPromptTokens,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'promptTokens': promptTokens,
    'completionTokens': completionTokens,
    'totalTokens': totalTokens,
    'cachedPromptTokens': cachedPromptTokens,
  };
}

/// 流式增量事件。
sealed class LlmDelta {
  const LlmDelta();
}

final class LlmTextDelta extends LlmDelta {
  const LlmTextDelta(this.text);
  final String text;
}

final class LlmToolCallDelta extends LlmDelta {
  const LlmToolCallDelta(this.call);
  final ToolCall call;
}

final class LlmUsageDelta extends LlmDelta {
  const LlmUsageDelta(this.usage);
  final LlmUsage usage;
}

final class LlmDoneDelta extends LlmDelta {
  const LlmDoneDelta({this.finishReason});
  final String? finishReason;
}

/// 所有模型调用的唯一入口（OpenAI 兼容协议）。
abstract interface class LlmClient {
  String get id;

  Stream<LlmDelta> chat(ChatRequest req, {CancelToken? cancel});
}
