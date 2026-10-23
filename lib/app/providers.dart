import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/agent/cost/llm_call_recorder.dart';
import '../core/agent/prompts/prompt_source.dart';
import '../core/agent/prompts/prompt_template.dart';
import '../core/contracts/contracts.dart';
import '../core/db/app_database.dart';
import '../core/platform/secure_store.dart';
import '../core/platform/tts/openai_tts_provider.dart';
import '../core/platform/tts/tts_service.dart';
import '../core/search/embedding/onnx_bge_embedding.dart';
import '../core/search/openai_web_search.dart';
import '../core/search/search_cache.dart';
import '../core/search/search_transport.dart';
import '../core/search/tavily_provider.dart';
import '../core/settings/connectivity.dart';
import '../core/settings/preferences.dart';
import '../core/settings/provider_config.dart';
import '../core/settings/repositories.dart';
import '../core/util/app_logger.dart';
import '../features/bank/data/bank_repository_impl.dart';
import '../features/bank/data/graph/question_graph_repository.dart';
import '../features/bank/data/import/bank_import_service.dart';
import '../features/bank/data/import_bulk/bulk_import_service.dart';
import '../features/bank/data/question_local_repository.dart';
import '../features/bank/data/remote/remote_source_importer.dart';
import '../features/bank/data/search/hybrid_search.dart';
import '../features/bank/data/seed_bank_installer.dart';
import '../features/bank/data/update/bank_public_key.dart';
import '../features/bank/data/update/bank_update_service.dart';
import '../features/bank/data/update/bank_update_source.dart';
import '../features/bank/data/update/manifest_verifier.dart';
import '../features/bank/domain/experience_extractor.dart';
import '../features/interview/data/appeal_repository.dart';
import '../features/interview/data/drift_session_repository.dart';
import '../features/interview/data/session_memory_store.dart';
import '../features/interview/domain/factcheck/claim_extractor.dart';
import '../features/interview/domain/factcheck/claim_verifier.dart';
import '../features/interview/domain/factcheck/fact_check_service.dart';
import '../features/interview/domain/interviewer_agent.dart';
import '../features/interview/domain/memory/memory_extractor.dart';
import '../features/interview/domain/scoring/scoring_engine.dart';

/// 以下三个 provider 在 `main()` 里用真实实例覆盖；测试中注入 fake。
final Provider<AppDatabase> databaseProvider = Provider<AppDatabase>(
  (Ref ref) => throw UnimplementedError('databaseProvider 必须在 main 覆盖'),
);

final Provider<AppLogger> loggerProvider = Provider<AppLogger>(
  (Ref ref) => throw UnimplementedError('loggerProvider 必须在 main 覆盖'),
);

final Provider<SecureStore> secureStoreProvider = Provider<SecureStore>(
  (Ref ref) => throw UnimplementedError('secureStoreProvider 必须在 main 覆盖'),
);

final Provider<ProviderRepository> providerRepositoryProvider =
    Provider<ProviderRepository>(
      (Ref ref) => ProviderRepository(
        ref.watch(databaseProvider),
        ref.watch(secureStoreProvider),
      ),
    );

final Provider<PreferencesRepository> preferencesRepositoryProvider =
    Provider<PreferencesRepository>(
      (Ref ref) => PreferencesRepository(ref.watch(databaseProvider)),
    );

final Provider<ConnectivityService> connectivityServiceProvider =
    Provider<ConnectivityService>(
      (Ref ref) => ConnectivityService(logger: ref.watch(loggerProvider)),
    );

/// 启动时加载全部 prompt；失败会在设置页/日志里暴露，不阻塞首帧。
final FutureProvider<PromptRegistry> promptRegistryProvider =
    FutureProvider<PromptRegistry>(
      (Ref ref) => PromptRegistry.load(AssetPromptSource()),
    );

class PreferencesController extends AsyncNotifier<AppPreferences> {
  @override
  Future<AppPreferences> build() =>
      ref.read(preferencesRepositoryProvider).load();

  Future<void> setThemeMode(ThemeMode mode) async {
    final current = state.valueOrNull ?? const AppPreferences();
    final next = current.copyWith(themeMode: mode);
    state = AsyncData(next);
    await ref.read(preferencesRepositoryProvider).save(next);
  }

