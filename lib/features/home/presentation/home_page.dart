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
import '../../review/presentation/review_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _selectionMode = false;
  final Set<String> _selected = <String>{};

  void _enterSelection(SessionRow session) {
    setState(() {
      _selectionMode = true;
      _selected
        ..clear()
        ..add(session.id);
    });
  }

  void _toggle(SessionRow session) {
    setState(() {
      if (!_selected.remove(session.id)) _selected.add(session.id);
    });
  }

  void _exitSelection() {
    setState(() {
      _selectionMode = false;
      _selected.clear();
    });
  }

  Future<void> _confirmDelete() async {
    if (_selected.isEmpty) return;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(l10n.homeDeleteConfirmTitle),
        content: Text(l10n.homeDeleteConfirmBody('${_selected.length}')),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.homeDeleteAction),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final repo = ref.read(sessionRepositoryImplProvider);
    for (final id in _selected.toList(growable: false)) {
      await repo.deleteSession(id);
    }
    if (!mounted) return;
    ref.invalidate(recentSessionsProvider);
    ref.invalidate(reviewSessionsProvider);
    ref.invalidate(reviewStatsProvider);
    _exitSelection();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final recent = ref.watch(recentSessionsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackdrop(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(MockSpace.s5),
            children: <Widget>[
              Row(
                children: _selectionMode
                    ? <Widget>[
                        IconButton(
                          tooltip: l10n.commonClose,
                          onPressed: _exitSelection,
                          icon: const Icon(Icons.close),
                        ),
                        Text(
                          l10n.homeSelectedCount('${_selected.length}'),
                          style: theme.textTheme.titleSmall,
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: l10n.homeDeleteSelected,
                          onPressed: _selected.isEmpty ? null : _confirmDelete,
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ]
                    : <Widget>[
                        Icon(
                          Icons.record_voice_over_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: MockSpace.s2),
                        Text(
                          l10n.appTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            letterSpacing: 0.4,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: l10n.settingsTitle,
                          onPressed: () => context.go('/settings'),
                          icon: const Icon(Icons.settings_outlined),
                        ),
                      ],
              ),
              const SizedBox(height: MockSpace.s5),
              GlassPanel(
                elevated: true,
                padding: const EdgeInsets.all(MockSpace.s5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      l10n.homeTitle,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: MockSpace.s2),
                    Text(l10n.homeSubtitle, style: theme.textTheme.bodyLarge),
                    const SizedBox(height: MockSpace.s5),
                    Wrap(
                      spacing: MockSpace.s3,
                      runSpacing: MockSpace.s3,
                      children: <Widget>[
                        GlassButton(
                          label: l10n.homeStartDrill,
                          icon: Icons.play_arrow,
                          onPressed: () => context.go('/drill'),
                        ),
                        GlassButton(
                          label: l10n.homeStartMock,
                          primary: false,
                          icon: Icons.timer_outlined,
                          onPressed: () => context.go('/mock/setup'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: MockSpace.s5),
              Row(
                children: <Widget>[
                  Text(
                    l10n.homeRecentSessions,
                    style: theme.textTheme.titleMedium,
                  ),
                  const Spacer(),
                  if (!_selectionMode)
                    TextButton(
                      onPressed: () => context.go('/review'),
                      child: Text(l10n.navReview),
                    ),
                ],
              ),
              const SizedBox(height: MockSpace.s3),
              recent.when(
                data: (List<SessionRow> sessions) => sessions.isEmpty
                    ? GlassPanel(
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.history, color: theme.hintColor),
                            const SizedBox(width: MockSpace.s3),
                            Expanded(child: Text(l10n.homeEmptyRecent)),
                          ],
                        ),
                      )
                    : Column(
                        children: <Widget>[
                          for (final session in sessions)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: MockSpace.s3,
                              ),
                              child: RepaintBoundary(
                                child: _RecentSessionCard(
                                  session: session,
                                  selected: _selected.contains(session.id),
                                  selectionMode: _selectionMode,
                                  onTap: () {
                                    if (_selectionMode) {
                                      _toggle(session);
                                    } else {
                                      _open(session);
                                    }
                                  },
                                  onLongPress: () => _enterSelection(session),
                                ),
                              ),
                            ),
                        ],
                      ),
                loading: () => const LinearProgressIndicator(),
                error: (Object error, StackTrace stack) =>
                    GlassPanel(child: Text('${l10n.failureUnknown}\n$error')),
              ),
              const SizedBox(height: MockSpace.s6),
              Text(
                l10n.appTagline,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _open(SessionRow session) {
    context.go(
      session.mode == 'mock' ? '/mock/report/${session.id}' : '/review',
    );
  }
}

class _RecentSessionCard extends StatelessWidget {
  const _RecentSessionCard({
    required this.session,
    required this.selected,
    required this.selectionMode,
    required this.onTap,
    required this.onLongPress,
  });

  final SessionRow session;
  final bool selected;
  final bool selectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassPanel(
      padding: EdgeInsets.zero,
      tint: selected ? theme.colorScheme.primary.withValues(alpha: 0.12) : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(MockRadius.lg),
        onTap: onTap,
        onLongPress: selectionMode ? null : onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(MockSpace.s4),
          child: Row(
            children: <Widget>[
              Icon(
                selectionMode
                    ? (selected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked)
                    : (session.mode == 'drill'
                          ? Icons.play_circle_outline
                          : Icons.timer_outlined),
                color: selected ? theme.colorScheme.primary : null,
              ),
              const SizedBox(width: MockSpace.s3),
              Expanded(
                child: Text(
                  '${session.mode} · ${DateFormat.yMMMd().add_Hm().format(session.startedAt.toLocal())}',
                ),
              ),
              if (!selectionMode) const Icon(Icons.chevron_right, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
