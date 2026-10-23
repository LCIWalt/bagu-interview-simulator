import 'package:flutter/material.dart';

import '../core/contracts/contracts.dart';
import '../l10n/generated/app_localizations.dart';

/// 按 Failure 的具体分支给出可操作文案（UI 只按 Failure 分支，AGENTS.md §6）。
String failureText(AppLocalizations l10n, Failure failure) {
  return switch (failure) {
    AuthFailure() => l10n.failureAuth,
    NotFoundFailure() => l10n.failureNotFound,
    RateLimitFailure() => l10n.failureRateLimit,
    TimeoutFailure() => l10n.failureTimeout,
    CancelledFailure() => l10n.failureCancelled,
    BudgetExceededFailure() => l10n.failureBudget,
    ParseFailure() => l10n.failureParse,
    NetworkFailure() => l10n.failureNetwork,
    UnknownFailure() => l10n.failureUnknown,
  };
}

void showFailure(BuildContext context, Failure failure) {
  final l10n = AppLocalizations.of(context);
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(failureText(l10n, failure))));
}
