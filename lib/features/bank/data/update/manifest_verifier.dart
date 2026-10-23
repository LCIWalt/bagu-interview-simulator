import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:mockmate/core/contracts/contracts.dart';

/// 校验 `manifest.json` 的 Ed25519 签名。
///
/// 签名体：`signature` 字段去掉后、递归 key 排序的紧凑 JSON（UTF-8）。
/// 签名格式：`ed25519:<base64>`。
class ManifestSignatureVerifier {
  ManifestSignatureVerifier({required List<int> publicKeyBytes})
    : _publicKey = SimplePublicKey(publicKeyBytes, type: KeyPairType.ed25519);

  factory ManifestSignatureVerifier.fromBase64(String publicKeyBase64) {
    return ManifestSignatureVerifier(
      publicKeyBytes: base64Decode(publicKeyBase64.trim()),
    );
  }

  final SimplePublicKey _publicKey;
  final Ed25519 _algorithm = Ed25519();

  Future<bool> verify(BankManifest manifest) async {
    final signature = manifest.signature;
    if (!signature.startsWith('ed25519:')) return false;
    final Uint8List signatureBytes;
    try {
      signatureBytes = base64Decode(signature.substring('ed25519:'.length));
    } on FormatException {
      return false;
    }
    final message = canonicalManifestBytes(manifest.toJson());
    try {
      return await _algorithm.verify(
        message,
        signature: Signature(signatureBytes, publicKey: _publicKey),
      );
    } on Exception {
      return false;
    }
  }

  /// 供签名工具复用：manifest 去掉 `signature` 后的规范化字节。
  static Uint8List canonicalManifestBytes(Map<String, Object?> manifest) {
    final copy = Map<String, Object?>.of(manifest)..remove('signature');
    return Uint8List.fromList(utf8.encode(jsonEncode(_sort(copy))));
  }

  static Object? _sort(Object? value) {
    if (value is Map) {
      final keys = value.keys.map((Object? k) => '$k').toList()..sort();
      return <String, Object?>{for (final key in keys) key: _sort(value[key])};
    }
    if (value is List) return value.map(_sort).toList(growable: false);
    return value;
  }
}

/// 将规范化的 manifest 字节签名，返回 `ed25519:<base64>`（工具/测试使用）。
Future<String> signManifest({
  required Map<String, Object?> manifest,
  required List<int> privateKeyBytes,
}) async {
  final algorithm = Ed25519();
  final keyPair = await algorithm.newKeyPairFromSeed(privateKeyBytes);
  final signature = await algorithm.sign(
    ManifestSignatureVerifier.canonicalManifestBytes(manifest),
    keyPair: keyPair,
  );
  return 'ed25519:${base64Encode(signature.bytes)}';
}
