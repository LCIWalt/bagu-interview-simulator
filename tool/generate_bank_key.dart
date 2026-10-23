import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';

/// 生成 Ed25519 密钥对（T-016/T-019）。
///
/// 输出：public key 到 stdout；private key 到 `.toolchain/bank_signing_key.txt`
/// （已 gitignore，禁止提交）。发布签名在 CI Secret 中保存私钥。
Future<void> main() async {
  final algorithm = Ed25519();
  final keyPair = await algorithm.newKeyPair();
  final publicKey = await keyPair.extractPublicKey();
  final privateBytes = await keyPair.extractPrivateKeyBytes();

  stdout.writeln('PUBLIC_KEY_BASE64=${base64Encode(publicKey.bytes)}');
  final out = File('.toolchain/bank_signing_key.txt');
  out.parent.createSync(recursive: true);
  out.writeAsStringSync(
    '${base64Encode(privateBytes)}\n${base64Encode(publicKey.bytes)}\n',
  );
  stdout.writeln('private key 已写入 ${out.path}（勿提交）');
}
