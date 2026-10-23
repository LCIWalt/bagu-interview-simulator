import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/contracts/contracts.dart';
import '../../../core/db/app_database.dart';
import '../data/bank_repository_impl.dart'
    show BankRepositoryImpl, TopicCount, BankTopics;
import '../data/search/hybrid_search.dart';

@immutable
class BankQuery {
  const BankQuery({this.text = '', this.role, this.difficulty, this.topic});

  final String text;
  final String? role;
  final int? difficulty;
  final String? topic;

  BankQuery copyWith({
    String? text,
    String? role,
    int? difficulty,
    String? topic,
    bool clearRole = false,
    bool clearDifficulty = false,
    bool clearTopic = false,
  }) {
    return BankQuery(
      text: text ?? this.text,
      role: clearRole ? null : (role ?? this.role),
      difficulty: clearDifficulty ? null : (difficulty ?? this.difficulty),
      topic: clearTopic ? null : (topic ?? this.topic),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BankQuery &&
      other.text == text &&
      other.role == role &&
      other.difficulty == difficulty &&
      other.topic == topic;

  @override
  int get hashCode => Object.hash(text, role, difficulty, topic);
}

/// 搜索输入 300ms 防抖（T-014 验收）。
class BankQueryController extends StateNotifier<BankQuery> {
  BankQueryController() : super(const BankQuery());

  static const Duration debounce = Duration(milliseconds: 300);
  Timer? _timer;

  void search(String text) {
    _timer?.cancel();
    _timer = Timer(debounce, () => state = state.copyWith(text: text.trim()));
  }

  void setRole(String? role) {
    _timer?.cancel();
    state = state.copyWith(clearRole: role == null, role: role);
  }

  void setDifficulty(int? difficulty) {
    state = state.copyWith(
      clearDifficulty: difficulty == null,
      difficulty: difficulty,
    );
  }

  void setTopic(String? topic) {
    state = state.copyWith(clearTopic: topic == null, topic: topic);
  }

  void clearFilters() {
    _timer?.cancel();
    state = const BankQuery();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final StateNotifierProvider<BankQueryController, BankQuery> bankQueryProvider =
    StateNotifierProvider<BankQueryController, BankQuery>(
      (Ref ref) => BankQueryController(),
    );

@immutable
class BankResults {
  const BankResults({
    required this.query,
    required this.questions,
    required this.hasMore,
    this.loadingMore = false,
  });

  final BankQuery query;
  final List<Question> questions;
  final bool hasMore;
  final bool loadingMore;

  BankResults copyWith({
    List<Question>? questions,
    bool? hasMore,
    bool? loadingMore,
  }) {
    return BankResults(
      query: query,
      questions: questions ?? this.questions,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
    );
  }
}

class BankResultsController extends AsyncNotifier<BankResults> {
  static const int pageSize = 30;

  @override
  Future<BankResults> build() async {
    final query = ref.watch(bankQueryProvider);
    await ref.watch(seedBankProvider.future);
    final questions = await _search(query, 0);
    return BankResults(
      query: query,
      questions: questions,
      hasMore: questions.length == pageSize,
    );
  }

  Future<List<Question>> _search(BankQuery query, int offset) async {
    final repository = ref.read(bankRepositoryProvider);
    final prefs = ref.read(preferencesProvider).valueOrNull;
    final request = QuestionQuery(
      text: query.text,
      role: query.role,
      difficulty: query.difficulty,
      topics: query.topic == null ? const <String>[] : <String>[query.topic!],
      limit: pageSize,
      offset: offset,
    );
    if (prefs?.semanticSearch == true &&
        query.text.trim().isNotEmpty &&
        repository is BankRepositoryImpl) {
      final embedding = await ref.read(embeddingProvider.future);
      if (embedding != null) {
        return HybridSearchEngine(
          repository: repository,
          embedding: embedding,
        ).search(request);
      }
    }
    return repository.search(request);
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.loadingMore) return;
    state = AsyncData(current.copyWith(loadingMore: true));
    try {
      final more = await _search(current.query, current.questions.length);
      state = AsyncData(
        current.copyWith(
          questions: <Question>[...current.questions, ...more],
          hasMore: more.length == pageSize,
          loadingMore: false,
        ),
      );
    } on Object {
      state = AsyncData(current.copyWith(loadingMore: false));
      rethrow;
    }
  }

  Future<void> retry() async {
    ref.invalidateSelf();
    await future;
  }
}

final AsyncNotifierProvider<BankResultsController, BankResults>
bankResultsProvider = AsyncNotifierProvider<BankResultsController, BankResults>(
  BankResultsController.new,
);

/// 题目详情。
final AutoDisposeFutureProviderFamily<Question?, String>
questionDetailProvider = FutureProvider.autoDispose.family<Question?, String>(
  (Ref ref, String id) => ref.watch(bankRepositoryProvider).byId(id),
);

/// 用户覆盖层（笔记/收藏/隐藏）。
final AutoDisposeFutureProviderFamily<QuestionLocalRow?, String>
questionLocalProvider = FutureProvider.autoDispose
    .family<QuestionLocalRow?, String>(
      (Ref ref, String id) =>
          ref.watch(questionLocalRepositoryProvider).get(id),
    );

/// 历史作答。
final AutoDisposeFutureProviderFamily<List<TurnRow>, String>
questionHistoryProvider = FutureProvider.autoDispose
    .family<List<TurnRow>, String>(
      (Ref ref, String id) =>
          ref.watch(questionLocalRepositoryProvider).historyFor(id),
    );

/// 已安装题库 manifest（更新页/设置页展示版本）。
final FutureProvider<BankManifest?> installedManifestProvider =
    FutureProvider<BankManifest?>(
      (Ref ref) => ref.watch(bankRepositoryProvider).installed(),
    );

/// 角色 → 主题（分类树数据）。
final FutureProvider<Map<String, List<TopicCount>>> bankTopicTreeProvider =
    FutureProvider<Map<String, List<TopicCount>>>(
      (Ref ref) => ref.watch(bankRepositoryImplProvider).topicsByRole(),
    );