  Future<void> setSemanticSearch(bool enabled) async {
    final current = state.valueOrNull ?? const AppPreferences();
    final next = current.copyWith(semanticSearch: enabled);
    state = AsyncData(next);
    await ref.read(preferencesRepositoryProvider).save(next);
  }

  Future<void> setLocale(String? code) async {
    final current = state.valueOrNull ?? const AppPreferences();
    final next = current.localeCode == code
        ? current
        : current.copyWith(localeCode: code, clearLocale: code == null);
    state = AsyncData(next);
    await ref.read(preferencesRepositoryProvider).save(next);
  }
}

final AsyncNotifierProvider<PreferencesController, AppPreferences>
preferencesProvider =
    AsyncNotifierProvider<PreferencesController, AppPreferences>(
      PreferencesController.new,
    );

class ProviderConfigsController extends AsyncNotifier<List<ProviderConfig>> {
  @override
  Future<List<ProviderConfig>> build() =>
      ref.read(providerRepositoryProvider).loadAll();

  Future<void> save(ProviderConfig config, {String? apiKey}) async {
    await ref.read(providerRepositoryProvider).save(config, apiKey: apiKey);
    state = AsyncData(await ref.read(providerRepositoryProvider).loadAll());
  }

  Future<String?> loadKey(ProviderRole role) =>
      ref.read(providerRepositoryProvider).loadKey(role);
}

final AsyncNotifierProvider<ProviderConfigsController, List<ProviderConfig>>
providerConfigsProvider =
    AsyncNotifierProvider<ProviderConfigsController, List<ProviderConfig>>(
      ProviderConfigsController.new,
    );

/// 首页「最近练习」（M3 前只用于空态展示）。
final FutureProvider<List<SessionRow>> recentSessionsProvider =
    FutureProvider<List<SessionRow>>((Ref ref) async {
      final db = ref.watch(databaseProvider);
      return (db.select(db.sessions)
            ..orderBy(<OrderClauseGenerator<$SessionsTable>>[
              ($SessionsTable t) => OrderingTerm.desc(t.startedAt),
            ])
            ..limit(5))
          .get();
    });

/// 题库仓库（T-013）。UI 只依赖 [BankRepository] 契约。
final Provider<BankRepositoryImpl> bankRepositoryImplProvider =
    Provider<BankRepositoryImpl>(
      (Ref ref) => BankRepositoryImpl(ref.watch(databaseProvider)),
    );

final Provider<BankRepository> bankRepositoryProvider =
    Provider<BankRepository>(
      (Ref ref) => ref.watch(bankRepositoryImplProvider),
    );

final Provider<QuestionLocalRepository> questionLocalRepositoryProvider =
    Provider<QuestionLocalRepository>(
      (Ref ref) => QuestionLocalRepository(ref.watch(databaseProvider)),
    );

final Provider<SeedBankInstaller> seedBankInstallerProvider =
    Provider<SeedBankInstaller>(
      (Ref ref) => SeedBankInstaller(
        ref.watch(bankRepositoryImplProvider),
        logger: ref.watch(loggerProvider),
      ),
    );

/// 打开题库页时确保内置种子已安装；返回是否发生了安装。
final FutureProvider<bool> seedBankProvider = FutureProvider<bool>(
  (Ref ref) => ref.watch(seedBankInstallerProvider).installIfNeeded(),
);

/// 当前 App 版本（包信息），用于题库 minAppVersion 判断。
final FutureProvider<String> appVersionProvider = FutureProvider<String>((
  Ref ref,
) async {
  final info = await PackageInfo.fromPlatform();
  return info.version;
});

/// 题库更新服务：真实 GitHub Release 源 + 内置公钥。
final FutureProvider<BankUpdateService> bankUpdateServiceProvider =
    FutureProvider<BankUpdateService>((Ref ref) async {
      final support = await getApplicationSupportDirectory();
      final appVersion = await ref.watch(appVersionProvider.future);
      final repository = ref.watch(bankRepositoryImplProvider);
      final service = BankUpdateService(
        db: ref.watch(databaseProvider),
        repository: repository,
        source: GitHubReleaseSource(
          releaseApiUrl: Uri.parse(kDefaultBankReleaseApiUrl),
        ),
        verifier: ManifestSignatureVerifier.fromBase64(kDefaultBankPublicKey),
        currentAppVersion: appVersion,
        bankRoot: Directory(p.join(support.path, 'bank')),
        logger: ref.watch(loggerProvider),
      );
      repository.updateRunner = service;
      return service;
    });

