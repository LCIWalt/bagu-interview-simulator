import 'package:flutter/material.dart';

import '../../../core/design/glass.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';

/// M0 占位页：保持三端结构一致，真实内容随里程碑替换。
class FeaturePlaceholderPage extends StatelessWidget {
  const FeaturePlaceholderPage({
    required this.title,
    required this.body,
    super.key,
    this.action,
  });

  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(title)),
      body: AppBackdrop(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(MockSpace.s5),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: GlassPanel(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.construction_outlined,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: MockSpace.s3),
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: MockSpace.s2),
                    Text(
                      body,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (action != null) ...<Widget>[
                      const SizedBox(height: MockSpace.s4),
                      action!,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
