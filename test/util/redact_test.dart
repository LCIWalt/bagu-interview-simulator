import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/core/util/redact.dart';

void main() {
  group('redact', () {
    test('masks sk- keys and bearer tokens', () {
      expect(redact('key=sk-abcdef123456'), isNot(contains('abcdef123456')));
      expect(
        redact('Authorization: Bearer abc.def.ghi'),
        'Authorization: Bearer ***',
      );
    });

    test('masks api_key/secret assignments', () {
      expect(redact('api_key: "abcd1234"'), 'api_key=***');
      expect(redact('secret=supersecret'), 'secret=***');
    });

    test('masks emails, phone numbers and internal hosts', () {
      expect(
        redact('mail foo.bar@example.com now'),
        'mail f***@example.com now',
      );
      expect(redact('call 13812348000 now'), 'call 138****8000 now');
      expect(redact('host db01.corp.internal'), 'host ***.internal');
    });

    test('truncates long payloads', () {
      final redacted = redact('x' * 50, maxLength: 10);
      expect(redacted, 'xxxxxxxxxx…[truncated]');
    });

    test('keeps ordinary text untouched', () {
      expect(redact('Go 的 GMP 模型里，为什么需要 P？'), 'Go 的 GMP 模型里，为什么需要 P？');
    });
  });
}
