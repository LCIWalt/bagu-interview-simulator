import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../l10n/generated/app_localizations.dart';

/// 平台自适应外壳：宽屏（macOS/平板）侧边栏，窄屏底部导航。
///
/// macOS 额外提供菜单栏与快捷键（指南 §8.4）。
class AppShell extends StatelessWidget {
  const AppShell({required this.shell, super.key});

  final StatefulNavigationShell shell;

  static const double _railBreakpoint = 840;

  void _openDesignDemo(BuildContext context) => context.push('/design');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final wide = MediaQuery.sizeOf(context).width >= _railBreakpoint;
    final isMac = !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

    final destinations = <_Destination>[
      _Destination(
        l10n.navPractice,
        Icons.play_circle_outline,
        Icons.play_circle_fill,
      ),
      _Destination(
        l10n.navBank,
        Icons.library_books_outlined,
        Icons.library_books,
      ),
      _Destination(l10n.navReview, Icons.insights_outlined, Icons.insights),
      _Destination(l10n.navSettings, Icons.settings_outlined, Icons.settings),
    ];

    Widget body = Scaffold(
      backgroundColor: Colors.transparent,
      body: Row(
        children: <Widget>[
          if (wide)
            NavigationRail(
              selectedIndex: shell.currentIndex,
              onDestinationSelected: (int index) => shell.goBranch(
                index,
                initialLocation: index == shell.currentIndex,
              ),
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                child: Icon(
                  Icons.record_voice_over_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              trailing: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: IconButton(
                  tooltip: l10n.settingsDesignDemo,
                  onPressed: () => _openDesignDemo(context),
                  icon: const Icon(Icons.palette_outlined),
                ),
              ),
              destinations: <NavigationRailDestination>[
                for (final d in destinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label),
                  ),
              ],
            ),
          if (wide) const VerticalDivider(width: 1),
          Expanded(child: shell),
        ],
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: shell.currentIndex,
              onDestinationSelected: (int index) => shell.goBranch(
                index,
                initialLocation: index == shell.currentIndex,
              ),
              destinations: <NavigationDestination>[
                for (final d in destinations)
                  NavigationDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: d.label,
                  ),
              ],
            ),
    );

    body = CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyN, meta: true): () =>
            shell.goBranch(0),
        const SingleActivator(LogicalKeyboardKey.comma, meta: true): () =>
            context.go('/settings'),
      },
      child: body,
    );

    if (!isMac) return body;

    return PlatformMenuBar(
      menus: <PlatformMenu>[
        PlatformMenu(
          label: 'MockMate',
          menus: <PlatformMenuItem>[
            PlatformMenuItem(
              label: l10n.navPractice,
              shortcut: const SingleActivator(
                LogicalKeyboardKey.keyN,
                meta: true,
              ),
              onSelected: () => shell.goBranch(0),
            ),
            PlatformMenuItem(
              label: l10n.navSettings,
              shortcut: const SingleActivator(
                LogicalKeyboardKey.comma,
                meta: true,
              ),
              onSelected: () => context.go('/settings'),
            ),
            PlatformMenuItem(
              label: l10n.designDemoTitle,
              onSelected: () => _openDesignDemo(context),
            ),
          ],
        ),
      ],
      child: body,
    );
  }
}

class _Destination {
  const _Destination(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
