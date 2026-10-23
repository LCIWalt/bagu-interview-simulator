import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/features/bank/data/update/bank_archive.dart';

void main() {
  const archive = BankArchive();

  test('extracts tar.gz and tar.zst fixtures', () {
    for (final name in <String>[
      'bank_archive.tar.gz',
      'bank_archive.tar.zst',
    ]) {
      final bytes = File('test/fixtures/$name').readAsBytesSync();
      final files = archive.extract(bytes);
      expect(
        files.keys,
        contains('questions/backend/upd-001.yaml'),
        reason: name,
      );
      expect(
        utf8.decode(files['questions/backend/upd-001.yaml']!),
        contains('upd-001'),
      );
    }
  });

  test('extracts zip', () {
    final zip = Archive()
      ..addFile(
        ArchiveFile(
          'questions/backend/zip-001.yaml',
          utf8.encode('id: zip-001').length,
          utf8.encode('id: zip-001'),
        ),
      );
    final bytes = Uint8List.fromList(ZipEncoder().encode(zip));
    expect(
      archive.extract(bytes).keys,
      contains('questions/backend/zip-001.yaml'),
    );
  });

  test('rejects path traversal and absolute paths', () {
    expect(BankArchive.sanitizeEntryPath('../evil.yaml'), isNull);
    expect(BankArchive.sanitizeEntryPath('/etc/passwd'), isNull);
    expect(BankArchive.sanitizeEntryPath('C:\\evil'), isNull);
    expect(BankArchive.sanitizeEntryPath('a/../../b'), isNull);
    expect(BankArchive.sanitizeEntryPath('./a//b'), 'a/b');
  });

  test('rejects zip-slip entries at extraction', () {
    final zip = Archive()
      ..addFile(ArchiveFile('../evil.yaml', 4, utf8.encode('evil')));
    final bytes = Uint8List.fromList(ZipEncoder().encode(zip));
    expect(() => archive.extract(bytes), throwsFormatException);
  });

  test('enforces uncompressed size cap', () {
    final zip = Archive()
      ..addFile(ArchiveFile('big.yaml', 1024, List<int>.filled(1024, 65)));
    final bytes = Uint8List.fromList(ZipEncoder().encode(zip));
    expect(
      () => const BankArchive(maxUncompressedBytes: 10).extract(bytes),
      throwsFormatException,
    );
  });
}
