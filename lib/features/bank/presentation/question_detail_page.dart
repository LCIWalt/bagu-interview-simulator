import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/providers.dart';
import '../../../core/contracts/contracts.dart';
import '../../../core/db/app_database.dart';
import '../../../core/design/glass.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'bank_providers.dart';
import 'bank_widgets.dart';

class QuestionDetailPage extends ConsumerWidget {
  const QuestionDetailPage({required this.questionId, super.key});

  final String questionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final question = ref.watch(questionDetailProvider(questionId));
    final local = ref.watch(questionLocalProvider(questionId));
    final history = ref.watch(questionHistoryProvider(questionId));
    final starred = local.valueOrNull?.starred ?? false;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.bankDetailTitle),
        actions: <Widget>[
          IconButton(
            tooltip: starred ? l10n.bankUnstar : l10n.bankStar,
            onPressed: () async {
              await ref
                  .read(questionLocalRepositoryProvider)
                  .setStarred(questionId, !starred);
              ref.invalidate(questionLocalProvider(questionId));
            },
            icon: Icon(starred ? Icons.star : Icons.star_border),
          ),
        ],
      ),
      body: AppBackdrop(
        child: question.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace stack) =>
              Center(child: Text(l10n.failureUnknown)),
          data: (Question? q) {
            if (q == null) {
              return Center(child: Text(l10n.bankNoResults));
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(
                MockSpace.s5,
                MockSpace.s2,
                MockSpace.s5,
                MockSpace.s7,
              ),
              children: <Widget>[
                _QuestionHeader(question: q),
                const SizedBox(height: MockSpace.s4),
                _AnswerSectionBody(question: q),
                const SizedBox(height: MockSpace.s4),
                if (q.source != null) _SourceSection(source: q.source!),
                const SizedBox(height: MockSpace.s4),
                _NotesEditor(
                  questionId: q.id,
                  initialNote: local.valueOrNull?.noteMd ?? '',
                ),
                const SizedBox(height: MockSpace.s4),
                _RelatedSection(questionId: q.id),
                const SizedBox(height: MockSpace.s4),
                _HistorySection(history: history),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _QuestionHeader extends StatelessWidget {
  const _QuestionHeader({required this.question});

  final Question question;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  question.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: MockSpace.s2),
              Text(
                statusLabel(l10n, question.status),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: statusColor(context, question.status),
                ),
              ),
            ],
          ),
          const SizedBox(height: MockSpace.s2),
          Wrap(
            spacing: MockSpace.s3,
            runSpacing: MockSpace.s1,
            children: <Widget>[
              Text(
                roleLabel(l10n, question.role),
                style: theme.textTheme.labelMedium,
              ),
              Text(
                l10n.bankDifficulty('${question.difficulty}'),
                style: theme.textTheme.labelMedium,
              ),
              for (final topic in question.topics)
                Text(
                  '#$topic',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
            ],
          ),
          if (question.bodyMarkdown.trim().isNotEmpty &&
              question.bodyMarkdown.trim() !=
                  question.title.trim()) ...<Widget>[
            const SizedBox(height: MockSpace.s3),
            SelectableText(
              question.bodyMarkdown,
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ],
      ),
    );
  }
}

class _AnswerSectionBody extends StatefulWidget {
  const _AnswerSectionBody({required this.question});

  final Question question;

  @override
  State<_AnswerSectionBody> createState() => _AnswerSectionBodyState();
}

