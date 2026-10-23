import 'dart:io';

import 'package:mockmate/features/bank/data/bank_validator.dart';

/// 用法：dart run tool/validate_bank.dart [题库目录]
///
/// 退出码：0 通过；1 校验失败；2 参数/目录错误。问题输出带 file:line:column。
Future<void> main(List<String> args) async {
  final root = args.isEmpty ? 'assets/bank_seed' : args.first;
  if (!Directory(root).existsSync()) {
    stderr.writeln('目录不存在: $root');
    exitCode = 2;
    return;
  }

  final report = const BankValidator().validateDirectory(Directory(root));
  for (final issue in report.sortedIssues) {
    stdout.writeln(issue.format());
  }
  stdout.writeln(
    '${report.ok ? 'OK' : 'FAILED'}: ${report.questionCount} questions, '
    '${report.issues.length} issues, bankVersion=${report.bankVersion}',
  );
  exitCode = report.ok ? 0 : 1;
}
