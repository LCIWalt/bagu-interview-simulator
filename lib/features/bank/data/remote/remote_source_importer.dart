import 'dart:convert';

import 'package:mockmate/core/search/search_transport.dart';

import '../import/bank_import_service.dart' show ImportConflictPolicy;
import '../import_bulk/bulk_import_service.dart';

class RemoteImportFailure implements Exception {
  const RemoteImportFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class RemoteRepoRef {
  const RemoteRepoRef({
    required this.owner,
    required this.repo,
    this.ref,
    this.filePath,
  });

  final String owner;
  final String repo;
  final String? ref;
  final String? filePath;

  String get slug => '$owner/$repo';
}

class RemoteFilePreview {
  const RemoteFilePreview({required this.path, required this.preview});

  final String path;
  final BulkImportPreview preview;
}

class RemoteImportPreview {
  const RemoteImportPreview({
    required this.repo,
    required this.license,
    required this.files,
  });

  final RemoteRepoRef repo;
  final String license;
  final List<RemoteFilePreview> files;

  int get total => files.fold(
    0,
    (int sum, RemoteFilePreview file) => sum + file.preview.items.length,
  );
  int get valid => files.fold(
    0,
    (int sum, RemoteFilePreview file) => sum + file.preview.validCount,
  );
  int get invalid => total - valid;
  int get conflicts => files.fold(
    0,
    (int sum, RemoteFilePreview file) => sum + file.preview.conflictCount,
  );
  bool get canImport => total > 0 && invalid == 0;
}

/// T-023：GitHub 仓库/单文件导入，先校验 license，再抓取、预览、入库。
class GitHubRemoteImporter {
  GitHubRemoteImporter({
    required this.transport,
    required this.bulk,
    this.apiBase = 'https://api.github.com',
    this.rawBase = 'https://raw.githubusercontent.com',
    this.token,
    this.maxFiles = 20,
    this.maxFileBytes = 2 * 1024 * 1024,
    this.maxTotalBytes = 8 * 1024 * 1024,
  });

  final SearchTransport transport;
  final BulkImportService bulk;
  final String apiBase;
  final String rawBase;
  final String? token;
  final int maxFiles;
  final int maxFileBytes;
  final int maxTotalBytes;

  static const Set<String> allowedLicenses = <String>{
    'MIT',
    'Apache-2.0',
    'BSD-2-Clause',
    'BSD-3-Clause',
    'ISC',
    'CC-BY-4.0',
    'CC-BY-3.0',
    'CC0-1.0',
  };

  RemoteRepoRef parseUrl(String input) {
    final uri = Uri.tryParse(input.trim());
    if (uri == null || uri.scheme != 'https') {
      throw const RemoteImportFailure('只支持 https 的 GitHub 链接');
    }
    final segments = uri.pathSegments
        .where((String s) => s.isNotEmpty)
        .toList();
    if (uri.host == 'raw.githubusercontent.com' && segments.length >= 4) {
      return RemoteRepoRef(
        owner: segments[0],
        repo: segments[1],
        ref: segments[2],
        filePath: segments.skip(3).join('/'),
      );
    }
    if (uri.host == 'github.com' && segments.length >= 2) {
      final owner = segments[0];
      final repo = segments[1].replaceAll(RegExp(r'\.git$'), '');
      if (segments.length >= 5 && segments[2] == 'blob') {
        return RemoteRepoRef(
          owner: owner,
          repo: repo,
          ref: segments[3],
          filePath: segments.skip(4).join('/'),
        );
      }
      return RemoteRepoRef(owner: owner, repo: repo);
    }
    if (uri.host == 'api.github.com' &&
        segments.length >= 3 &&
        segments[0] == 'repos') {
      return RemoteRepoRef(owner: segments[1], repo: segments[2]);
    }
    throw const RemoteImportFailure(
      '仅支持 github.com / raw.githubusercontent.com 链接',
    );
  }

  Future<RemoteImportPreview> preview(String input) async {
    final repo = parseUrl(input);
    final license = await _license(repo);
    final files = await _files(repo);
    final previews = <RemoteFilePreview>[];
    for (final file in files) {
      final content = await _readText(_rawUri(repo, file.path));
      final preview = await bulk.preview(content);
      previews.add(RemoteFilePreview(path: file.path, preview: preview));
    }
    return RemoteImportPreview(repo: repo, license: license, files: previews);
  }

  Future<int> commit(
    RemoteImportPreview preview, {
    required ImportConflictPolicy policy,
  }) async {
    if (!preview.canImport) {
      throw const RemoteImportFailure('存在无效行，修复后再导入');
    }
    var imported = 0;
    for (final file in preview.files) {
      final outcome = await bulk.commit(
        file.preview,
        policy: policy,
        origin: 'github:${preview.repo.slug}',
      );
      imported += outcome.created + outcome.overwritten + outcome.merged;
    }
    return imported;
  }

