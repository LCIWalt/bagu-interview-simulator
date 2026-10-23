import '../../../../core/contracts/contracts.dart';

/// 更新管线入口；由 BankUpdateService 实现，BankRepositoryImpl 委托。
abstract interface class BankUpdateRunner {
  Stream<BankUpdateProgress> run({
    required BankChannel channel,
    bool force = false,
    CancelToken? cancel,
    String? mirrorBase,
  });
}
