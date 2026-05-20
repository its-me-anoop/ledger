import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/core/result/result.dart';

void main() {
  group('Ok', () {
    test('carries value', () {
      const result = Ok<int, String>(42);
      expect(result.isOk, isTrue);
      expect(result.isErr, isFalse);
      expect(result.value, 42);
    });

    test('when calls ok branch', () {
      const result = Ok<int, String>(10);
      final output = result.when(
        ok: (v) => 'ok:$v',
        err: (e) => 'err:$e',
      );
      expect(output, 'ok:10');
    });
  });

  group('Err', () {
    test('carries error', () {
      const result = Err<int, String>('boom');
      expect(result.isErr, isTrue);
      expect(result.isOk, isFalse);
      expect(result.error, 'boom');
    });

    test('when calls err branch', () {
      const result = Err<int, String>('fail');
      final output = result.when(
        ok: (v) => 'ok:$v',
        err: (e) => 'err:$e',
      );
      expect(output, 'err:fail');
    });
  });

  test('when discriminates Ok vs Err correctly', () {
    final results = <Result<int, String>>[
      const Ok(1),
      const Err('e'),
      const Ok(2),
    ];
    final labels = results.map(
      (r) => r.when(ok: (v) => 'ok', err: (e) => 'err'),
    );
    expect(labels.toList(), ['ok', 'err', 'ok']);
  });
}
