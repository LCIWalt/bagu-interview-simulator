import 'package:flutter/material.dart';

import '../../../../core/contracts/contracts.dart';
import '../../../../core/design/glass.dart';
import '../../../../core/design/tokens.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// 评分卡片（T-034）：三维分、覆盖率、要点证据、事实错误、申诉入口。
class ScoringCard extends StatelessWidget {
  const ScoringCard({required this.score, super.key, this.onAppeal});

  final TurnScore score;
  final void Function(String point)? onAppeal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return GlassPanel(
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(l10n.drillScoreTitle, style: theme.textTheme.titleMedium),
              const Spacer(),
              Text(
                l10n.drillTotal(score.total.toStringAsFixed(1)),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _scoreColor(context, score.total),
                ),
              ),
            ],
          ),
          const SizedBox(height: MockSpace.s2),
          Text(
            l10n.drillCoverage((score.coverage * 100).toStringAsFixed(0)),
            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
          ),
          const SizedBox(height: MockSpace.s3),
          Wrap(
            spacing: MockSpace.s4,
            runSpacing: MockSpace.s2,
            children: <Widget>[
              _Dimension(
                label: l10n.drillCorrectness,
                value: score.correctness,
              ),
              _Dimension(label: l10n.drillDepth, value: score.depth),
              _Dimension(label: l10n.drillStructure, value: score.structure),
            ],
          ),
          if (score.degraded) ...<Widget>[
            const SizedBox(height: MockSpace.s3),
            Text(
              l10n.drillDegraded,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            if (score.comment.isNotEmpty) ...<Widget>[
              const SizedBox(height: MockSpace.s1),
              SelectableText(
                score.comment,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            ],
          ],
          if (score.points.isNotEmpty) ...<Widget>[
            const SizedBox(height: MockSpace.s4),
            Text(l10n.bankKeyPoints, style: theme.textTheme.titleSmall),
            const SizedBox(height: MockSpace.s2),
            for (final point in score.points)
              _PointRow(
                point: point,
                onAppeal: point.verdict == 'hit' || onAppeal == null
                    ? null
                    : () => onAppeal!(point.point),
              ),
          ],
          if (score.factualErrors.isNotEmpty) ...<Widget>[
            const SizedBox(height: MockSpace.s3),
            Text(
              l10n.drillFactualErrors,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: MockSpace.s2),
            for (final error in score.factualErrors)
              Padding(
                padding: const EdgeInsets.only(bottom: MockSpace.s2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('“${error.quote}”', style: theme.textTheme.bodySmall),
                    Text(
                      error.issue,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
          ],
          if (score.factChecks.isNotEmpty) ...<Widget>[
            const SizedBox(height: MockSpace.s3),
            Text(l10n.drillFactChecks, style: theme.textTheme.titleSmall),
            const SizedBox(height: MockSpace.s2),
            for (final check in score.factChecks)
              Padding(
                padding: const EdgeInsets.only(bottom: MockSpace.s2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(check.claim, style: theme.textTheme.bodySmall),
                    Text(
                      switch (check.verdict) {
                        'contradicted' => l10n.drillFactCheckContradicted,
                        'supported' => l10n.drillFactCheckSupported,
                        _ => l10n.drillFactCheckUnknown,
                      },
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: switch (check.verdict) {
                          'contradicted' => context.tokens.danger,
                          'supported' => context.tokens.success,
                          _ => theme.hintColor,
                        },
                      ),
                    ),
                    if (check.evidence.isNotEmpty)
                      Text(
                        '${l10n.drillFactCheckEvidence}：${check.evidence}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    for (final source in check.sources)
                      Text(
                        source,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                  ],
                ),
              ),
          ],
          if (score.comment.isNotEmpty && !score.degraded) ...<Widget>[
            const SizedBox(height: MockSpace.s3),
            Text(score.comment, style: theme.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }

  Color _scoreColor(BuildContext context, double total) {
    final tokens = context.tokens;
    if (total >= 4) return tokens.success;
    if (total >= 2.5) return tokens.warning;
    return tokens.danger;
  }
}

class _Dimension extends StatelessWidget {
  const _Dimension({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor),
        ),
        Text(
          '${value.toStringAsFixed(1)} / 5',
          style: theme.textTheme.titleSmall,
        ),
      ],
    );
  }
}

class _PointRow extends StatelessWidget {
  const _PointRow({required this.point, this.onAppeal});

  final TurnScorePoint point;
  final VoidCallback? onAppeal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final (color, label) = switch (point.verdict) {
      'hit' => (context.tokens.success, l10n.drillVerdictHit),
      'partial' => (context.tokens.warning, l10n.drillVerdictPartial),
      'not_asked' => (theme.hintColor, l10n.drillVerdictNotAsked),
      _ => (context.tokens.danger, l10n.drillVerdictMiss),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: MockSpace.s2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            switch (point.verdict) {
              'hit' => Icons.check_circle_outline,
              'partial' => Icons.contrast,
              'not_asked' => Icons.remove_circle_outline,
              _ => Icons.cancel_outlined,
            },
            size: 16,
            color: color,
          ),
          const SizedBox(width: MockSpace.s2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(point.point, style: theme.textTheme.bodyMedium),
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(color: color),
                ),
                if (point.evidence.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '${l10n.drillEvidence}：${point.evidence}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (onAppeal != null)
            TextButton(
              onPressed: onAppeal,
              child: Text(l10n.drillAppeal, style: theme.textTheme.labelSmall),
            ),
        ],
      ),
    );
  }
}
