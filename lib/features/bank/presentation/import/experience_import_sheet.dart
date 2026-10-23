import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/contracts/contracts.dart';
import '../../../../core/design/glass.dart';
import '../../../../core/design/tokens.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/bank_repository_impl.dart';
import '../../domain/experience_extractor.dart';
import '../bank_providers.dart';

/// T-022：面经长文 → LLM 草稿 → 人工勾选 → 入库。
class ExperienceImportSheet extends ConsumerStatefulWidget {
  const ExperienceImportSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => const ExperienceImportSheet(),
    );
  }

  @override
  ConsumerState<ExperienceImportSheet> createState() =>
      _ExperienceImportSheetState();
}

class _ExperienceImportSheetState extends ConsumerState<ExperienceImportSheet> {
  final TextEditingController _text = TextEditingController();
  List<ExtractedQuestionDraft> _drafts = const <ExtractedQuestionDraft>[];
  final Set<int> _selected = <int>{};
  bool _busy = false;
  String? _error;
  int? _saved;
  int _skipped = 0;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _extract() async {
    final l10n = AppLocalizations.of(context);
    if (_text.text.trim().isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
      _saved = null;
      _drafts = const <ExtractedQuestionDraft>[];
      _selected.clear();
    });
    try {
      final extractor = await ref.read(experienceExtractorProvider.future);
      if (extractor == null) {
        setState(() => _error = l10n.bankExperienceNeedKey);
        return;
      }
      final drafts = await extractor.extract(_text.text);
      if (!mounted) return;
      setState(() {
        _drafts = drafts;
        _selected.addAll(
          List<int>.generate(drafts.length, (int index) => index),
        );
        if (drafts.isEmpty) _error = l10n.bankExperienceEmpty;
      });
    } on Object catch (error) {
      if (mounted) setState(() => _error = l10n.bankExperienceFailed('$error'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (_selected.isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final repo = ref.read(bankRepositoryImplProvider);
      final questions = <Question>[];
      var skipped = 0;
      for (final index in _selected) {
        final question = _drafts[index].toQuestion();
        if (await repo.byId(question.id) != null) {
          skipped++;
          continue;
        }
        questions.add(question);
      }
      if (questions.isNotEmpty) {
        await repo.importBatch(questions, origin: 'experience');
      }
      if (!mounted) return;
      ref.invalidate(bankResultsProvider);
      ref.invalidate(bankTopicTreeProvider);
      setState(() {
        _saved = questions.length;
        _skipped = skipped;
      });
    } on Object catch (error) {
      if (mounted) setState(() => _error = l10n.bankExperienceFailed('$error'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return GlassSheet(
      title: l10n.bankExperienceTitle,
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
            controller: _text,
            minLines: 5,
            maxLines: 10,
            decoration: InputDecoration(
              hintText: l10n.bankExperienceHint,
              hintMaxLines: 2,
            ),
          ),
          const SizedBox(height: MockSpace.s3),
          Align(
            alignment: Alignment.centerLeft,
            child: GlassButton(
              label: l10n.bankExperienceExtract,
              icon: Icons.auto_awesome_outlined,
              busy: _busy && _drafts.isEmpty,
              onPressed: _busy ? null : _extract,
            ),
          ),
          if (_drafts.isNotEmpty) ...<Widget>[
            const SizedBox(height: MockSpace.s3),
            Text(
              l10n.bankExperienceDrafts('${_drafts.length}'),
              style: theme.textTheme.bodySmall,
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _drafts.length,
                itemBuilder: (BuildContext context, int index) {
                  final draft = _drafts[index];
                  return CheckboxListTile(
                    value: _selected.contains(index),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selected.add(index);
                        } else {
                          _selected.remove(index);
                        }
                      });
                    },
                    title: Text(draft.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${draft.role} · ${draft.level} · ${draft.keyPoints.join(' / ')}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          l10n.bankExperienceEvidence(draft.evidence),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                },
              ),
            ),
            const SizedBox(height: MockSpace.s2),
            GlassButton(
              label: l10n.bankExperienceSave('${_selected.length}'),
              icon: Icons.save_outlined,
              busy: _busy,
              onPressed: _selected.isEmpty ? null : _save,
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
          if (_saved != null) ...<Widget>[
            const SizedBox(height: MockSpace.s3),
            Text(
              l10n.bankExperienceSaved('$_saved', '$_skipped'),
              style: theme.textTheme.titleSmall,
            ),
          ],
        ],
      ),
    );
  }
}
