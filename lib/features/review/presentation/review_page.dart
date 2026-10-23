import 'package:drift/drift.dart' show OrderClauseGenerator, OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/providers.dart';
import '../../../core/db/app_database.dart';
import '../../../core/design/glass.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../interview/domain/turn_score_codec.dart';
import '../domain/review_stats.dart';

class ReviewSession {
  const ReviewSession({
    required this.row,
    required this.turns,
    this.averageScore,
  });

  final SessionRow row;
  final List<TurnRow> turns;
  final double? averageScore;

  bool get isMock => row.mode == 'mock';
  bool get isActive => row.status == 'active';
}

final FutureProvider<List<ReviewSession>> reviewSessionsProvider =
    FutureProvider<List<ReviewSession>>((Ref ref) async {
      final db = ref.watch(databaseProvider);
      final rows =
          await (db.select(db.sessions)
                ..orderBy(<OrderClauseGenerator<$SessionsTable>>[
                  ($SessionsTable t) => OrderingTerm.desc(t.startedAt),
                ])
                ..limit(100))
              .get();
      final sessions = <ReviewSession>[];
      for (final row in rows) {
        final turns =
            await (db.select(db.turns)
                  ..where((Turns t) => t.sessionId.equals(row.id))
                  ..orderBy(<OrderClauseGenerator<$TurnsTable>>[
                    ($TurnsTable t) => OrderingTerm.asc(t.seq),
                  ]))
                .get();
        final scores = turns
            .map(
              (TurnRow turn) => turn.scoreJson == null
                  ? null
                  : TurnScoreCodec.decode(turn.scoreJson!),
            )
            .whereType<Object>()
            .toList();
        final values = scores
            .map((Object score) => (score as dynamic).total as double)
            .toList(growable: false);
        sessions.add(
          ReviewSession(
            row: row,
            turns: turns,
            averageScore: values.isEmpty
                ? null
                : values.reduce((double a, double b) => a + b) / values.length,
          ),
        );
      }
      return sessions;
    });

final FutureProvider<ReviewStats> reviewStatsProvider =
    FutureProvider<ReviewStats>((Ref ref) async {
      return ReviewStatsBuilder(ref.watch(databaseProvider)).build();
    });

