import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/design/glass.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/bank_repository_impl.dart' show TopicCount;
import 'bank_providers.dart';
import 'bank_widgets.dart';
import 'import/bank_import_sheet.dart';
import 'import/bulk_import_sheet.dart';
import 'import/experience_import_sheet.dart';
import 'import/remote_import_sheet.dart';
import 'update/bank_update_sheet.dart';

class BankPage extends ConsumerStatefulWidget {
  const BankPage({super.key});

  @override
  ConsumerState<BankPage> createState() => _BankPageState();
}

class _BankPageState extends ConsumerState<BankPage> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _showTopicTree(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => const _TopicTreeSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final query = ref.watch(bankQueryProvider);
    final seed = ref.watch(seedBankProvider);
    final results = ref.watch(bankResultsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.bankTitle),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.bankNewQuestion,
            onPressed: () => context.push('/bank/new'),
            icon: const Icon(Icons.add),
          ),
          IconButton(
            tooltip: l10n.bankTopicsTitle,
            onPressed: () => _showTopicTree(context),
            icon: const Icon(Icons.account_tree_outlined),
          ),
          PopupMenuButton<String>(
            tooltip: l10n.bankImportTitle,
            icon: const Icon(Icons.upload_file_outlined),
            onSelected: (String value) {
              if (value == 'single') {
                BankImportSheet.show(context);
              } else if (value == 'bulk') {
                BulkImportSheet.show(context);
              } else if (value == 'remote') {
                RemoteImportSheet.show(context);
              } else {
                ExperienceImportSheet.show(context);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'single',
                child: Text(l10n.bankImportTitle),
              ),
              PopupMenuItem<String>(
                value: 'bulk',
                child: Text(l10n.bankBulkImportTitle),
              ),
              PopupMenuItem<String>(
                value: 'remote',
                child: Text(l10n.bankRemoteTitle),
              ),
              PopupMenuItem<String>(
                value: 'experience',
                child: Text(l10n.bankExperienceTitle),
              ),
            ],
          ),
          IconButton(
            tooltip: l10n.bankUpdateTitle,
            onPressed: () => BankUpdateSheet.show(context),
            icon: const Icon(Icons.cloud_download_outlined),
          ),
          IconButton(
            tooltip: l10n.bankRetry,
            onPressed: () {
              ref.invalidate(seedBankProvider);
              ref.invalidate(bankResultsProvider);
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: AppBackdrop(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                MockSpace.s5,
                MockSpace.s2,
                MockSpace.s5,
                MockSpace.s2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextField(
                    controller: _search,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: l10n.bankSearchHint,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: query.text.isEmpty && _search.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: l10n.bankClearFilters,
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                _search.clear();
                                ref
                                    .read(bankQueryProvider.notifier)
                                    .clearFilters();
                              },
                            ),
                    ),
                    onChanged: ref.read(bankQueryProvider.notifier).search,
                  ),
                  const SizedBox(height: MockSpace.s3),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: <Widget>[
                        for (final String role in <String>[
                          '',
                          'backend',
                          'frontend',
                          'algorithm',
                          'mobile',
                        ])
                          Padding(
                            padding: const EdgeInsets.only(right: MockSpace.s2),
                            child: ChoiceChip(
                              label: Text(
                                role.isEmpty
                                    ? l10n.bankFilterAll
                                    : roleLabel(l10n, role),
                              ),
                              selected: (query.role ?? '') == role,
                              onSelected: (_) => ref
                                  .read(bankQueryProvider.notifier)
                                  .setRole(role.isEmpty ? null : role),
                            ),
                          ),
                        const SizedBox(width: MockSpace.s3),
                        if (query.topic != null)
                          Padding(
                            padding: const EdgeInsets.only(right: MockSpace.s2),
                            child: InputChip(
                              label: Text(l10n.bankTopicSelected(query.topic!)),
                              onDeleted: () => ref
                                  .read(bankQueryProvider.notifier)
                                  .setTopic(null),
                            ),
                          ),
                        for (var level = 0; level <= 5; level++)
                          Padding(
                            padding: const EdgeInsets.only(right: MockSpace.s2),
                            child: ChoiceChip(
                              label: Text(
                                level == 0
                                    ? l10n.bankAllDifficulties
                                    : l10n.bankDifficulty('$level'),
                              ),
                              selected: (query.difficulty ?? 0) == level,
                              onSelected: (_) => ref
                                  .read(bankQueryProvider.notifier)
                                  .setDifficulty(level == 0 ? null : level),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (results.isLoading && results.hasValue)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: MockSpace.s5),
                child: LinearProgressIndicator(minHeight: 2),
              ),
            Expanded(
              child: seed.when(
                loading: () => _CenteredHint(
                  icon: Icons.inventory_2_outlined,
                  text: l10n.bankSeedInstalling,
                  busy: true,
                ),
                error: (Object error, StackTrace stack) => _CenteredHint(
                  icon: Icons.error_outline,
                  text: l10n.failureUnknown,
                  action: GlassButton(
                    label: l10n.bankRetry,
                    icon: Icons.refresh,
                    onPressed: () => ref.invalidate(seedBankProvider),
                  ),
                ),
                data: (_) => results.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (Object error, StackTrace stack) => _CenteredHint(
                    icon: Icons.cloud_off_outlined,
                    text: l10n.failureUnknown,
                    action: GlassButton(
                      label: l10n.bankRetry,
                      icon: Icons.refresh,
                      onPressed: () =>
                          ref.read(bankResultsProvider.notifier).retry(),
                    ),
                  ),
                  data: (BankResults data) {
                    if (data.questions.isEmpty) {
                      return _CenteredHint(
                        icon: Icons.search_off,
                        text: l10n.bankNoResults,
                        subtitle: l10n.bankNoResultsHint,
                        action: GlassButton(
                          label: l10n.bankClearFilters,
                          icon: Icons.filter_alt_off_outlined,
                          onPressed: () {
                            _search.clear();
                            ref.read(bankQueryProvider.notifier).clearFilters();
                          },
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        MockSpace.s5,
                        MockSpace.s2,
                        MockSpace.s5,
                        MockSpace.s6,
                      ),
                      itemCount: data.questions.length + 1,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == data.questions.length) {
                          return _Footer(
                            data: data,
                            onLoadMore: () => ref
                                .read(bankResultsProvider.notifier)
                                .loadMore(),
                          );
                        }
                        final question = data.questions[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: MockSpace.s3),
                          child: QuestionListCard(
                            question: question,
                            onTap: () => context.push('/bank/${question.id}'),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            if (results.hasValue && results.value!.questions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: MockSpace.s5),
                child: Text(
                  l10n.bankQuestionCount('${results.value!.questions.length}'),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ),
            const SizedBox(height: MockSpace.s2),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.data, required this.onLoadMore});

  final BankResults data;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (!data.hasMore) return const SizedBox(height: MockSpace.s4);
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: MockSpace.s2),
      child: Center(
        child: GlassButton(
          label: l10n.bankLoadMore,
          primary: false,
          busy: data.loadingMore,
          onPressed: onLoadMore,
        ),
      ),
    );
  }
}

