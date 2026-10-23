import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../app/providers.dart';
import '../../../core/contracts/contracts.dart';
import '../../../core/design/glass.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../l10n/generated/app_localizations.dart';

class MockReportPage extends ConsumerWidget {
  const MockReportPage({required this.sessionId, super.key});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final report = ref.watch(mockReportProvider(sessionId));
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(l10n.mockReportTitle)),
      body: AppBackdrop(
        child: report.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace stack) =>
              Center(child: Text(l10n.failureUnknown)),
          data: (SessionReport? data) {
            if (data == null) {
              return Center(child: Text(l10n.mockSessionMissing));
            }
            return ListView(
              padding: const EdgeInsets.all(MockSpace.s5),
              children: <Widget>[
                GlassPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        l10n.mockReportHeadline,
                        style: theme.textTheme.labelMedium,
                      ),
                      const SizedBox(height: MockSpace.s2),
                      Text(data.headline, style: theme.textTheme.headlineSmall),
                      if (data.sampleShortfall) ...<Widget>[
                        const SizedBox(height: MockSpace.s2),
                        Text(
                          l10n.mockReportEarly('${data.turns.length}'),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: MockSpace.s4),
                GlassPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        l10n.mockReportDimensions,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: MockSpace.s3),
                      _DimensionBar(
                        label: l10n.drillCorrectness,
                        value: data.dimensions['correctness'] ?? 0,
                      ),
                      _DimensionBar(
                        label: l10n.drillDepth,
                        value: data.dimensions['depth'] ?? 0,
                      ),
                      _DimensionBar(
                        label: l10n.drillStructure,
                        value: data.dimensions['structure'] ?? 0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: MockSpace.s4),
                GlassPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        l10n.reportWeakest,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: MockSpace.s2),
                      if (data.weakestTopics.isEmpty)
                        Text(
                          l10n.reportNoWeakness,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        )
                      else
                        Wrap(
                          spacing: MockSpace.s2,
                          runSpacing: MockSpace.s2,
                          children: <Widget>[
                            for (final topic in data.weakestTopics)
                              Chip(label: Text(topic)),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: MockSpace.s4),
                GlassPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(l10n.reportPlan, style: theme.textTheme.titleSmall),
                      const SizedBox(height: MockSpace.s2),
                      for (final item in data.sevenDayPlan)
                        Padding(
                          padding: const EdgeInsets.only(bottom: MockSpace.s1),
                          child: Text(
                            '· $item',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: MockSpace.s4),
                GlassPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        l10n.reportInterviewerView,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: MockSpace.s1),
                      Text(
                        data.interviewerView,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: MockSpace.s4),
                Row(
                  children: <Widget>[
                    Text(
                      l10n.reportTurnsTitle,
                      style: theme.textTheme.titleMedium,
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: l10n.reportExport,
                      onPressed: () => _export(context, data),
                      icon: const Icon(Icons.download_outlined),
                    ),
                    IconButton(
                      tooltip: l10n.reportDelete,
                      onPressed: () => _delete(context, ref, data),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
                const SizedBox(height: MockSpace.s2),
                const SizedBox(height: MockSpace.s4),
                if (data.turns.isEmpty)
                  GlassPanel(child: Text(l10n.mockReportNoTurns))
                else
                  for (final turn in data.turns)
                    Padding(
                      padding: const EdgeInsets.only(bottom: MockSpace.s3),
                      child: GlassPanel(
                        padding: EdgeInsets.zero,
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: MockSpace.s4,
                            vertical: MockSpace.s1,
                          ),
                          title: Text(
                            '${turn.seq}. ${turn.questionText}',
                            style: theme.textTheme.titleSmall,
                          ),
                          subtitle: turn.score == null
                              ? Text(l10n.mockReportPending)
                              : Text(
                                  '${l10n.drillTotal(turn.score!.total.toStringAsFixed(1))} · '
                                  '${l10n.drillCoverage((turn.score!.coverage * 100).toStringAsFixed(0))}',
                                ),
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                MockSpace.s4,
                                0,
                                MockSpace.s4,
                                MockSpace.s3,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    l10n.reportTurnAnswer,
                                    style: theme.textTheme.labelMedium,
                                  ),
                                  const SizedBox(height: MockSpace.s1),
                                  SelectableText(turn.answerText),
                                  if (turn.score != null) ...<Widget>[
                                    const SizedBox(height: MockSpace.s2),
                                    for (final point in turn.score!.points)
                                      Text(
                                        '[${point.verdict}] ${point.point}',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    if (turn.score!.points.any(
                                      (TurnScorePoint p) => p.verdict != 'hit',
                                    ))
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: MockSpace.s2,
                                        ),
                                        child: Text(
                                          '${l10n.reportMissedPoints}：'
                                          '${turn.score!.points.where((TurnScorePoint p) => p.verdict != 'hit').map((TurnScorePoint p) => p.point).join('、')}',
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      ),
                                    for (final error
                                        in turn.score!.factualErrors)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: MockSpace.s1,
                                        ),
                                        child: Text(
                                          '${l10n.drillFactualErrors}：${error.quote} → ${error.issue}',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: theme.colorScheme.error,
                                              ),
                                        ),
                                      ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                const SizedBox(height: MockSpace.s4),
                GlassButton(
                  label: l10n.mockReportBackHome,
                  icon: Icons.home_outlined,
                  onPressed: () => context.go('/'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

Future<void> _export(BuildContext context, SessionReport report) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final markdown = report.markdown;
  if (markdown == null) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.reportExportFailed)));
    return;
  }
  try {
    final support = await getApplicationSupportDirectory();
    final file = File(
      p.join(support.path, 'reports', '${report.sessionId}.md'),
    );
    await file.parent.create(recursive: true);
    await file.writeAsString(markdown);
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.reportExported(file.path))),
    );
  } on FileSystemException {
    messenger.showSnackBar(SnackBar(content: Text(l10n.reportExportFailed)));
  }
}

Future<void> _delete(
  BuildContext context,
  WidgetRef ref,
  SessionReport report,
) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(l10n.reportDeleteConfirm),
      content: Text(l10n.reportDeleteBody),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.commonCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.reportDelete),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  await ref.read(sessionRepositoryImplProvider).deleteSession(report.sessionId);
  ref.invalidate(recentSessionsProvider);
  if (context.mounted) context.go('/');
}

class _DimensionBar extends StatelessWidget {
  const _DimensionBar({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: MockSpace.s2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: Text(label, style: theme.textTheme.bodySmall)),
              Text(
                '${value.toStringAsFixed(1)} / 5',
                style: theme.textTheme.labelMedium,
              ),
            ],
          ),
          const SizedBox(height: 2),
          LinearProgressIndicator(value: (value / 5).clamp(0, 1)),
        ],
      ),
    );
  }
}