final Provider<BankImportService> bankImportServiceProvider =
    Provider<BankImportService>(
      (Ref ref) => BankImportService(
        ref.watch(bankRepositoryImplProvider),
        ref.watch(questionLocalRepositoryProvider),
      ),
    );

final Provider<BulkImportService> bulkImportServiceProvider =
    Provider<BulkImportService>(
      (Ref ref) => BulkImportService(
        ref.watch(bankRepositoryImplProvider),
        ref.watch(questionLocalRepositoryProvider),
      ),
    );

/// 会话仓库（T-031）。
final Provider<DriftSessionRepository> sessionRepositoryImplProvider =
    Provider<DriftSessionRepository>(
      (Ref ref) => DriftSessionRepository(ref.watch(databaseProvider)),
    );

final Provider<SessionRepository> sessionRepositoryProvider =
    Provider<SessionRepository>(
      (Ref ref) => ref.watch(sessionRepositoryImplProvider),
    );

/// 评分官工厂（T-033/T-035）：传入 sessionId 时启用预算与 `llm_calls` 记账。
final Provider<Future<ScoringEngine> Function(String sessionId)>
scoringEngineFactoryProvider =
    Provider<Future<ScoringEngine> Function(String sessionId)>((Ref ref) {
      return (String sessionId) async {
        final prompts = await ref.watch(promptRegistryProvider.future);
        final configs = await ref.watch(providerConfigsProvider.future);
        final scorer = configs.firstWhere(
          (ProviderConfig config) => config.role == ProviderRole.scorer,
          orElse: () => ProviderConfig.defaults(ProviderRole.scorer),
        );
        final key =
            await ref.watch(providerRepositoryProvider).loadKey(scorer.role) ??
            '';
        if (key.isEmpty) {
          throw const AuthFailure('scorer api key is missing');
        }
        final client = createLlmClient(
          scorer,
          key,
          logger: ref.watch(loggerProvider),
        );
        final recorded = LlmCallRecorder(
          inner: client,
          db: ref.watch(databaseProvider),
          role: 'scorer',
          providerId: scorer.role.name,
          sessionId: sessionId.isEmpty ? null : sessionId,
          logger: ref.watch(loggerProvider),
        );
        return ScoringEngine(
          client: recorded,
          prompts: prompts,
          model: scorer.model,
        );
      };
    });

class UsageSummary {
  const UsageSummary({required this.tokens});

  final int tokens;
}

/// 本月 token 用量（设置页展示，超过 80% 给软提示）。
final FutureProvider<UsageSummary>
usageSummaryProvider = FutureProvider<UsageSummary>((Ref ref) async {
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month);
  final rows = await (db.select(
    db.llmCalls,
  )..where((LlmCalls t) => t.createdAt.isBiggerOrEqualValue(monthStart))).get();
  var tokens = 0;
  for (final row in rows) {
    tokens += row.tokensIn + row.tokensOut;
  }
  return UsageSummary(tokens: tokens);
});

/// 实战报告（T-044 雏形）：finish 幂等，读取已落盘 turns 聚合。
final FutureProviderFamily<SessionReport?, String> mockReportProvider =
    FutureProvider.family<SessionReport?, String>((
      Ref ref,
      String sessionId,
    ) async {
      final repo = ref.watch(sessionRepositoryImplProvider);
      final session = await repo.byId(sessionId);
      if (session == null) return null;
      return repo.finish(sessionId);
    });

