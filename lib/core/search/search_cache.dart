import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';

import '../contracts/contracts.dart';
import '../db/app_database.dart';
import 'domain_authority.dart';

abstract interface class PageCache {
  Future<ExtractedPage?> get(String url);

  Future<void> put(
    ExtractedPage page, {
    Duration ttl = const Duration(hours: 24),
  });
}

class DriftPageCache implements PageCache {
  DriftPageCache(this._db);

  final AppDatabase _db;

  @override
  Future<ExtractedPage?> get(String url) async {
    final hash = sha256.convert(utf8.encode(url)).toString();
    final row = await (_db.select(
      _db.searchCache,
    )..where((SearchCache t) => t.urlHash.equals(hash))).getSingleOrNull();
    if (row == null) return null;
    if (DateTime.now().difference(row.fetchedAt) >
        Duration(seconds: row.ttlS)) {
      return null;
    }
    return ExtractedPage(
      url: row.url,
      title: row.title,
      textMarkdown: row.textMd,
      fetchedAt: row.fetchedAt,
      authority: DomainAuthority.classify(row.url),
    );
  }

  @override
  Future<void> put(
    ExtractedPage page, {
    Duration ttl = const Duration(hours: 24),
  }) async {
    await _db
        .into(_db.searchCache)
        .insertOnConflictUpdate(
          SearchCacheCompanion.insert(
            urlHash: sha256.convert(utf8.encode(page.url)).toString(),
            url: page.url,
            title: Value(page.title),
            textMd: page.textMarkdown,
            fetchedAt: page.fetchedAt,
            ttlS: Value(ttl.inSeconds),
          ),
        );
  }
}
