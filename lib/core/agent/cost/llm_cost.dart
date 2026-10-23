/// token 用量累计；v0.5 只统计 token，不做费用估算。
class UsageSnapshot {
  const UsageSnapshot({this.promptTokens = 0, this.completionTokens = 0});

  final int promptTokens;
  final int completionTokens;

  int get totalTokens => promptTokens + completionTokens;
}
