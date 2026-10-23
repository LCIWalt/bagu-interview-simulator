import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../app/providers.dart';
import '../../../core/design/glass.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/settings/provider_config.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../bank/data/search/hybrid_search.dart';
import 'provider_card.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final configs = ref.watch(providerConfigsProvider);
    final prefs = ref.watch(preferencesProvider).valueOrNull;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.settingsDesignDemo,
            onPressed: () => context.push('/design'),
            icon: const Icon(Icons.palette_outlined),
          ),
        ],
      ),
      body: AppBackdrop(
        child: ListView(
          padding: const EdgeInsets.all(MockSpace.s5),
          children: <Widget>[
            Text(
              l10n.settingsProviderSection,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: MockSpace.s2),
            Text(
              l10n.settingsProviderHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: MockSpace.s3),
            configs.when(
              data: (List<ProviderConfig> list) => Column(
                children: <Widget>[
                  for (final config in list.where(
                    (ProviderConfig c) =>
                        c.role == ProviderRole.interviewer ||
                        c.role == ProviderRole.scorer ||
                        c.role == ProviderRole.search ||
                        c.role == ProviderRole.tts,
                  ))
                    Padding(
                      padding: const EdgeInsets.only(bottom: MockSpace.s3),
                      child: ProviderCard(
                        key: ValueKey<String>(config.role.name),
                        config: config,
                        label: switch (config.role) {
                          ProviderRole.interviewer =>
                            l10n.settingsRoleInterviewer,
                          ProviderRole.scorer => l10n.settingsRoleScorer,
                          ProviderRole.search => l10n.settingsRoleSearch,
                          ProviderRole.tts => l10n.settingsRoleTts,
                          _ => config.role.name,
                        },
                      ),
                    ),
                ],
              ),
              loading: () => const Padding(
                padding: EdgeInsets.all(MockSpace.s5),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (Object error, StackTrace stack) =>
                  GlassPanel(child: Text(l10n.failureUnknown)),
            ),
            const SizedBox(height: MockSpace.s5),
            Text(l10n.settingsAppearance, style: theme.textTheme.titleMedium),
            const SizedBox(height: MockSpace.s2),
            GlassPanel(
              child: SegmentedButton<ThemeMode>(
                segments: <ButtonSegment<ThemeMode>>[
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.system,
                    label: Text(l10n.settingsThemeSystem),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.light,
                    label: Text(l10n.settingsThemeLight),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.dark,
                    label: Text(l10n.settingsThemeDark),
                  ),
                ],
                selected: <ThemeMode>{prefs?.themeMode ?? ThemeMode.system},
                onSelectionChanged: (Set<ThemeMode> value) {
                  ref
                      .read(preferencesProvider.notifier)
                      .setThemeMode(value.first);
                },
              ),
            ),
            const SizedBox(height: MockSpace.s4),
            Text(l10n.settingsLanguage, style: theme.textTheme.titleMedium),
            const SizedBox(height: MockSpace.s2),
            GlassPanel(
              child: SegmentedButton<String>(
                segments: <ButtonSegment<String>>[
                  ButtonSegment<String>(
                    value: '',
                    label: Text(l10n.settingsLanguageSystem),
                  ),
                  ButtonSegment<String>(
                    value: 'zh',
                    label: Text(l10n.settingsLanguageZh),
                  ),
                  ButtonSegment<String>(
                    value: 'en',
                    label: Text(l10n.settingsLanguageEn),
                  ),
                ],
                selected: <String>{prefs?.localeCode ?? ''},
                onSelectionChanged: (Set<String> value) {
                  final code = value.first;
                  ref
                      .read(preferencesProvider.notifier)
                      .setLocale(code.isEmpty ? null : code);
                },
              ),
            ),
            const SizedBox(height: MockSpace.s5),
            Text(
              l10n.settingsSemanticSection,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: MockSpace.s2),
            const _SemanticSection(),
            const SizedBox(height: MockSpace.s5),
            Text(l10n.settingsDataSection, style: theme.textTheme.titleMedium),
            const SizedBox(height: MockSpace.s2),
            const _DataSection(),
            const SizedBox(height: MockSpace.s5),
            Text(l10n.settingsUsageSection, style: theme.textTheme.titleMedium),
            const SizedBox(height: MockSpace.s2),
            const _UsageSection(),
            const SizedBox(height: MockSpace.s5),
            Text(l10n.settingsAbout, style: theme.textTheme.titleMedium),
            const SizedBox(height: MockSpace.s2),
            GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(l10n.appTagline),
                  const SizedBox(height: MockSpace.s2),
                  ref
                      .watch(appVersionProvider)
                      .when(
                        data: (String version) =>
                            Text(l10n.settingsVersion(version)),
                        loading: () => Text(l10n.commonLoading),
                        error: (Object error, StackTrace stack) =>
                            const SizedBox.shrink(),
                      ),
                  const SizedBox(height: MockSpace.s3),
                  GlassButton(
                    label: l10n.settingsDesignDemo,
                    primary: false,
                    icon: Icons.palette_outlined,
                    onPressed: () => context.push('/design'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: MockSpace.s6),
          ],
        ),
      ),
    );
  }
}

