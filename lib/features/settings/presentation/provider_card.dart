import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/failure_text.dart';
import '../../../app/providers.dart';
import '../../../core/contracts/contracts.dart';
import '../../../core/design/glass.dart';
import '../../../core/design/tokens.dart';
import '../../../core/settings/connectivity.dart';
import '../../../core/settings/provider_config.dart';
import '../../../l10n/generated/app_localizations.dart';

/// 单个 provider 的配置卡：非敏感字段 + 密钥（只写不读回）。
class ProviderCard extends ConsumerStatefulWidget {
  const ProviderCard({required this.config, required this.label, super.key});

  final ProviderConfig config;
  final String label;

  @override
  ConsumerState<ProviderCard> createState() => _ProviderCardState();
}

class _ProviderCardState extends ConsumerState<ProviderCard> {
  late final TextEditingController _baseUrl;
  late final TextEditingController _model;
  final TextEditingController _apiKey = TextEditingController();
  bool _hasStoredKey = false;
  bool _saving = false;
  bool _testing = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _baseUrl = TextEditingController(text: widget.config.baseUrl);
    _model = TextEditingController(text: widget.config.model);
    _loadStoredKey();
  }

  Future<void> _loadStoredKey() async {
    final key = await ref
        .read(providerConfigsProvider.notifier)
        .loadKey(widget.config.role);
    if (!mounted) return;
    setState(() => _hasStoredKey = key != null && key.isNotEmpty);
  }

  @override
  void dispose() {
    _baseUrl.dispose();
    _model.dispose();
    _apiKey.dispose();
    super.dispose();
  }

  ProviderConfig get _draft => widget.config.copyWith(
    baseUrl: _baseUrl.text.trim(),
    model: _model.text.trim(),
    enabled: true,
  );

  Future<void> _save() async {
    if (_saving || _testing) return;
    final l10n = AppLocalizations.of(context);
    final config = _draft;
    if (!config.hasEndpoint) {
      _toast(l10n.settingsTestNeedsUrl);
      return;
    }
    try {
      parseProviderBaseUrl(config.baseUrl);
    } on FormatException {
      _toast(l10n.settingsInvalidUrl);
      return;
    }
    setState(() => _saving = true);
    try {
      await ref
          .read(providerConfigsProvider.notifier)
          .save(config, apiKey: _apiKey.text.trim());
      if (!mounted) return;
      final stored = await ref
          .read(providerConfigsProvider.notifier)
          .loadKey(widget.config.role);
      if (!mounted) return;
      _apiKey.clear();
      setState(() => _hasStoredKey = stored != null && stored.isNotEmpty);
      _toast(l10n.settingsSaved);
    } on Object catch (error) {
      if (mounted) _toast(l10n.settingsSaveFailed('$error'));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _test() async {
    if (_saving || _testing) return;
    final l10n = AppLocalizations.of(context);
    final config = _draft;
    if (!config.hasEndpoint) {
      _toast(l10n.settingsTestNeedsUrl);
      return;
    }
    final typedKey = _apiKey.text.trim();
    if (typedKey.isEmpty && !_hasStoredKey) {
      _toast(l10n.settingsTestNeedsKey);
      return;
    }
    setState(() => _testing = true);
    try {
      final key = typedKey.isNotEmpty
          ? typedKey
          : await ref
                    .read(providerConfigsProvider.notifier)
                    .loadKey(widget.config.role) ??
                '';
      final result = await ref
          .read(connectivityServiceProvider)
          .test(config: config, apiKey: key);
      if (!mounted) return;
      _toast(l10n.settingsConnectionOk('${result.latency.inMilliseconds}'));
    } on Failure catch (failure) {
      if (!mounted) return;
      _toast('${failureText(l10n, failure)}：${failure.message}');
    } on Object catch (error) {
      if (!mounted) return;
      _toast(l10n.settingsConnectionFailed('$error'));
    } finally {
      if (mounted) setState(() => _testing = false);
    }
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
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                widget.config.role == ProviderRole.scorer
                    ? Icons.fact_check_outlined
                    : Icons.forum_outlined,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: MockSpace.s2),
              Expanded(
                child: Text(widget.label, style: theme.textTheme.titleMedium),
              ),
              if (_hasStoredKey)
                Chip(
                  visualDensity: VisualDensity.compact,
                  avatar: const Icon(Icons.lock_outline, size: 16),
                  label: Text(l10n.settingsApiKeyStored),
                ),
            ],
          ),
          const SizedBox(height: MockSpace.s3),
          TextField(
            controller: _baseUrl,
            keyboardType: TextInputType.url,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: l10n.settingsBaseUrl,
              hintText: 'https://api.deepseek.com',
            ),
          ),
          const SizedBox(height: MockSpace.s3),
          TextField(
            controller: _model,
            autocorrect: false,
            decoration: InputDecoration(labelText: l10n.settingsModel),
          ),
          if (widget.config.role == ProviderRole.search) ...<Widget>[
            const SizedBox(height: MockSpace.s1),
            Text(
              l10n.settingsSearchHint,
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: Theme.of(context).hintColor),
            ),
          ],
          const SizedBox(height: MockSpace.s3),
          TextField(
            controller: _apiKey,
            obscureText: _obscure,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              labelText: l10n.settingsApiKey,
              hintText: _hasStoredKey
                  ? l10n.settingsApiKeyStoredHint
                  : l10n.settingsApiKeyHint,
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
          ),
          const SizedBox(height: MockSpace.s4),
          Wrap(
            spacing: MockSpace.s3,
            runSpacing: MockSpace.s3,
            children: <Widget>[
              GlassButton(
                label: l10n.settingsSave,
                icon: Icons.save_outlined,
                busy: _saving,
                onPressed: _save,
              ),
              GlassButton(
                label: l10n.settingsTest,
                primary: false,
                icon: Icons.bolt_outlined,
                busy: _testing,
                onPressed: _test,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