class _AnswerSectionBodyState extends State<_AnswerSectionBody> {
  bool _revealed = false;
  final TextEditingController _draft = TextEditingController();

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final answer = widget.question.answer;
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(l10n.bankAnswerSummary, style: theme.textTheme.titleMedium),
          const SizedBox(height: MockSpace.s2),
          if (!_revealed) ...<Widget>[
            Text(
              l10n.bankAnswerHiddenHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: MockSpace.s3),
            TextField(
              controller: _draft,
              minLines: 3,
              maxLines: 8,
              decoration: InputDecoration(
                labelText: l10n.bankYourAnswer,
                hintText: l10n.bankYourAnswerHint,
              ),
            ),
            const SizedBox(height: MockSpace.s3),
            GlassButton(
              label: l10n.bankRevealAnswer,
              icon: Icons.visibility_outlined,
              onPressed: () => setState(() => _revealed = true),
            ),
          ] else ...<Widget>[
            SelectableText(answer.summary, style: theme.textTheme.bodyLarge),
            const SizedBox(height: MockSpace.s4),
            Text(l10n.bankKeyPoints, style: theme.textTheme.titleSmall),
            const SizedBox(height: MockSpace.s2),
            for (var i = 0; i < answer.keyPoints.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: MockSpace.s2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('${i + 1}. ', style: theme.textTheme.bodyMedium),
                    Expanded(child: Text(answer.keyPoints[i])),
                  ],
                ),
              ),
            if (answer.pitfalls.isNotEmpty) ...<Widget>[
              const SizedBox(height: MockSpace.s2),
              Text(l10n.bankPitfalls, style: theme.textTheme.titleSmall),
              const SizedBox(height: MockSpace.s1),
              for (final pitfall in answer.pitfalls)
                Text('· $pitfall', style: theme.textTheme.bodyMedium),
            ],
            if (widget.question.followups.isNotEmpty) ...<Widget>[
              const SizedBox(height: MockSpace.s3),
              Text(l10n.bankFollowups, style: theme.textTheme.titleSmall),
              const SizedBox(height: MockSpace.s1),
              for (final followup in widget.question.followups)
                Text('· $followup', style: theme.textTheme.bodyMedium),
            ],
          ],
        ],
      ),
    );
  }
}

class _SourceSection extends StatelessWidget {
  const _SourceSection({required this.source});

  final QuestionSource source;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(l10n.bankSource, style: theme.textTheme.titleSmall),
          const SizedBox(height: MockSpace.s2),
          SelectableText(source.url, style: theme.textTheme.bodySmall),
          const SizedBox(height: MockSpace.s1),
          Text(
            l10n.bankSourceLicense(source.license),
            style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor),
          ),
        ],
      ),
    );
  }
}

class _NotesEditor extends ConsumerStatefulWidget {
  const _NotesEditor({required this.questionId, required this.initialNote});

  final String questionId;
  final String initialNote;

  @override
  ConsumerState<_NotesEditor> createState() => _NotesEditorState();
}

class _NotesEditorState extends ConsumerState<_NotesEditor> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialNote,
  );
  Timer? _timer;
  bool _saved = false;

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _timer?.cancel();
    setState(() => _saved = false);
    _timer = Timer(const Duration(milliseconds: 500), () async {
      await ref
          .read(questionLocalRepositoryProvider)
          .saveNote(widget.questionId, value);
      if (mounted) setState(() => _saved = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(l10n.bankNotes, style: theme.textTheme.titleSmall),
              const SizedBox(width: MockSpace.s2),
              if (_saved)
                Text(
                  l10n.bankNotesSaved,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: context.tokens.success,
                  ),
                ),
            ],
          ),
          const SizedBox(height: MockSpace.s2),
          TextField(
            controller: _controller,
            minLines: 4,
            maxLines: 10,
            decoration: InputDecoration(hintText: l10n.bankNotesHint),
            onChanged: _onChanged,
          ),
        ],
      ),
    );
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection({required this.history});

  final AsyncValue<List<TurnRow>> history;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(l10n.bankHistory, style: theme.textTheme.titleSmall),
          const SizedBox(height: MockSpace.s2),
          history.when(
            loading: () => const LinearProgressIndicator(),
            error: (Object error, StackTrace stack) =>
                Text(l10n.failureUnknown),
            data: (List<TurnRow> turns) {
              if (turns.isEmpty) {
                return Text(
                  l10n.bankHistoryEmpty,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                );
              }
              return Column(
                children: <Widget>[
                  for (final turn in turns)
                    Padding(
                      padding: const EdgeInsets.only(bottom: MockSpace.s3),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            DateFormat.Md().add_Hm().format(
                              turn.tSubmittedAt.toLocal(),
                            ),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                          const SizedBox(width: MockSpace.s3),
                          Expanded(
                            child: Text(
                              turn.answerText,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RelatedSection extends ConsumerWidget {
  const _RelatedSection({required this.questionId});

  final String questionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final related = ref.watch(relatedQuestionsProvider(questionId));
    return GlassPanel(
      child: related.when(
        loading: () =>
            const SizedBox(height: 24, child: LinearProgressIndicator()),
        error: (Object error, StackTrace stack) => Text(l10n.failureUnknown),
        data: (List<Question> questions) {
          if (questions.isEmpty) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                l10n.bankRelatedTitle,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: MockSpace.s2),
              for (final question in questions)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    question.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () => context.push('/bank/${question.id}'),
                ),
            ],
          );
        },
      ),
    );
  }
}
