/// 语音输入契约。
///
/// v1 只有 [SystemDictationProvider]：不采集音频，`capturesAudio == false`。
/// 未来接入 App 内录音时新增实现并替换默认值，UI 不变。
abstract interface class SttProvider {
  String get id;

  /// v1 必须为 false；为 true 时需 ADR 与麦克风权限。
  bool get capturesAudio;

  Future<bool> isAvailable();
}

/// 系统输入法听写：App 侧零权限、零通道，仅提供能力声明与引导文案。
class SystemDictationProvider implements SttProvider {
  const SystemDictationProvider();

  @override
  String get id => 'system-dictation';

  @override
  bool get capturesAudio => false;

  @override
  Future<bool> isAvailable() async => true;
}