/// 面试官工厂（T-041）：与评分官分离，带成本记录；无 key/失败时 UI 回退本地题目。
final Provider<Future<InterviewerAgent> Function(String sessionId)>
interviewerAgentFactoryProvider =
    Provider<Future<InterviewerAgent> Function(String sessionId)>((Ref ref) {
      return (String sessionId) async {
        final prompts = await ref.watch(promptRegistryProvider.future);
        final configs = await ref.watch(providerConfigsProvider.future);
        final interviewer = configs.firstWhere(
          (ProviderConfig config) => config.role == ProviderRole.interviewer,
          orElse: () => ProviderConfig.defaults(ProviderRole.interviewer),
        );
        final key =
            await ref
                .watch(providerRepositoryProvider)
                .loadKey(interviewer.role) ??
            '';
        if (key.isEmpty) {
          throw const AuthFailure('interviewer api key is missing');
        }
        final client = createLlmClient(
          interviewer,
          key,
          logger: ref.watch(loggerProvider),
        );
        final recorded = LlmCallRecorder(
          inner: client,
          db: ref.watch(databaseProvider),
          role: 'interviewer',
          providerId: interviewer.role.name,
          sessionId: sessionId.isEmpty ? null : sessionId,
          logger: ref.watch(loggerProvider),
        );
        return InterviewerAgent(
          client: recorded,
          prompts: prompts,
          model: interviewer.model,
        );
      };
    });

final Provider<SessionMemoryStore> sessionMemoryStoreProvider =
    Provider<SessionMemoryStore>(
      (Ref ref) => SessionMemoryStore(ref.watch(databaseProvider)),
    );

/// 记忆抽取工厂（T-043），复用 interviewer 配置与预算/记账。
final Provider<Future<MemoryExtractor> Function(String sessionId)>
memoryExtractorFactoryProvider =
    Provider<Future<MemoryExtractor> Function(String sessionId)>((Ref ref) {
      return (String sessionId) async {
        final prompts = await ref.watch(promptRegistryProvider.future);
        final configs = await ref.watch(providerConfigsProvider.future);
        final config = configs.firstWhere(
          (ProviderConfig c) => c.role == ProviderRole.interviewer,
          orElse: () => ProviderConfig.defaults(ProviderRole.interviewer),
        );
        final key =
            await ref.watch(providerRepositoryProvider).loadKey(config.role) ??
            '';
        if (key.isEmpty) throw const AuthFailure('memory api key is missing');
        final client = createLlmClient(
          config,
          key,
          logger: ref.watch(loggerProvider),
        );
        final recorded = LlmCallRecorder(
          inner: client,
          db: ref.watch(databaseProvider),
          role: 'memory',
          providerId: config.role.name,
          sessionId: sessionId.isEmpty ? null : sessionId,
          logger: ref.watch(loggerProvider),
        );
        return MemoryExtractor(
          client: recorded,
          prompts: prompts,
          model: config.model,
        );
      };
    });

/// 联网核查（T-053）：无 Tavily key 或 scorer key 时返回 null，评分照常进行。
final FutureProvider<FactCheckService?>
factCheckServiceProvider = FutureProvider<FactCheckService?>((Ref ref) async {
  final configs = await ref.watch(providerConfigsProvider.future);
  final searchConfig = configs.firstWhere(
    (ProviderConfig c) => c.role == ProviderRole.search,
    orElse: () => ProviderConfig.defaults(ProviderRole.search),
  );
  final scorer = configs.firstWhere(
    (ProviderConfig c) => c.role == ProviderRole.scorer,
    orElse: () => ProviderConfig.defaults(ProviderRole.scorer),
  );
  final searchKey =
      await ref.watch(providerRepositoryProvider).loadKey(searchConfig.role) ??
      '';
  final scorerKey =
      await ref.watch(providerRepositoryProvider).loadKey(scorer.role) ?? '';
  if (searchKey.isEmpty || scorerKey.isEmpty) return null;
  final prompts = await ref.watch(promptRegistryProvider.future);
  final llm = createLlmClient(
    scorer,
    scorerKey,
    logger: ref.watch(loggerProvider),
  );
  final cache = DriftPageCache(ref.watch(databaseProvider));
  final useOpenAiSearch =
      !searchConfig.baseUrl.contains('tavily.com') ||
      searchConfig.model.trim() != 'tavily-search';
  final SearchProvider search = useOpenAiSearch
      ? OpenAiWebSearchProvider(
          apiKey: searchKey,
          baseUrl: Uri.parse(searchConfig.baseUrl),
          model: searchConfig.model,
          cache: cache,
        )
      : TavilySearchProvider(
          apiKey: searchKey,
          baseUrl: Uri.parse(searchConfig.baseUrl),
          cache: cache,
        );
  return FactCheckService(
    extractor: ClaimExtractor(
      client: llm,
      prompts: prompts,
      model: scorer.model,
    ),
    verifier: ClaimVerifier(
      search: search,
      judge: llm,
      prompts: prompts,
      model: scorer.model,
      cache: FactCheckCache(ref.watch(databaseProvider)),
    ),
  );
});

