import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/generated/app_localizations.dart';
import 'glass.dart';
import 'theme.dart';
import 'tokens.dart';

/// 设计系统演示页：验证玻璃三级降级与控件规格。
class DesignDemoPage extends ConsumerStatefulWidget {
  const DesignDemoPage({super.key});

  @override
  ConsumerState<DesignDemoPage> createState() => _DesignDemoPageState();
}

class _DesignDemoPageState extends ConsumerState<DesignDemoPage> {
  GlassQuality _quality = GlassQuality.full;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final demoTheme = Theme.of(context).copyWith(
      extensions: <ThemeExtension<dynamic>>[
        tokens.copyWith(glassQuality: _quality),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.designDemoTitle)),
      body: AppBackdrop(
        child: Theme(
          data: demoTheme,
          child: ListView(
            padding: const EdgeInsets.all(MockSpace.s5),
            children: <Widget>[
              Text(
                l10n.designDemoTitle,
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: MockSpace.s2),
              Text(
                l10n.designDemoBody,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: MockSpace.s5),
              Text(
                l10n.designDemoQuality,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: MockSpace.s2),
              SegmentedButton<GlassQuality>(
                segments: <ButtonSegment<GlassQuality>>[
                  ButtonSegment<GlassQuality>(
                    value: GlassQuality.full,
                    label: Text(l10n.designQualityFull),
                  ),
                  ButtonSegment<GlassQuality>(
                    value: GlassQuality.blurOnly,
                    label: Text(l10n.designQualityBlur),
                  ),
                  ButtonSegment<GlassQuality>(
                    value: GlassQuality.flat,
                    label: Text(l10n.designQualityFlat),
                  ),
                ],
                selected: <GlassQuality>{_quality},
                onSelectionChanged: (Set<GlassQuality> value) {
                  setState(() => _quality = value.first);
                },
              ),
              const SizedBox(height: MockSpace.s5),
              GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      l10n.designDemoContent,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: MockSpace.s2),
                    Text(l10n.designDemoBody),
                    const SizedBox(height: MockSpace.s4),
                    Wrap(
                      spacing: MockSpace.s3,
                      runSpacing: MockSpace.s3,
                      children: <Widget>[
                        GlassButton(
                          label: l10n.settingsTest,
                          icon: Icons.bolt_outlined,
                          onPressed: () {},
                        ),
                        GlassButton(
                          label: l10n.settingsSave,
                          primary: false,
                          onPressed: () {},
                        ),
                        GlassButton(
                          label: l10n.commonLoading,
                          primary: false,
                          busy: true,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: MockSpace.s4),
              GlassPanel(
                elevated: true,
                onTap: () => GlassSheet.show<void>(
                  context: context,
                  title: l10n.designDemoTitle,
                  child: Text(l10n.designDemoBody),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.commonClose),
                    ),
                  ],
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.auto_awesome,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: MockSpace.s3),
                    Expanded(child: Text(l10n.designDemoContent)),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
              const SizedBox(height: MockSpace.s4),
              GlassPanel(
                padding: const EdgeInsets.all(MockSpace.s3),
                child: Row(
                  children: <Widget>[
                    _SemanticDot(color: tokens.success, label: 'success'),
                    _SemanticDot(color: tokens.warning, label: 'warn'),
                    _SemanticDot(color: tokens.danger, label: 'danger'),
                    _SemanticDot(color: tokens.info, label: 'info'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SemanticDot extends StatelessWidget {
  const _SemanticDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: MockSpace.s4),
      child: Row(
        children: <Widget>[
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: MockSpace.s2),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
