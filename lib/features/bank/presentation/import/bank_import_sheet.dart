import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/design/glass.dart';
import '../../../../core/design/tokens.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/import/bank_import_service.dart';
import '../bank_providers.dart';

/// T-018：粘贴 YAML → 预览 → 选择冲突策略 → 导入。
class BankImportSheet extends ConsumerStatefulWidget {
  const BankImportSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => const BankImportSheet(),
    );
  }

  @override
  ConsumerState<BankImportSheet> createState() => _BankImportSheetState();
}

class _BankImportSheetState extends ConsumerState<BankImportSheet> {
  final TextEditingController _content = TextEditingController();
  ImportPreview? _preview;
  ImportOutcome? _outcome;
  ImportConflictPolicy _policy = ImportConflictPolicy.skip;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _content.dispose();
    super.dispose();
  }

  Future<void> _runPreview() async {
    final l10n = AppLocalizations.of(context);
    if (_content.text.trim().isEmpty) {
      setState(() => _error = l10n.bankImportNoValid);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _outcome = null;
    });
    try {
      final preview = await ref
          .read(bankImportServiceProvider)
          .preview(_content.text);
      if (!mounted) return;
      setState(() => _preview = preview);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _commit() async {
    final l10n = AppLocalizations.of(context);
    final preview = _preview;
    if (preview == null) {
      setState(() => _error = l10n.bankImportNeedPreview);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final outcome = await ref
          .read(bankImportServiceProvider)
          .commit(preview, policy: _policy);
      if (!mounted) return;
      ref.invalidate(bankResultsProvider);
      setState(() => _outcome = outcome);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return GlassSheet(
      title: l10n.bankImportTitle,
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonClose),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            controller: _content,
            minLines: 5,
            maxLines: 12,
            style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
            decoration: InputDecoration(
              hintText: l10n.bankImportHint,
              hintMaxLines: 2,
            ),
          ),
          const SizedBox(height: MockSpace.s3),
          Wrap(
            spacing: MockSpace.s3,
            runSpacing: MockSpace.s2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              GlassButton(
                label: l10n.bankImportPreview,
                icon: Icons.visibility_outlined,
                busy: _busy && _preview == null,
                onPressed: _busy ? null : _runPreview,
              ),
              Text(l10n.bankImportPolicy, style: theme.textTheme.labelMedium),
              SegmentedButton<ImportConflictPolicy>(
                segments: <ButtonSegment<ImportConflictPolicy>>[
                  ButtonSegment<ImportConflictPolicy>(
                    value: ImportConflictPolicy.skip,
                    label: Text(l10n.bankImportSkip),
                  ),
                  ButtonSegment<ImportConflictPolicy>(
                    value: ImportConflictPolicy.overwrite,
                    label: Text(l10n.bankImportOverwrite),
                  ),
                  ButtonSegment<ImportConflictPolicy>(
                    value: ImportConflictPolicy.merge,
                    label: Text(l10n.bankImportMerge),
                  ),
                ],
                selected: <ImportConflictPolicy>{_policy},
                onSelectionChanged: (Set<ImportConflictPolicy> value) {
                  setState(() => _policy = value.first);
                },
              ),
            ],
          ),
          if (_preview != null) ...<Widget>[
            const SizedBox(height: MockSpace.s3),
            Text(
              l10n.bankImportParsed(
                '${_preview!.conflictCount}',
                '${_preview!.validCount}',
              ),
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: MockSpace.s2),
            if (_preview!.items.isNotEmpty)
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 180),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _preview!.items.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = _preview!.items[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: MockSpace.s1),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            item.valid
                                ? Icons.check_circle_outline
                                : Icons.error_outline,
                            size: 16,
                            color: item.valid
                                ? theme.colorScheme.primary
                                : theme.colorScheme.error,
                          ),
                          const SizedBox(width: MockSpace.s2),
                          Expanded(
                            child: Text(
                              item.question?.title ?? item.sourceLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (item.conflict)
                            Text(
                              l10n.bankImportConflictLabel,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          if (!item.valid)
                            Text(
                              l10n.bankImportInvalidLabel,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: MockSpace.s3),
            GlassButton(
              label: l10n.bankImportConfirm('${_preview!.validCount}'),
              icon: Icons.upload_file_outlined,
              busy: _busy,
              onPressed: _preview!.validCount == 0 ? null : _commit,
            ),
          ],
          if (_error != null) ...<Widget>[
            const SizedBox(height: MockSpace.s3),
            Text(
              _error!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
          if (_outcome != null) ...<Widget>[
            const SizedBox(height: MockSpace.s3),
            Text(
              l10n.bankImportResult(
                '${_outcome!.created}',
                '${_outcome!.failed}',
                '${_outcome!.merged}',
                '${_outcome!.overwritten}',
                '${_outcome!.skipped}',
              ),
              style: theme.textTheme.titleSmall,
            ),
          ],
        ],
      ),
    );
  }
}