class _CenteredHint extends StatelessWidget {
  const _CenteredHint({
    required this.icon,
    required this.text,
    this.subtitle,
    this.action,
    this.busy = false,
  });

  final IconData icon;
  final String text;
  final String? subtitle;
  final Widget? action;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(MockSpace.s5),
        child: GlassPanel(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (busy)
                const CircularProgressIndicator()
              else
                Icon(icon, size: 36, color: theme.colorScheme.primary),
              const SizedBox(height: MockSpace.s3),
              Text(
                text,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              if (subtitle != null) ...<Widget>[
                const SizedBox(height: MockSpace.s1),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ],
              if (action != null) ...<Widget>[
                const SizedBox(height: MockSpace.s4),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicTreeSheet extends ConsumerWidget {
  const _TopicTreeSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final topicTree = ref.watch(bankTopicTreeProvider);
    return GlassSheet(
      title: l10n.bankTopicsTitle,
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonClose),
        ),
      ],
      child: topicTree.when(
        loading: () => const LinearProgressIndicator(),
        error: (Object error, StackTrace stack) => Text(l10n.failureUnknown),
        data: (Map<String, List<TopicCount>> tree) {
          if (tree.isEmpty) return Text(l10n.bankNoResults);
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  ref.read(bankQueryProvider.notifier).setTopic(null);
                  Navigator.of(context).pop();
                },
                child: Text(l10n.bankAllTopics),
              ),
              for (final entry in tree.entries)
                ExpansionTile(
                  title: Text(roleLabel(l10n, entry.key)),
                  initiallyExpanded: entry.key == 'backend',
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        MockSpace.s4,
                        0,
                        MockSpace.s4,
                        MockSpace.s3,
                      ),
                      child: Wrap(
                        spacing: MockSpace.s2,
                        runSpacing: MockSpace.s2,
                        children: <Widget>[
                          for (final topic in entry.value)
                            ActionChip(
                              label: Text('${topic.topic} · ${topic.count}'),
                              onPressed: () {
                                ref
                                    .read(bankQueryProvider.notifier)
                                    .setTopic(topic.topic);
                                Navigator.of(context).pop();
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}
