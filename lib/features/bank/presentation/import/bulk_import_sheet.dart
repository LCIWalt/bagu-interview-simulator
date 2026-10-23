import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/design/glass.dart';
import '../../../../core/design/tokens.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/import/bank_import_service.dart' show ImportConflictPolicy;
import '../../data/import_bulk/bulk_import_service.dart';
import '../bank_providers.dart';

/// T-021：批量粘贴 YAML/JSON/CSV/Markdown → 逐行预览 → 原子导入。
class BulkImportSheet extends ConsumerStatefulWidget {
  const BulkImportSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => const BulkImportSheet(),
    );
  }

  @override
  ConsumerState<BulkImportSheet> createState() => _BulkImportSheetState();
}

class _BulkImportSheetState extends ConsumerState<BulkImportSheet> {
  final TextEditingController _content = TextEditingController();
  BulkImportPreview? _preview;
  BulkImportOutcome? _outcome;
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
          .read(bulkImportServiceProvider)
          .preview(_content.text);
      if (!mounted) return;
      setState(() => _preview = preview);
    } on Object catch (error) {
      if (mounted) setState(() => _error = '$error');
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
    if (!preview.canImport) {
      setState(() => _error = l10n.bankBulkNeedValid);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final outcome = await ref
          .read(bulkImportServiceProvider)
          .commit(preview, policy: _policy);
      if (!mounted) return;
      ref.invalidate(bankResultsProvider);
      ref.invalidate(bankTopicTreeProvider);
      setState(() => _outcome = outcome);
    } on Object catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final preview = _preview;
    return GlassSheet(
      title: l10n.bankBulkImportTitle,
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
            minLines: 6,
            maxLines: 14,
            style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
            decoration: InputDecoration(
              hintText: l10n.bankBulkImportHint,
              hintMaxLines: 4,
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
                busy: _busy && preview == null,
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
          if (preview != null) ...<Widget>[
            const SizedBox(height: MockSpace.s3),
            Text(
              l10n.bankBulkSummary(
                '${preview.conflictCount}',
                '${preview.invalidCount}',
                '${preview.items.length}',
                '${preview.validCount}',
              ),
              style: theme.textTheme.bodySmall,
            ),
            Text(
              l10n.bankBulkFormat(preview.format.name.toUpperCase()),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: MockSpace.s2),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: preview.items.length,
                itemBuilder: (BuildContext context, int index) {
                  final item = preview.items[index];
                  final firstIssue = item.issues.isEmpty
                      ? null
                      : item.issues.first;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: MockSpace.s2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                item.question?.title ?? '—',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (firstIssue != null)
                                Text(
                                  l10n.bankBulkInvalidLine(
                                    '${item.line}',
                                    firstIssue,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (item.hasConflict)
                          Text(
                            l10n.bankImportConflictLabel,
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
              label: l10n.bankBulkCommit('${preview.validCount}'),
              icon: Icons.upload_file_outlined,
              busy: _busy,
              onPressed: preview.canImport && preview.validCount > 0
                  ? _commit
                  : null,
            ),
            if (!preview.canImport)
              Padding(
                padding: const EdgeInsets.only(top: MockSpace.s2),
                child: Text(
                  l10n.bankBulkNeedValid,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
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
