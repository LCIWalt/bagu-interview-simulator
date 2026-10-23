import 'package:flutter/material.dart';

import '../../../core/contracts/contracts.dart';
import '../../../core/design/glass.dart';
import '../../../core/design/tokens.dart';
import '../../../l10n/generated/app_localizations.dart';

String roleLabel(AppLocalizations l10n, String role) => switch (role) {
  'backend' => l10n.bankRoleBackend,
  'frontend' => l10n.bankRoleFrontend,
  'algorithm' => l10n.bankRoleAlgorithm,
  'mobile' => l10n.bankRoleMobile,
  _ => role,
};

String statusLabel(AppLocalizations l10n, QuestionStatus status) =>
    switch (status) {
      QuestionStatus.verified => l10n.bankStatusVerified,
      QuestionStatus.community => l10n.bankStatusCommunity,
      QuestionStatus.aiDraft => l10n.bankStatusAiDraft,
      QuestionStatus.user => l10n.bankStatusUser,
      QuestionStatus.orphaned => l10n.bankStatusOrphaned,
    };

Color statusColor(BuildContext context, QuestionStatus status) {
  final tokens = context.tokens;
  return switch (status) {
    QuestionStatus.verified => tokens.success,
    QuestionStatus.community => tokens.info,
    QuestionStatus.aiDraft => tokens.warning,
    QuestionStatus.user => Theme.of(context).colorScheme.primary,
    QuestionStatus.orphaned => tokens.danger,
  };
}

class QuestionListCard extends StatelessWidget {
  const QuestionListCard({
    required this.question,
    required this.onTap,
    super.key,
  });

  final Question question;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return RepaintBoundary(
      child: GlassPanel(
        onTap: onTap,
        semanticLabel: question.title,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Text(
                    question.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: MockSpace.s2),
                _Badge(
                  text: statusLabel(l10n, question.status),
                  color: statusColor(context, question.status),
                ),
              ],
            ),
            const SizedBox(height: MockSpace.s3),
            Wrap(
              spacing: MockSpace.s2,
              runSpacing: MockSpace.s1,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                _MetaChip(
                  label: roleLabel(l10n, question.role),
                  icon: Icons.work_outline,
                ),
                _MetaChip(
                  label: l10n.bankDifficulty('${question.difficulty}'),
                  icon: Icons.speed_outlined,
                ),
                for (final topic in question.topics.take(3))
                  _MetaChip(label: topic, icon: Icons.tag),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MockSpace.s2,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(MockRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 13, color: theme.hintColor),
        const SizedBox(width: 3),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor),
        ),
      ],
    );
  }
}