final Provider<AppealRepository> appealRepositoryProvider =
    Provider<AppealRepository>(
      (Ref ref) => AppealRepository(ref.watch(databaseProvider)),
    );

final Provider<QuestionGraphRepository> questionGraphRepositoryProvider =
    Provider<QuestionGraphRepository>(
      (Ref ref) => QuestionGraphRepository(
        ref.watch(databaseProvider),
        ref.watch(bankRepositoryImplProvider),
      ),
    );

final FutureProviderFamily<List<Question>, String> relatedQuestionsProvider =
    FutureProvider.family<List<Question>, String>((
      Ref ref,
      String questionId,
    ) async {
      final graph = ref.watch(questionGraphRepositoryProvider);
      // 只读缓存边；关系图重建放到离线工具，避免在打开详情时做重写入。
      return graph.relatedCached(questionId);
    });

/// TTS（T-061）：仅在配置了 tts provider key 时返回服务；否则纯文本降级。
final FutureProvider<TtsService?> ttsServiceProvider =
    FutureProvider<TtsService?>((Ref ref) async {
      final configs = await ref.watch(providerConfigsProvider.future);
      final config = configs.firstWhere(
        (ProviderConfig c) => c.role == ProviderRole.tts,
        orElse: () => ProviderConfig.defaults(ProviderRole.tts),
      );
      final key =
          await ref.watch(providerRepositoryProvider).loadKey(config.role) ??
          '';
      if (key.isEmpty) return null;
      final service = TtsService(
        provider: OpenAiTtsProvider(
          apiKey: key,
          baseUrl: Uri.parse(config.baseUrl),
          model: config.model,
        ),
        sink: JustAudioSink(),
      );
      ref.onDispose(service.dispose);
      return service;
    });

final Provider<GitHubRemoteImporter> githubRemoteImporterProvider =
    Provider<GitHubRemoteImporter>(
      (Ref ref) => GitHubRemoteImporter(
        transport: DioSearchTransport(),
        bulk: ref.watch(bulkImportServiceProvider),
      ),
    );

/// 面经抽取（T-022）：依赖评分官配置；未配置 key 时返回 null。
final FutureProvider<ExperienceExtractor?> experienceExtractorProvider =
    FutureProvider<ExperienceExtractor?>((Ref ref) async {
      final configs = await ref.watch(providerConfigsProvider.future);
      final config = configs.firstWhere(
        (ProviderConfig c) => c.role == ProviderRole.scorer,
        orElse: () => ProviderConfig.defaults(ProviderRole.scorer),
      );
      final key =
          await ref.watch(providerRepositoryProvider).loadKey(config.role) ??
          '';
      if (key.isEmpty) return null;
      final prompts = await ref.watch(promptRegistryProvider.future);
      return ExperienceExtractor(
        client: createLlmClient(config, key, logger: ref.watch(loggerProvider)),
        prompts: prompts,
        model: config.model,
      );
    });

/// 本地 bge 模型（T-024）；加载失败返回 null，题库回退 FTS。
final FutureProvider<EmbeddingProvider?> embeddingProvider =
    FutureProvider<EmbeddingProvider?>((Ref ref) async {
      final provider = await OnnxBgeEmbeddingProvider.create();
      if (provider == null) return null;
      ref.onDispose(provider.dispose);
      return provider;
    });

final FutureProvider<HybridSearchEngine?> hybridSearchEngineProvider =
    FutureProvider<HybridSearchEngine?>((Ref ref) async {
      final embedding = await ref.watch(embeddingProvider.future);
      if (embedding == null) return null;
      return HybridSearchEngine(
        repository: ref.watch(bankRepositoryImplProvider),
        embedding: embedding,
      );
    });