class _DataSection extends ConsumerStatefulWidget {
  const _DataSection();

  @override
  ConsumerState<_DataSection> createState() => _DataSectionState();
}

class _DataSectionState extends ConsumerState<_DataSection> {
  bool _exporting = false;

  Future<void> _exportLogs() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final logger = ref.read(loggerProvider);
    if (logger.recent.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.logExportEmpty)));
      return;
    }
    setState(() => _exporting = true);
    try {
      final dir = await getApplicationSupportDirectory();
      final stamp = DateTime.now().toUtc().toIso8601String().replaceAll(
        ':',
        '-',
      );
      final path = p.join(dir.path, 'logs', 'export-$stamp.txt');
      await logger.export(File(path));
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.logExportDone(path))));
    } on FileSystemException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.failureUnknown)));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _exportAppeals() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(appealRepositoryProvider);
    final candidates = await repo.loadAll();
    if (candidates.isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.settingsAppealsEmpty)),
      );
      return;
    }
    try {
      final dir = await getApplicationSupportDirectory();
      final path = await repo.export(dir);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.settingsAppealsExported(path))),
      );
    } on FileSystemException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.failureUnknown)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(l10n.settingsPrivacy, style: theme.textTheme.titleSmall),
          const SizedBox(height: MockSpace.s2),
          Text(l10n.settingsPrivacyBody, style: theme.textTheme.bodySmall),
          const SizedBox(height: MockSpace.s3),
          Text(
            l10n.settingsExportLogsHint,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
          ),
          const SizedBox(height: MockSpace.s3),
          GlassButton(
            label: l10n.logExport,
            primary: false,
            icon: Icons.download_outlined,
            busy: _exporting,
            onPressed: _exportLogs,
          ),
          const SizedBox(height: MockSpace.s2),
          GlassButton(
            label: l10n.settingsExportAppeals,
            primary: false,
            icon: Icons.rate_review_outlined,
            onPressed: _exportAppeals,
          ),
        ],
      ),
    );
  }
}

class _UsageSection extends ConsumerWidget {
  const _UsageSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final usage = ref.watch(usageSummaryProvider);
    return GlassPanel(
      child: usage.when(
        loading: () => const LinearProgressIndicator(),
        error: (Object error, StackTrace stack) => Text(l10n.failureUnknown),
        data: (UsageSummary data) {
          if (data.tokens == 0) {
            return Text(
              l10n.settingsUsageEmpty,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            );
          }
          return Text(l10n.settingsUsageTokens('${data.tokens}'));
        },
      ),
    );
  }
}

class _SemanticSection extends ConsumerStatefulWidget {
  const _SemanticSection();

  @override
  ConsumerState<_SemanticSection> createState() => _SemanticSectionState();
}

