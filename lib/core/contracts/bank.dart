import 'failure.dart';

/// 题库通道。[mirror] 用于镜像站，与稳定版 schema 相同。
enum BankChannel { stable, beta, mirror }

enum QuestionType { knowledge, behavioral, systemDesign, coding, project }

/// `verified` 人工校对 · `community` 社区/面经待校 · `ai-draft` 占位。
/// 另外 `user` 表示用户自建（存于 question_local，指南 §7.1.1）。
enum QuestionStatus { verified, community, aiDraft, user, orphaned }

class BankFileEntry {
  const BankFileEntry({
    required this.path,
    required this.sha256,
    required this.bytes,
  });

  final String path;
  final String sha256;
  final int bytes;
}

class BankAsset {
  const BankAsset({
    required this.name,
    required this.sha256,
    required this.bytes,
  });

  final String name;
  final String sha256;
  final int bytes;
}

/// 题库清单（`manifest.json`），Ed25519 验签对象（指南 §6.2/§6.3）。
class BankManifest {
  const BankManifest({
    required this.schemaVersion,
    required this.bankVersion,
    required this.minAppVersion,
    required this.generatedAt,
    required this.gitCommit,
    required this.questionCount,
    required this.experienceCount,
    required this.files,
    required this.assets,
    required this.signature,
  });

  final int schemaVersion;
  final String bankVersion;
  final String minAppVersion;
  final DateTime generatedAt;
  final String gitCommit;
  final int questionCount;
  final int experienceCount;
  final List<BankFileEntry> files;
  final List<BankAsset> assets;
  final String signature;

  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'bankVersion': bankVersion,
    'minAppVersion': minAppVersion,
    'generatedAt': generatedAt.toUtc().toIso8601String(),
    'gitCommit': gitCommit,
    'counts': <String, Object?>{
      'questions': questionCount,
      'experiences': experienceCount,
    },
    'files': files
        .map(
          (f) => <String, Object?>{
            'path': f.path,
            'sha256': f.sha256,
            'bytes': f.bytes,
          },
        )
        .toList(growable: false),
    'assets': assets
        .map(
          (a) => <String, Object?>{
            'name': a.name,
            'sha256': a.sha256,
            'bytes': a.bytes,
          },
        )
        .toList(growable: false),
    'signature': signature,
  };
}

/// 更新进度事件（UI 直接消费）。
sealed class BankUpdateProgress {
  const BankUpdateProgress();
}

final class BankChecking extends BankUpdateProgress {
  const BankChecking();
}

final class BankDownloading extends BankUpdateProgress {
  const BankDownloading({
    required this.receivedBytes,
    required this.totalBytes,
  });

  final int receivedBytes;
  final int totalBytes;

  double get fraction => totalBytes <= 0 ? 0 : receivedBytes / totalBytes;
}

final class BankVerifying extends BankUpdateProgress {
  const BankVerifying(this.stage);

  /// `sha256` / `signature` / `schema`
  final String stage;
}

final class BankActivating extends BankUpdateProgress {
  const BankActivating(this.version);
  final String version;
}

final class BankUpdated extends BankUpdateProgress {
  const BankUpdated(this.manifest);
  final BankManifest manifest;
}

/// 已是最新版本（ETag 304 或版本不高于本地）。
final class BankUpToDate extends BankUpdateProgress {
  const BankUpToDate(this.manifest);
  final BankManifest? manifest;
}

final class BankUpdateFailed extends BankUpdateProgress {
  const BankUpdateFailed(this.failure, {this.rolledBack = true});
  final Failure failure;
  final bool rolledBack;
}

/// 题目来源。
class QuestionSource {
  const QuestionSource({
    required this.url,
    required this.title,
    required this.license,
    this.retrievedAt,
  });

  final String url;
  final String title;
  final String license;
  final DateTime? retrievedAt;
}

/// 参考答案与评分点。评分只按 `keyPoints` 二值判定（指南 §7.3.2）。
class QuestionAnswer {
  const QuestionAnswer({
    required this.summary,
    required this.keyPoints,
    this.pitfalls = const <String>[],
  });

  final String summary;
  final List<String> keyPoints;
  final List<String> pitfalls;
}

class Question {
  const Question({
    required this.id,
    required this.bankVersion,
    required this.title,
    required this.bodyMarkdown,
    required this.topics,
    required this.role,
    required this.level,
    required this.difficulty,
    required this.type,
    required this.answer,
    this.followups = const <String>[],
    this.source,
    this.status = QuestionStatus.community,
    this.updatedAt,
  });

  final String id;
  final String bankVersion;
  final String title;
  final String bodyMarkdown;
  final List<String> topics;
  final String role;

  /// 1 = junior … 5 = staff
  final int level;

  /// 题目难度 1–5
  final int difficulty;
  final QuestionType type;
  final QuestionAnswer answer;
  final List<String> followups;
  final QuestionSource? source;
  final QuestionStatus status;
  final DateTime? updatedAt;
}

/// 混合检索的输入（FTS + 向量 + 结构化过滤）。
class QuestionQuery {
  const QuestionQuery({
    this.text = '',
    this.topics = const <String>[],
    this.role,
    this.level,
    this.difficulty,
    this.statuses = const <QuestionStatus>[],
    this.limit = 20,
    this.offset = 0,
  });

  final String text;
  final List<String> topics;
  final String? role;
  final int? level;
  final int? difficulty;
  final List<QuestionStatus> statuses;
  final int limit;
  final int offset;
}

abstract interface class BankRepository {
  Future<BankManifest?> installed();

  Stream<BankUpdateProgress> update({
    required BankChannel channel,
    bool force = false,
  });

  Future<List<Question>> search(QuestionQuery q);

  Future<Question?> byId(String id);
}
