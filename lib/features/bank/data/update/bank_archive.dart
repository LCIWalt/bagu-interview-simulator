import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:pure_zstd/pure_zstd.dart';

/// 题库更新包解包：支持 `.tar.zst`（指南 §6.3）、`.tar.gz`、`.zip`、裸 tar。
///
/// 只返回文件内容，不落盘；路径必须相对且不能逃逸（防 zip-slip）。
class BankArchive {
  const BankArchive({this.maxUncompressedBytes = 100 * 1024 * 1024});

  final int maxUncompressedBytes;

  Map<String, Uint8List> extract(Uint8List bytes) {
    final payload = _decompress(bytes);
    final Archive archive;
    if (_isZip(bytes)) {
      archive = ZipDecoder().decodeBytes(payload, verify: true);
    } else {
      archive = TarDecoder().decodeBytes(payload, verify: true);
    }

    final files = <String, Uint8List>{};
    var total = 0;
    for (final entry in archive.files) {
      if (!entry.isFile) continue;
      final path = sanitizeEntryPath(entry.name);
      if (path == null) {
        throw const FormatException('题库包包含非法路径');
      }
      total += entry.size;
      if (total > maxUncompressedBytes) {
        throw const FormatException('题库包解压后超过大小上限');
      }
      files[path] = entry.content;
    }
    if (files.isEmpty) {
      throw const FormatException('题库包为空');
    }
    return files;
  }

  Uint8List _decompress(Uint8List bytes) {
    if (bytes.length < 4) throw const FormatException('题库包过短');
    if (_isZstd(bytes)) {
      try {
        return Uint8List.fromList(zstdDecode(bytes));
      } on Object catch (error) {
        throw FormatException('zstd 解压失败: $error');
      }
    }
    if (_isGzip(bytes)) {
      try {
        return Uint8List.fromList(GZipDecoder().decodeBytes(bytes));
      } on Object catch (error) {
        throw FormatException('gzip 解压失败: $error');
      }
    }
    return bytes;
  }

  static bool _isZstd(Uint8List b) =>
      b.length >= 4 &&
      b[0] == 0x28 &&
      b[1] == 0xB5 &&
      b[2] == 0x2F &&
      b[3] == 0xFD;
  static bool _isGzip(Uint8List b) =>
      b.length >= 2 && b[0] == 0x1F && b[1] == 0x8B;
  static bool _isZip(Uint8List b) =>
      b.length >= 4 &&
      b[0] == 0x50 &&
      b[1] == 0x4B &&
      b[2] == 0x03 &&
      b[3] == 0x04;

  /// 返回安全的 POSIX 相对路径；`..`、绝对路径、盘符、空段一律拒绝。
  static String? sanitizeEntryPath(String raw) {
    final normalized = raw.replaceAll('\\', '/');
    if (normalized.startsWith('/') ||
        RegExp(r'^[A-Za-z]:').hasMatch(normalized)) {
      return null;
    }
    final parts = <String>[];
    for (final part in normalized.split('/')) {
      if (part.isEmpty || part == '.') continue;
      if (part == '..') {
        return null;
      }
      parts.add(part);
    }
    if (parts.isEmpty) return null;
    return parts.join('/');
  }
}
