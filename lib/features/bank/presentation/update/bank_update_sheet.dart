import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/failure_text.dart';
import '../../../../core/design/glass.dart';
import '../../../../core/design/tokens.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../bank_providers.dart';
import 'bank_update_controller.dart';

/// T-017：检查更新、下载进度、失败原因、重试、镜像、取消。
class BankUpdateSheet extends ConsumerStatefulWidget {
  const BankUpdateSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => const BankUpdateSheet(),
    );
  }

  @override
  ConsumerState<BankUpdateSheet> createState() => _BankUpdateSheetState();
}

class _BankUpdateSheetState extends ConsumerState<BankUpdateSheet> {
  final TextEditingController _mirror = TextEditingController();

  @override
  void dispose() {
    _mirror.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final state = ref.watch(bankUpdateProvider);
    final installed = ref.watch(installedManifestProvider).valueOrNull;

    return GlassSheet(
      title: l10n.bankUpdateTitle,
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonClose),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            installed == null
                ? l10n.bankUpdateNotInstalled
                : l10n.bankUpdateCurrent(installed.bankVersion),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: MockSpace.s3),
          if (state.busy) ...<Widget>[
            LinearProgressIndicator(value: state.progress),
            const SizedBox(height: MockSpace.s2),
            Text(_phaseLabel(l10n, state), style: theme.textTheme.bodySmall),
            const SizedBox(height: MockSpace.s3),
            GlassButton(
              label: l10n.bankUpdateCancel,
              primary: false,
              icon: Icons.close,
              onPressed: () => ref.read(bankUpdateProvider.notifier).cancel(),
            ),
          ] else ...<Widget>[
            if (state.phase == BankUpdatePhase.idle ||
                state.phase == BankUpdatePhase.failed)
              TextField(
                controller: _mirror,
                keyboardType: TextInputType.url,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: l10n.bankUpdateMirror,
                  hintText: l10n.bankUpdateMirrorHint,
                ),
              ),
            if (state.phase == BankUpdatePhase.idle) ...<Widget>[
              const SizedBox(height: MockSpace.s3),
              GlassButton(
                label: l10n.bankUpdateCheck,
                icon: Icons.cloud_download_outlined,
                onPressed: () => ref
                    .read(bankUpdateProvider.notifier)
                    .start(
                      mirrorBase: _mirror.text.trim().isEmpty
                          ? null
                          : _mirror.text.trim(),
                    ),
              ),
            ],
            if (state.phase == BankUpdatePhase.failed) ...<Widget>[
              const SizedBox(height: MockSpace.s2),
              Text(
                l10n.bankUpdateFailed,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: MockSpace.s1),
              Text(
                state.failure == null
                    ? l10n.failureUnknown
                    : failureText(l10n, state.failure!),
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: MockSpace.s3),
              GlassButton(
                label: l10n.bankUpdateRetry,
                icon: Icons.refresh,
                onPressed: () => ref
                    .read(bankUpdateProvider.notifier)
                    .start(
                      mirrorBase: _mirror.text.trim().isEmpty
                          ? null
                          : _mirror.text.trim(),
                    ),
              ),
            ],
            if (state.phase == BankUpdatePhase.done) ...<Widget>[
              const SizedBox(height: MockSpace.s2),
              Text(
                l10n.bankUpdateDone(state.manifest?.bankVersion ?? ''),
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: MockSpace.s1),
              Text(l10n.bankUpdateReady, style: theme.textTheme.bodySmall),
            ],
            if (state.phase == BankUpdatePhase.upToDate) ...<Widget>[
              const SizedBox(height: MockSpace.s2),
              Text(l10n.bankUpdateUpToDate, style: theme.textTheme.titleSmall),
            ],
          ],
        ],
      ),
    );
  }

  String _phaseLabel(AppLocalizations l10n, BankUpdateState state) {
    return switch (state.phase) {
      BankUpdatePhase.checking => l10n.bankUpdateChecking,
      BankUpdatePhase.downloading => l10n.bankUpdateDownloading(
        ((state.progress ?? 0) * 100).toStringAsFixed(0),
      ),
      BankUpdatePhase.verifying => l10n.bankUpdateVerifying(state.stage),
      BankUpdatePhase.activating => l10n.bankUpdateActivating,
      _ => '',
    };
  }
}