class _SemanticSectionState extends ConsumerState<_SemanticSection> {
  bool _busy = false;
  int? _count;
  int _indexMs = 0;
  int _done = 0;
  int _total = 0;
  String? _error;
  String? _checkResult;

  Future<void> _checkModel() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
      _checkResult = null;
    });
    try {
      final embedding = await ref.read(embeddingProvider.future);
      if (embedding == null) {
        setState(() => _error = l10n.settingsModelCheckUnavailable);
        return;
      }
      final watch = Stopwatch()..start();
      final go = await embedding.embed('Go 的 GMP 调度模型，P 提供执行上下文');
      final goroutine = await embedding.embed('goroutine 如何被 M 调度执行');
      final mysql = await embedding.embed('MySQL 的 B+ 树索引结构');
      watch.stop();
      final related = _cosine(go, goroutine);
      final unrelated = _cosine(go, mysql);
      if (mounted) {
        setState(() {
          _checkResult = l10n.settingsModelCheckResult(
            '${go.length}',
            '${watch.elapsedMilliseconds}',
            related.toStringAsFixed(3),
            unrelated.toStringAsFixed(3),
          );
        });
      }
    } on Object catch (error) {
      if (mounted) setState(() => _error = l10n.settingsIndexFailed('$error'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  double _cosine(List<double> a, List<double> b) {
    var dot = 0.0;
    var na = 0.0;
    var nb = 0.0;
    for (var i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      na += a[i] * a[i];
      nb += b[i] * b[i];
    }
    if (na == 0 || nb == 0) return 0;
    return dot / (math.sqrt(na) * math.sqrt(nb));
  }

  Future<void> _rebuild() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
      _count = null;
    });
    try {
      final embedding = await ref.read(embeddingProvider.future);
      if (embedding == null) {
        setState(() => _error = l10n.settingsIndexUnavailable);
        return;
      }
      final indexer = QuestionEmbeddingIndexer(
        repository: ref.read(bankRepositoryImplProvider),
        embedding: embedding,
      );
      final watch = Stopwatch()..start();
      final count = await indexer.rebuild(
        onProgress: (int done, int total) {
          if (mounted) {
            setState(() {
              _done = done;
              _total = total;
            });
          }
        },
      );
      watch.stop();
      if (mounted) {
        setState(() {
          _count = count;
          _indexMs = watch.elapsedMilliseconds;
        });
      }
    } on Object catch (error) {
      if (mounted) setState(() => _error = l10n.settingsIndexFailed('$error'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final prefs = ref.watch(preferencesProvider).valueOrNull;
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.settingsSemanticToggle),
            subtitle: Text(l10n.settingsSemanticHint),
            value: prefs?.semanticSearch ?? false,
            onChanged: (bool value) {
              ref.read(preferencesProvider.notifier).setSemanticSearch(value);
            },
          ),
          const SizedBox(height: MockSpace.s2),
          Wrap(
            spacing: MockSpace.s3,
            runSpacing: MockSpace.s2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              GlassButton(
                label: l10n.settingsModelCheck,
                icon: Icons.health_and_safety_outlined,
                primary: false,
                busy: _busy,
                onPressed: _busy ? null : _checkModel,
              ),
              GlassButton(
                label: l10n.settingsRebuildIndex,
                icon: Icons.memory_outlined,
                busy: _busy,
                onPressed: _busy ? null : _rebuild,
              ),
              if (_busy && _total > 0)
                Text(
                  l10n.settingsIndexing('$_done', '$_total'),
                  style: theme.textTheme.bodySmall,
                ),
              if (_count != null)
                Text(
                  l10n.settingsIndexDone('$_count', '$_indexMs'),
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ),
          if (_checkResult != null) ...<Widget>[
            const SizedBox(height: MockSpace.s2),
            Text(_checkResult!, style: theme.textTheme.bodySmall),
          ],
          if (_error != null) ...<Widget>[
            const SizedBox(height: MockSpace.s2),
            Text(
              _error!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
