import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/contracts/contracts.dart';
import '../../data/update/bank_update_service.dart' show BankUpdateService;
import '../bank_providers.dart';

enum BankUpdatePhase {
  idle,
  checking,
  downloading,
  verifying,
  activating,
  done,
  upToDate,
  failed,
}

@immutable
class BankUpdateState {
  const BankUpdateState({
    this.phase = BankUpdatePhase.idle,
    this.received = 0,
    this.total = 0,
    this.stage = '',
    this.manifest,
    this.failure,
  });

  final BankUpdatePhase phase;
  final int received;
  final int total;
  final String stage;
  final BankManifest? manifest;
  final Failure? failure;

  bool get busy => switch (phase) {
    BankUpdatePhase.checking ||
    BankUpdatePhase.downloading ||
    BankUpdatePhase.verifying ||
    BankUpdatePhase.activating => true,
    _ => false,
  };

  double? get progress {
    if (phase != BankUpdatePhase.downloading || total <= 0) return null;
    return (received / total).clamp(0, 1);
  }
}

/// 题库更新 UI 状态机（T-017）。取消会贯穿 HTTP 下载与 staging 清理。
class BankUpdateController extends StateNotifier<BankUpdateState> {
  BankUpdateController(this._ref) : super(const BankUpdateState());

  final Ref _ref;
  CancelToken? _cancel;

  Future<void> start({bool force = true, String? mirrorBase}) async {
    if (state.busy) return;
    final cancel = CancelToken();
    _cancel = cancel;
    state = const BankUpdateState(phase: BankUpdatePhase.checking);
    try {
      final BankUpdateService service = await _ref.read(
        bankUpdateServiceProvider.future,
      );
      await for (final event in service.run(
        channel: BankChannel.stable,
        force: force,
        cancel: cancel,
        mirrorBase: mirrorBase,
      )) {
        if (!mounted) return;
        state = _map(event);
        if (event is BankUpdated) {
          _ref.invalidate(bankResultsProvider);
          _ref.invalidate(installedManifestProvider);
        }
        if (event is BankUpToDate) {
          _ref.invalidate(installedManifestProvider);
        }
      }
    } on Failure catch (failure) {
      if (mounted) {
        state = BankUpdateState(
          phase: BankUpdatePhase.failed,
          failure: failure,
        );
      }
    } on Object catch (error) {
      if (mounted) {
        state = BankUpdateState(
          phase: BankUpdatePhase.failed,
          failure: UnknownFailure('$error'),
        );
      }
    } finally {
      if (identical(_cancel, cancel)) _cancel = null;
    }
  }

  void cancel() {
    _cancel?.cancel();
    _cancel = null;
    if (mounted) {
      state = BankUpdateState(
        phase: BankUpdatePhase.failed,
        failure: const CancelledFailure(),
      );
    }
  }

  BankUpdateState _map(BankUpdateProgress event) => switch (event) {
    BankChecking() => const BankUpdateState(phase: BankUpdatePhase.checking),
    BankDownloading(:final receivedBytes, :final totalBytes) => BankUpdateState(
      phase: BankUpdatePhase.downloading,
      received: receivedBytes,
      total: totalBytes,
    ),
    BankVerifying(:final stage) => BankUpdateState(
      phase: BankUpdatePhase.verifying,
      stage: stage,
    ),
    BankActivating() => const BankUpdateState(
      phase: BankUpdatePhase.activating,
    ),
    BankUpdated(:final manifest) => BankUpdateState(
      phase: BankUpdatePhase.done,
      manifest: manifest,
    ),
    BankUpToDate(:final manifest) => BankUpdateState(
      phase: BankUpdatePhase.upToDate,
      manifest: manifest,
    ),
    BankUpdateFailed(:final failure) => BankUpdateState(
      phase: BankUpdatePhase.failed,
      failure: failure,
    ),
  };

  @override
  void dispose() {
    _cancel?.cancel();
    super.dispose();
  }
}

final AutoDisposeStateNotifierProvider<BankUpdateController, BankUpdateState>
bankUpdateProvider =
    StateNotifierProvider.autoDispose<BankUpdateController, BankUpdateState>(
      BankUpdateController.new,
    );
