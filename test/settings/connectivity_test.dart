import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/core/contracts/contracts.dart';
import 'package:mockmate/core/settings/connectivity.dart';
import 'package:mockmate/core/settings/provider_config.dart';

import '../fakes/fakes.dart';

void main() {
  const config = ProviderConfig(
    role: ProviderRole.interviewer,
    baseUrl: 'https://api.example.com',
    model: 'deepseek-chat',
    enabled: true,
  );

  test('returns latency and first text on success', () async {
    final client = FakeLlmClient(
      script: <FakeLlmTurn>[
        FakeLlmTurn(textChunks: <String>['pong']),
      ],
    );
    final result = await ConnectivityService().test(
      config: config,
      apiKey: 'sk-test',
      client: client,
    );
    expect(result.sample, 'pong');
    expect(client.requests.single.model, 'deepseek-chat');
  });

  test('missing key fails with AuthFailure before any request', () async {
    final client = FakeLlmClient();
    await expectLater(
      ConnectivityService().test(config: config, apiKey: ' ', client: client),
      throwsA(isA<AuthFailure>()),
    );
    expect(client.requests, isEmpty);
  });

  test('provider error is surfaced as the same Failure type', () async {
    final client = FakeLlmClient(
      script: <FakeLlmTurn>[
        FakeLlmTurn(error: const NotFoundFailure('no model')),
      ],
    );
    await expectLater(
      ConnectivityService().test(
        config: config,
        apiKey: 'sk-test',
        client: client,
      ),
      throwsA(isA<NotFoundFailure>()),
    );
  });

  test('embedding role never hits the network', () async {
    await expectLater(
      ConnectivityService().test(
        config: ProviderConfig.defaults(ProviderRole.embedding),
        apiKey: 'x',
      ),
      throwsA(isA<UnknownFailure>()),
    );
  });
}