  Future<String> _license(RemoteRepoRef repo) async {
    final uri = Uri.parse('$apiBase/repos/${repo.owner}/${repo.repo}/license');
    final response = await transport.get(uri, headers: _headers);
    if (response.statusCode == 404) {
      throw const RemoteImportFailure('仓库没有 LICENSE，拒绝导入');
    }
    _checkStatus(response.statusCode);
    final json = await _readJson(response.body);
    final license =
        (json['license'] as Map<String, dynamic>?)?['spdx_id']?.toString() ??
        '';
    if (!allowedLicenses.contains(license)) {
      throw RemoteImportFailure(
        '许可证 $license 不在允许列表：${allowedLicenses.join(', ')}',
      );
    }
    return license;
  }

  Future<List<_TreeFile>> _files(RemoteRepoRef repo) async {
    if (repo.filePath != null) {
      return <_TreeFile>[_TreeFile(repo.filePath!, 0)];
    }
    final info = await transport.get(
      Uri.parse('$apiBase/repos/${repo.owner}/${repo.repo}'),
      headers: _headers,
    );
    _checkStatus(info.statusCode);
    final infoJson = await _readJson(info.body);
    final ref = repo.ref ?? infoJson['default_branch']?.toString() ?? 'main';
    final tree = await transport.get(
      Uri.parse(
        '$apiBase/repos/${repo.owner}/${repo.repo}/git/trees/$ref?recursive=1',
      ),
      headers: _headers,
    );
    _checkStatus(tree.statusCode);
    final treeJson = await _readJson(tree.body);
    final entries = treeJson['tree'];
    if (entries is! List) throw const RemoteImportFailure('仓库文件树为空');
    final files = <_TreeFile>[];
    var total = 0;
    for (final entry in entries) {
      if (entry is! Map<String, dynamic>) continue;
      if (entry['type'] != 'blob') continue;
      final path = entry['path']?.toString() ?? '';
      if (!_isQuestionFile(path)) continue;
      final size = (entry['size'] as num?)?.toInt() ?? 0;
      if (size > maxFileBytes) {
        throw RemoteImportFailure('文件过大：$path（${size ~/ 1024}KB）');
      }
      total += size;
      if (total > maxTotalBytes) {
        throw const RemoteImportFailure('仓库题目内容超过 8MB 限制');
      }
      files.add(_TreeFile(path, size));
    }
    if (files.isEmpty) {
      throw const RemoteImportFailure('仓库里没有 .yaml/.yml/.json/.md 题目文件');
    }
    files.sort((_TreeFile a, _TreeFile b) => a.path.compareTo(b.path));
    if (files.length > maxFiles) {
      files.removeRange(maxFiles, files.length);
    }
    return files;
  }

  bool _isQuestionFile(String path) {
    final lower = path.toLowerCase();
    if (!(lower.endsWith('.yaml') ||
        lower.endsWith('.yml') ||
        lower.endsWith('.json') ||
        lower.endsWith('.md'))) {
      return false;
    }
    if (lower.contains('license') || lower.contains('readme')) return false;
    return true;
  }

  Uri _rawUri(RemoteRepoRef repo, String path) {
    final ref = repo.ref ?? 'main';
    return Uri.parse(
      '$rawBase/${repo.owner}/${repo.repo}/$ref/${Uri.encodeFull(path)}',
    );
  }

  Map<String, String> get _headers => <String, String>{
    'Accept': 'application/vnd.github+json',
    'User-Agent': 'MockMate/0.5',
    if (token != null && token!.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  void _checkStatus(int status) {
    if (status == 401 || status == 403) {
      throw const RemoteImportFailure('GitHub 拒绝访问（未授权或超出速率限制），请稍后重试');
    }
    if (status == 404) throw const RemoteImportFailure('GitHub 资源不存在');
    if (status == 429) throw const RemoteImportFailure('GitHub 速率限制，请稍后重试');
    if (status < 200 || status >= 300) {
      throw RemoteImportFailure('GitHub HTTP $status');
    }
  }

  Future<Map<String, dynamic>> _readJson(Stream<List<int>> body) async {
    final text = await _read(body);
    try {
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) {
        throw const RemoteImportFailure('GitHub 响应不是对象');
      }
      return decoded;
    } on FormatException {
      throw const RemoteImportFailure('GitHub 响应不是合法 JSON');
    }
  }

  Future<String> _readText(Uri uri) async {
    final response = await transport.get(
      uri,
      headers: <String, String>{'User-Agent': 'MockMate/0.5'},
    );
    _checkStatus(response.statusCode);
    return _read(response.body);
  }

  Future<String> _read(Stream<List<int>> body, {int? maxBytes}) async {
    final bytes = <int>[];
    await for (final chunk in body) {
      if (bytes.length + chunk.length > (maxBytes ?? maxFileBytes)) {
        throw const RemoteImportFailure('文件超过大小限制');
      }
      bytes.addAll(chunk);
    }
    return utf8.decode(bytes, allowMalformed: true);
  }
}

class _TreeFile {
  const _TreeFile(this.path, this.size);

  final String path;
  final int size;
}
