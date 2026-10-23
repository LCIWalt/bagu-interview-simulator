import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/failure_text.dart';
import '../../../../app/providers.dart';
import '../../../../core/contracts/contracts.dart';
import '../../../../core/design/glass.dart';
import '../../../../core/design/theme.dart';
import '../../../../core/design/tokens.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/mock_config_store.dart';

class MockSetupPage extends ConsumerStatefulWidget {
  const MockSetupPage({super.key});

  @override
  ConsumerState<MockSetupPage> createState() => _MockSetupPageState();
}

class _MockSetupPageState extends ConsumerState<MockSetupPage> {
  SessionConfig? _config;
  Session? _active;
  bool _starting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final saved = await MockConfigStore(ref.read(databaseProvider)).load();
    final active = await ref
        .read(sessionRepositoryImplProvider)
        .activeSession();
    if (!mounted) return;
    setState(() {
      _config = saved?.mode == SessionMode.mock
          ? saved
          : const SessionConfig(
              mode: SessionMode.mock,
              role: 'backend',
              level: 'mid',
            );
      _active = active?.mode == SessionMode.mock ? active : null;
    });
  }

  void _update(SessionConfig value) => setState(() => _config = value);

  Future<void> _start() async {
    final config = _config;
    if (config == null) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _starting = true);
    try {
      await MockConfigStore(ref.read(databaseProvider)).save(config);
      final session = await ref.read(sessionRepositoryProvider).create(config);
      if (!mounted) return;
      await context.push('/mock/live/${session.id}');
    } on Failure catch (failure) {
      if (mounted) showFailure(context, failure);
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.mockStartFailed)));
      }
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  SessionConfig _copy({
    String? role,
    String? level,
    int? duration,
    int? difficulty,
    int? followupDepth,
    InterviewerStyle? style,
    bool? allowHints,
  }) {
    final config = _config!;
    return SessionConfig(
      mode: config.mode,
      role: role ?? config.role,
      level: level ?? config.level,
      durationMinutes: duration ?? config.durationMinutes,
      difficulty: difficulty ?? config.difficulty,
      followupDepth: followupDepth ?? config.followupDepth,
      allowHints: allowHints ?? config.allowHints,
      style: style ?? config.style,
      topics: config.topics,
      jdText: config.jdText,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final config = _config;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(l10n.mockSetupTitle)),
      body: AppBackdrop(
        child: config == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(MockSpace.s5),
                children: <Widget>[
                  if (_active != null) ...<Widget>[
                    GlassPanel(
                      child: Row(
                        children: <Widget>[
                          const Icon(Icons.play_circle_outline),
                          const SizedBox(width: MockSpace.s3),
                          Expanded(child: Text(l10n.mockResume)),
                          GlassButton(
                            label: l10n.mockResume,
                            primary: false,
                            onPressed: () =>
                                context.push('/mock/live/${_active!.id}'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: MockSpace.s4),
                  ],
                  GlassPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _label(theme, l10n.mockRole),
                        SegmentedButton<String>(
                          segments: <ButtonSegment<String>>[
                            ButtonSegment<String>(
                              value: 'backend',
                              label: Text(l10n.bankRoleBackend),
                            ),
                            ButtonSegment<String>(
                              value: 'frontend',
                              label: Text(l10n.bankRoleFrontend),
                            ),
                            ButtonSegment<String>(
                              value: 'algorithm',
                              label: Text(l10n.bankRoleAlgorithm),
                            ),
                            ButtonSegment<String>(
                              value: 'mobile',
                              label: Text(l10n.bankRoleMobile),
                            ),
                          ],
                          selected: <String>{config.role},
                          onSelectionChanged: (Set<String> value) =>
                              _update(_copy(role: value.first)),
                        ),
                        const SizedBox(height: MockSpace.s4),
                        _label(theme, l10n.mockLevel),
                        SegmentedButton<String>(
                          segments: <ButtonSegment<String>>[
                            ButtonSegment<String>(
                              value: 'junior',
                              label: Text(l10n.mockLevelJunior),
                            ),
                            ButtonSegment<String>(
                              value: 'mid',
                              label: Text(l10n.mockLevelMid),
                            ),
                            ButtonSegment<String>(
                              value: 'senior',
                              label: Text(l10n.mockLevelSenior),
                            ),
                            ButtonSegment<String>(
                              value: 'staff',
                              label: Text(l10n.mockLevelStaff),
                            ),
                          ],
                          selected: <String>{config.level},
                          onSelectionChanged: (Set<String> value) =>
                              _update(_copy(level: value.first)),
                        ),
                        const SizedBox(height: MockSpace.s4),
                        _label(theme, l10n.mockDuration),
                        Wrap(
                          spacing: MockSpace.s2,
                          children: <Widget>[
                            for (final minutes in <int>[10, 20, 30, 45])
                              ChoiceChip(
                                label: Text(
                                  l10n.mockDurationMinutes('$minutes'),
                                ),
                                selected: config.durationMinutes == minutes,
                                onSelected: (_) =>
                                    _update(_copy(duration: minutes)),
                              ),
                          ],
                        ),
                        const SizedBox(height: MockSpace.s4),
                        _label(
                          theme,
                          '${l10n.mockDifficulty} · ${config.difficulty}',
                        ),
                        Slider(
                          value: config.difficulty.toDouble(),
                          min: 1,
                          max: 5,
                          divisions: 4,
                          label: '${config.difficulty}',
                          onChanged: (double value) =>
                              _update(_copy(difficulty: value.round())),
                        ),
                        const SizedBox(height: MockSpace.s2),
                        _label(theme, l10n.mockFollowupDepth),
                        SegmentedButton<int>(
                          segments: <ButtonSegment<int>>[
                            for (var depth = 0; depth <= 3; depth++)
                              ButtonSegment<int>(
                                value: depth,
                                label: Text('$depth'),
                              ),
                          ],
                          selected: <int>{config.followupDepth},
                          onSelectionChanged: (Set<int> value) =>
                              _update(_copy(followupDepth: value.first)),
                        ),
                        const SizedBox(height: MockSpace.s4),
                        _label(theme, l10n.mockStyle),
                        SegmentedButton<InterviewerStyle>(
                          segments: <ButtonSegment<InterviewerStyle>>[
                            ButtonSegment<InterviewerStyle>(
                              value: InterviewerStyle.friendly,
                              label: Text(l10n.mockStyleFriendly),
                            ),
                            ButtonSegment<InterviewerStyle>(
                              value: InterviewerStyle.neutral,
                              label: Text(l10n.mockStyleNeutral),
                            ),
                            ButtonSegment<InterviewerStyle>(
                              value: InterviewerStyle.stress,
                              label: Text(l10n.mockStyleStress),
                            ),
                          ],
                          selected: <InterviewerStyle>{config.style},
                          onSelectionChanged: (Set<InterviewerStyle> value) =>
                              _update(_copy(style: value.first)),
                        ),
                        const SizedBox(height: MockSpace.s2),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(l10n.mockAllowHints),
                          value: config.allowHints,
                          onChanged: (bool value) =>
                              _update(_copy(allowHints: value)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: MockSpace.s4),
                  GlassButton(
                    label: l10n.mockStart,
                    icon: Icons.play_arrow,
                    busy: _starting,
                    onPressed: _starting ? null : _start,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _label(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: MockSpace.s2),
      child: Text(text, style: theme.textTheme.titleSmall),
    );
  }
}
