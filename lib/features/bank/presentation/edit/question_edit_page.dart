import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers.dart';
import '../../../../core/contracts/contracts.dart';
import '../../../../core/design/glass.dart';
import '../../../../core/design/theme.dart';
import '../../../../core/design/tokens.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/dedup/similar_question_detector.dart';
import '../../data/question_local_repository.dart';
import '../bank_providers.dart';

/// T-020：单题新建，默认 status=user，入库后可立即检索。
class QuestionEditPage extends ConsumerStatefulWidget {
  const QuestionEditPage({super.key});

  @override
  ConsumerState<QuestionEditPage> createState() => _QuestionEditPageState();
}

class _QuestionEditPageState extends ConsumerState<QuestionEditPage> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _body = TextEditingController();
  final TextEditingController _topics = TextEditingController();
  final TextEditingController _summary = TextEditingController();
  final TextEditingController _keyPoints = TextEditingController();
  final TextEditingController _pitfalls = TextEditingController();
  final TextEditingController _followups = TextEditingController();
  final TextEditingController _sourceUrl = TextEditingController();
  final TextEditingController _sourceTitle = TextEditingController();
  final TextEditingController _license = TextEditingController(text: 'user');

  String _role = 'backend';
  String _level = 'mid';
  String _type = 'knowledge';
  int _difficulty = 3;
  bool _saving = false;

  @override
  void dispose() {
    for (final controller in <TextEditingController>[
      _title,
      _body,
      _topics,
      _summary,
      _keyPoints,
      _pitfalls,
      _followups,
      _sourceUrl,
      _sourceTitle,
      _license,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  List<String> _lines(TextEditingController controller) => controller.text
      .split('\n')
      .map((String line) => line.trim())
      .where((String line) => line.isNotEmpty)
      .toList(growable: false);

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final title = _title.text.trim();
    final topics = _topics.text
        .split(RegExp(r'[,，]'))
        .map((String value) => value.trim())
        .where((String value) => value.isNotEmpty)
        .toSet()
        .toList(growable: false);
    final keyPoints = _lines(_keyPoints);
    if (title.isEmpty) {
      _toast(l10n.bankNeedTitle);
      return;
    }
    if (topics.isEmpty) {
      _toast(l10n.bankNeedTopics);
      return;
    }
    if (keyPoints.isEmpty) {
      _toast(l10n.bankNeedKeyPoints);
      return;
    }
    final summary = _summary.text.trim();
    if (summary.isEmpty) {
      _toast(l10n.bankEditAnswerSummary);
      return;
    }
    final url = _sourceUrl.text.trim();
    if (url.isNotEmpty) {
      final uri = Uri.tryParse(url);
      if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
        _toast(l10n.settingsInvalidUrl);
        return;
      }
    }
    final question = Question(
      id: 'user-${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}',
      bankVersion: 'user',
      title: title,
      bodyMarkdown: _body.text.trim().isEmpty ? title : _body.text.trim(),
      topics: topics,
      role: _role,
      level: switch (_level) {
        'junior' => 1,
        'senior' => 4,
        'staff' => 5,
        _ => 3,
      },
      difficulty: _difficulty,
      type: switch (_type) {
        'behavioral' => QuestionType.behavioral,
        'system-design' => QuestionType.systemDesign,
        'coding' => QuestionType.coding,
        'project' => QuestionType.project,
        _ => QuestionType.knowledge,
      },
      answer: QuestionAnswer(
        summary: summary,
        keyPoints: keyPoints,
        pitfalls: _lines(_pitfalls),
      ),
      followups: _lines(_followups),
      source: url.isEmpty
          ? null
          : QuestionSource(
              url: url,
              title: _sourceTitle.text.trim().isEmpty
                  ? url
                  : _sourceTitle.text.trim(),
              license: _license.text.trim().isEmpty
                  ? 'user'
                  : _license.text.trim(),
              retrievedAt: DateTime.now(),
            ),
      status: QuestionStatus.user,
      updatedAt: DateTime.now(),
    );

    setState(() => _saving = true);
    try {
      final repo = ref.read(bankRepositoryImplProvider);
      final existing = await repo.search(const QuestionQuery(limit: 5000));
      final matches = const SimilarQuestionDetector().findSimilar(
        question,
        existing,
      );
      if (matches.isNotEmpty) {
        final keep = await _confirmDuplicate(matches.first);
        if (keep != true) return;
      }
      await repo.upsertQuestions(<Question>[question]);
      await ref
          .read(questionLocalRepositoryProvider)
          .ensureUserOrigin(question.id);
      ref.invalidate(bankResultsProvider);
      ref.invalidate(bankTopicTreeProvider);
      if (!mounted) return;
      _toast(l10n.bankSaveSuccess);
      context.pop();
    } on Object catch (error) {
      if (mounted) _toast('$error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<bool?> _confirmDuplicate(SimilarMatch match) {
    final l10n = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(l10n.bankDuplicateTitle),
        content: Text(
          l10n.bankDuplicateBody(
            match.question.title,
            (match.similarity * 100).toStringAsFixed(0),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.bankDuplicateKeep),
          ),
        ],
      ),
    );
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(l10n.bankNewQuestion)),
      body: AppBackdrop(
        child: ListView(
          padding: const EdgeInsets.all(MockSpace.s5),
          children: <Widget>[
            GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextField(
                    controller: _title,
                    decoration: InputDecoration(labelText: l10n.bankEditTitle),
                  ),
                  const SizedBox(height: MockSpace.s3),
                  TextField(
                    controller: _body,
                    minLines: 2,
                    maxLines: 5,
                    decoration: InputDecoration(labelText: l10n.bankEditBody),
                  ),
                  const SizedBox(height: MockSpace.s3),
                  TextField(
                    controller: _topics,
                    decoration: InputDecoration(
                      labelText: l10n.bankEditTopics,
                      hintText: 'go, runtime',
                    ),
                  ),
                  const SizedBox(height: MockSpace.s3),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _role,
                          decoration: InputDecoration(
                            labelText: l10n.bankEditRole,
                          ),
                          items: <DropdownMenuItem<String>>[
                            DropdownMenuItem<String>(
                              value: 'backend',
                              child: Text(l10n.bankRoleBackend),
                            ),
                            DropdownMenuItem<String>(
                              value: 'frontend',
                              child: Text(l10n.bankRoleFrontend),
                            ),
                            DropdownMenuItem<String>(
                              value: 'algorithm',
                              child: Text(l10n.bankRoleAlgorithm),
                            ),
                            DropdownMenuItem<String>(
                              value: 'mobile',
                              child: Text(l10n.bankRoleMobile),
                            ),
                          ],
                          onChanged: (String? value) =>
                              setState(() => _role = value ?? _role),
                        ),
                      ),
                      const SizedBox(width: MockSpace.s3),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _level,
                          decoration: InputDecoration(
                            labelText: l10n.bankEditLevel,
                          ),
                          items: <DropdownMenuItem<String>>[
                            DropdownMenuItem<String>(
                              value: 'junior',
                              child: Text(l10n.mockLevelJunior),
                            ),
                            DropdownMenuItem<String>(
                              value: 'mid',
                              child: Text(l10n.mockLevelMid),
                            ),
                            DropdownMenuItem<String>(
                              value: 'senior',
                              child: Text(l10n.mockLevelSenior),
                            ),
                            DropdownMenuItem<String>(
                              value: 'staff',
                              child: Text(l10n.mockLevelStaff),
                            ),
                          ],
                          onChanged: (String? value) =>
                              setState(() => _level = value ?? _level),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: MockSpace.s3),
                  DropdownButtonFormField<String>(
                    initialValue: _type,
                    decoration: InputDecoration(labelText: l10n.bankEditType),
                    items: <DropdownMenuItem<String>>[
                      DropdownMenuItem<String>(
                        value: 'knowledge',
                        child: Text(l10n.bankTypeKnowledge),
                      ),
                      DropdownMenuItem<String>(
                        value: 'behavioral',
                        child: Text(l10n.bankTypeBehavioral),
                      ),
                      DropdownMenuItem<String>(
                        value: 'system-design',
                        child: Text(l10n.bankTypeSystemDesign),
                      ),
                      DropdownMenuItem<String>(
                        value: 'coding',
                        child: Text(l10n.bankTypeCoding),
                      ),
                      DropdownMenuItem<String>(
                        value: 'project',
                        child: Text(l10n.bankTypeProject),
                      ),
                    ],
                    onChanged: (String? value) =>
                        setState(() => _type = value ?? _type),
                  ),
                  const SizedBox(height: MockSpace.s3),
                  Text(
                    '${l10n.bankEditDifficulty} · $_difficulty',
                    style: theme.textTheme.titleSmall,
                  ),
                  Slider(
                    value: _difficulty.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    onChanged: (double value) =>
                        setState(() => _difficulty = value.round()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: MockSpace.s4),
            GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextField(
                    controller: _summary,
                    minLines: 2,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: l10n.bankEditAnswerSummary,
                    ),
                  ),
                  const SizedBox(height: MockSpace.s3),
                  TextField(
                    controller: _keyPoints,
                    minLines: 4,
                    maxLines: 10,
                    decoration: InputDecoration(
                      labelText: l10n.bankEditKeyPoints,
                      hintText: l10n.bankEditKeyPointsHint,
                    ),
                  ),
                  const SizedBox(height: MockSpace.s3),
                  TextField(
                    controller: _pitfalls,
                    minLines: 2,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: l10n.bankEditPitfalls,
                    ),
                  ),
                  const SizedBox(height: MockSpace.s3),
                  TextField(
                    controller: _followups,
                    minLines: 2,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: l10n.bankEditFollowups,
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
                  TextField(
                    controller: _sourceUrl,
                    keyboardType: TextInputType.url,
                    decoration: InputDecoration(
                      labelText: l10n.bankEditSourceUrl,
                    ),
                  ),
                  const SizedBox(height: MockSpace.s3),
                  TextField(
                    controller: _sourceTitle,
                    decoration: InputDecoration(
                      labelText: l10n.bankEditSourceTitle,
                    ),
                  ),
                  const SizedBox(height: MockSpace.s3),
                  TextField(
                    controller: _license,
                    decoration: InputDecoration(
                      labelText: l10n.bankEditLicense,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: MockSpace.s4),
            GlassButton(
              label: l10n.bankSave,
              icon: Icons.save_outlined,
              busy: _saving,
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
