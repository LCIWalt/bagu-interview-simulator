import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/design/glass.dart';
import '../../../../core/design/tokens.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/import/bank_import_service.dart' show ImportConflictPolicy;
import '../../data/import_bulk/bulk_import_service.dart';
import '../../data/remote/remote_source_importer.dart';
import '../bank_providers.dart';

/// T-023：GitHub 仓库/单文件 → 许可证校验 → 预览 → 导入。
class RemoteImportSheet extends ConsumerStatefulWidget {
  const RemoteImportSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => const RemoteImportSheet(),
    );
  }

  @override
  ConsumerState<RemoteImportSheet> createState() => _RemoteImportSheetState();
}

class _RemoteImportSheetState extends ConsumerState<RemoteImportSheet> {
  final TextEditingController _url = TextEditingController();
  RemoteImportPreview? _preview;
  ImportConflictPolicy _policy = ImportConflictPolicy.skip;
  bool _busy = false;
  String? _error;
  int? _imported;

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    final l10n = AppLocalizations.of(context);
    if (_url.text.trim().isEmpty) {
      setState(() => _error = l10n.bankRemoteHint);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _preview = null;
      _imported = null;
    });
    try {
      final preview = await ref
          .read(githubRemoteImporterProvider)
          .preview(_url.text);
      if (mounted) setState(() => _preview = preview);
    } on Object catch (error) {
      if (mounted) setState(() => _error = l10n.bankRemoteFailed('$error'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _commit() async {
    final l10n = AppLocalizations.of(context);
    final preview = _preview;
    if (preview == null || !preview.canImport) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final imported = await ref
          .read(githubRemoteImporterProvider)
          .commit(preview, policy: _policy);
      if (!mounted) return;
      ref.invalidate(bankResultsProvider);
      ref.invalidate(bankTopicTreeProvider);
      setState(() => _imported = imported);
    } on Object catch (error) {
      if (mounted) setState(() => _error = l10n.bankRemoteFailed('$error'));
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
      title: l10n.bankRemoteTitle,
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
            controller: _url,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(hintText: l10n.bankRemoteHint),
          ),
          const SizedBox(height: MockSpace.s3),
          Wrap(
            spacing: MockSpace.s3,
            runSpacing: MockSpace.s2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              GlassButton(
                label: l10n.bankRemotePreview,
                icon: Icons.cloud_download_outlined,
                busy: _busy && preview == null,
                onPressed: _busy ? null : _fetch,
              ),
              if (_busy && preview == null) Text(l10n.bankRemoteLoading),
            ],
          ),
          if (preview != null) ...<Widget>[
            const SizedBox(height: MockSpace.s3),
            Text(
              '${preview.repo.slug} · ${l10n.bankRemoteLicense(preview.license)}',
              style: theme.textTheme.titleSmall,
            ),
            Text(
              l10n.bankRemoteSummary(
                '${preview.conflicts}',
                '${preview.files.length}',
                '${preview.invalid}',
                '${preview.valid}',
              ),
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: MockSpace.s2),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  for (final file in preview.files)
                    Padding(
                      padding: const EdgeInsets.only(bottom: MockSpace.s2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(file.path, style: theme.textTheme.labelMedium),
                          Text(
                            l10n.bankImportParsed(
                              '${file.preview.conflictCount}',
                              '${file.preview.validCount}',
                            ),
                            style: theme.textTheme.labelSmall,
                          ),
                          for (final item in file.preview.items.where(
                            (BulkImportItem item) => !item.valid,
                          ))
                            Text(
                              l10n.bankBulkInvalidLine(
                                '${item.line}',
                                item.issues.isEmpty ? '?' : item.issues.first,
                              ),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: MockSpace.s2),
            Wrap(
              spacing: MockSpace.s3,
              runSpacing: MockSpace.s2,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
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
                  ],
                  selected: <ImportConflictPolicy>{_policy},
                  onSelectionChanged: (Set<ImportConflictPolicy> value) {
                    setState(() => _policy = value.first);
                  },
                ),
                GlassButton(
                  label: l10n.bankRemoteImport('${preview.valid}'),
                  icon: Icons.download_done_outlined,
                  busy: _busy,
                  onPressed: preview.canImport ? _commit : null,
                ),
              ],
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
          if (_imported != null) ...<Widget>[
            const SizedBox(height: MockSpace.s3),
            Text(
              l10n.bankImportResult('$_imported', '0', '0', '0', '0'),
              style: theme.textTheme.titleSmall,
            ),
          ],
        ],
      ),
    );
  }
}