class ReviewPage extends ConsumerWidget {
  const ReviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final sessions = ref.watch(reviewSessionsProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(l10n.reviewTitle)),
      body: AppBackdrop(
        child: sessions.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace stack) =>
              Center(child: Text(l10n.failureUnknown)),
          data: (List<ReviewSession> data) {
            if (data.isEmpty) {
              return _EmptyReview(text: l10n.reviewEmpty);
            }
            final finished = data
                .where((ReviewSession s) => !s.isActive)
                .toList();
            final scored = finished
                .map((ReviewSession s) => s.averageScore)
                .whereType<double>()
                .toList();
            final average = scored.isEmpty
                ? null
                : scored.reduce((double a, double b) => a + b) / scored.length;
            return ListView(
              padding: const EdgeInsets.all(MockSpace.s5),
              children: <Widget>[
                GlassPanel(
                  child: Text(
                    l10n.reviewSummary(
                      '${data.length}',
                      '${finished.length}',
                      average == null ? '—' : average.toStringAsFixed(1),
                    ),
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                const SizedBox(height: MockSpace.s4),
                const _StatsSection(),
                const SizedBox(height: MockSpace.s4),
                for (final session in data)
                  Padding(
                    padding: const EdgeInsets.only(bottom: MockSpace.s3),
                    child: _SessionCard(session: session),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});

  final ReviewSession session;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final score = session.averageScore;
    final status = session.isActive
        ? (session.row.mode == 'mock'
              ? l10n.reviewResume
              : l10n.reviewStatusActive)
        : l10n.reviewStatusFinished;
    return GlassPanel(
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(MockRadius.md),
        onTap: () => _open(context),
        child: Padding(
          padding: const EdgeInsets.all(MockSpace.s4),
          child: Row(
            children: <Widget>[
              Icon(
                session.isMock
                    ? Icons.timer_outlined
                    : Icons.play_circle_outline,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: MockSpace.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${session.isMock ? l10n.reviewModeMock : l10n.reviewModeDrill} · '
                      '${DateFormat.yMMMd().add_Hm().format(session.row.startedAt.toLocal())}',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: MockSpace.s1),
                    Text(
                      '${l10n.reviewTurns('${session.turns.length}')} · '
                      '${score == null ? l10n.reviewNoScore : l10n.reviewScore(score.toStringAsFixed(1))}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
              Chip(
                visualDensity: VisualDensity.compact,
                label: Text(status, style: theme.textTheme.labelSmall),
              ),
              const Icon(Icons.chevron_right, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context) {
    if (session.isMock) {
      context.push(
        session.isActive
            ? '/mock/live/${session.row.id}'
            : '/mock/report/${session.row.id}',
      );
      return;
    }
    if (session.turns.isEmpty) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(l10n.reviewNoTurns),
            action: SnackBarAction(
              label: l10n.reviewStartDrill,
              onPressed: () => context.go('/drill'),
            ),
          ),
        );
      return;
    }
    if (!session.isActive) {
      // 练习也走六段式整场报告；进行中的练习仍看逐题面板。
      context.push('/mock/report/${session.row.id}');
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => _DrillReviewSheet(session: session),
    );
  }
}

class _DrillReviewSheet extends StatelessWidget {
  const _DrillReviewSheet({required this.session});

  final ReviewSession session;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return GlassSheet(
      title: l10n.reviewTitle,
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonClose),
        ),
      ],
      child: session.turns.isEmpty
          ? Text(l10n.reviewNoTurns)
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                for (final turn in session.turns)
                  Padding(
                    padding: const EdgeInsets.only(bottom: MockSpace.s3),
                    child: GlassPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '${turn.seq}. ${turn.questionText}',
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: MockSpace.s2),
                          Text(
                            turn.answerText,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: MockSpace.s2),
                          Text(
                            turn.scoreJson == null
                                ? l10n.reviewNoScore
                                : l10n.reviewScore(
                                    TurnScoreCodec.decode(turn.scoreJson!)!
                                        .total
                                        .toStringAsFixed(1),
                                  ),
                            style: theme.textTheme.labelMedium,
                          ),
                          if (turn.questionId != null)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  context.push('/bank/${turn.questionId}');
                                },
                                child: Text(l10n.reviewGoBank),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _EmptyReview extends StatelessWidget {
  const _EmptyReview({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(MockSpace.s6),
        child: GlassPanel(child: Text(text, textAlign: TextAlign.center)),
      ),
    );
  }
}

class _StatsSection extends ConsumerWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final stats = ref.watch(reviewStatsProvider);
    return stats.when(
      loading: () => const SizedBox.shrink(),
      error: (Object error, StackTrace stack) => const SizedBox.shrink(),
      data: (ReviewStats data) {
        if (data.trend.isEmpty && data.topics.isEmpty) {
          return GlassPanel(
            child: Text(
              l10n.reviewNoStats,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
          );
        }
        return GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    l10n.reviewTrendTitle,
                    style: theme.textTheme.titleSmall,
                  ),
                  const Spacer(),
                  Text(
                    l10n.reviewTrendHint('${data.trend.length}'),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: MockSpace.s2),
              if (data.trend.isNotEmpty)
                SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _TrendPainter(
                      points: data.trend,
                      color: theme.colorScheme.primary,
                      gridColor: theme.colorScheme.outlineVariant,
                    ),
                  ),
                ),
              if (data.topics.isNotEmpty) ...<Widget>[
                const SizedBox(height: MockSpace.s4),
                Text(
                  l10n.reviewMasteryTitle,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: MockSpace.s2),
                for (final topic in data.topics.take(8))
                  Padding(
                    padding: const EdgeInsets.only(bottom: MockSpace.s2),
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 110,
                          child: Text(
                            topic.topic,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: topic.rate.clamp(0, 1),
                              minHeight: 8,
                              color: topic.rate < 0.6
                                  ? theme.colorScheme.error
                                  : topic.rate < 0.8
                                  ? theme.colorScheme.tertiary
                                  : theme.colorScheme.primary,
                              backgroundColor:
                                  theme.colorScheme.surfaceContainerHighest,
                            ),
                          ),
                        ),
                        const SizedBox(width: MockSpace.s2),
                        SizedBox(
                          width: 42,
                          child: Text(
                            l10n.reviewMasteryPercent(
                              '${(topic.rate * 100).round()}',
                            ),
                            textAlign: TextAlign.right,
                            style: theme.textTheme.labelSmall,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({
    required this.points,
    required this.color,
    required this.gridColor,
  });

  final List<TrendPoint> points;
  final Color color;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    const padding = 8.0;
    final chart = Rect.fromLTWH(
      padding,
      padding,
      size.width - padding * 2,
      size.height - padding * 2,
    );
    final grid = Paint()
      ..color = gridColor.withValues(alpha: 0.4)
      ..strokeWidth = 1;
    for (var i = 0; i <= 2; i++) {
      final y = chart.top + chart.height * i / 2;
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), grid);
    }
    if (points.isEmpty) return;
    final step = points.length == 1 ? 0.0 : chart.width / (points.length - 1);
    final path = Path();
    final dots = <Offset>[];
    for (var i = 0; i < points.length; i++) {
      final x = chart.left + step * i;
      final y = chart.bottom - chart.height * (points[i].score.clamp(0, 5) / 5);
      final offset = Offset(x, y);
      dots.add(offset);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    for (final dot in dots) {
      canvas.drawCircle(dot, 3, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_TrendPainter oldDelegate) =>
      oldDelegate.points.length != points.length ||
      oldDelegate.points.lastOrNull?.score != points.lastOrNull?.score ||
      oldDelegate.color != color;
}
