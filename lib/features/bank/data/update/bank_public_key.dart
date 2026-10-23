/// 内置 Ed25519 公钥（base64），用于校验题库 manifest。
///
/// 开发/自用默认 key 由 `tool/generate_bank_key.dart` 生成；正式分发时通过
/// `--dart-define=BANK_PUBLIC_KEY=...` 注入自己的公钥，私钥只放 CI Secret。
/// 轮换公钥需要发版，旧题库仍可用（离线优先）。
const String kDefaultBankPublicKey = String.fromEnvironment(
  'BANK_PUBLIC_KEY',
  defaultValue: '2ER1BZOt2evm02oDG/n6R2+Ie5vGIA4eKL0gIVkxvwI=',
);

/// 默认题库仓库 release API（mockmate-bank 仓库上线后替换）。
const String kDefaultBankReleaseApiUrl =
    'https://api.github.com/repos/mockmate/mockmate-bank/releases/latest';
