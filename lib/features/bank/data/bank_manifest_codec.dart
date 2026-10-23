import 'package:mockmate/core/contracts/contracts.dart';

/// `manifest.json` ↔ [BankManifest]。仅做结构映射；验签/哈希在 T-016 校验。
abstract final class BankManifestCodec {
  static BankManifest fromJson(Map<String, dynamic> json) {
    final counts = json['counts'] is Map<String, dynamic>
        ? json['counts'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final files = json['files'] is List
        ? json['files'] as List
        : const <Object?>[];
    final assets = json['assets'] is List
        ? json['assets'] as List
        : const <Object?>[];
    return BankManifest(
      schemaVersion: json['schemaVersion'] as int? ?? 1,
      bankVersion: json['bankVersion']?.toString() ?? '0.0.0',
      minAppVersion: json['minAppVersion']?.toString() ?? '0.5.0',
      generatedAt:
          DateTime.tryParse(json['generatedAt']?.toString() ?? '') ??
          DateTime.now(),
      gitCommit: json['gitCommit']?.toString() ?? '',
      questionCount: counts['questions'] as int? ?? 0,
      experienceCount: counts['experiences'] as int? ?? 0,
      files: files
          .whereType<Map<String, dynamic>>()
          .map(
            (Map<String, dynamic> f) => BankFileEntry(
              path: f['path']?.toString() ?? '',
              sha256: f['sha256']?.toString() ?? '',
              bytes: f['bytes'] as int? ?? 0,
            ),
          )
          .toList(growable: false),
      assets: assets
          .whereType<Map<String, dynamic>>()
          .map(
            (Map<String, dynamic> a) => BankAsset(
              name: a['name']?.toString() ?? '',
              sha256: a['sha256']?.toString() ?? '',
              bytes: a['bytes'] as int? ?? 0,
            ),
          )
          .toList(growable: false),
      signature: json['signature']?.toString() ?? '',
    );
  }
}
