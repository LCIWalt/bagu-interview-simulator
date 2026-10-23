import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/app/providers.dart';
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/core/design/theme.dart';
import 'package:mockmate/core/settings/connectivity.dart';
import 'package:mockmate/core/settings/provider_config.dart';
import 'package:mockmate/features/settings/presentation/provider_card.dart';
import 'package:mockmate/l10n/generated/app_localizations.dart';

class _FakeConfigs extends ProviderConfigsController {
  @override
  Future<List<ProviderConfig>> build() async => <ProviderConfig>[
    ProviderConfig.defaults(ProviderRole.interviewer),
  ];

  @override
  Future<void> save(ProviderConfig config, {String? apiKey}) async {}

  @override
  Future<String?> loadKey(ProviderRole role) async => 'sk-test';
}

class _PendingConnectivity extends ConnectivityService {
  final Completer<ConnectivityResult> pending = Completer<ConnectivityResult>();

  @override
  Future<ConnectivityResult> test({
    required ProviderConfig config,
    required String apiKey,
    LlmClient? client,
  }) {
    return pending.future;
  }
}

void main() {
  testWidgets('testing connectivity does not spin the save button', (
    WidgetTester tester,
  ) async {
    final connectivity = _PendingConnectivity();
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          providerConfigsProvider.overrideWith(_FakeConfigs.new),
          connectivityServiceProvider.overrideWithValue(connectivity),
        ],
        child: MaterialApp(
          theme: buildMockTheme(Brightness.light),
          locale: const Locale('zh'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: ProviderCard(
              config: ProviderConfig.defaults(ProviderRole.interviewer),
              label: '面试官',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('测试连通'));
    await tester.pump(const Duration(milliseconds: 120));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(connectivity.pending.isCompleted, isFalse);
  });
}
