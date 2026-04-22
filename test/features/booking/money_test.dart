import 'package:flutter_test/flutter_test.dart';
import 'package:pinks_valets/core/utils/money.dart';

void main() {
  group('formatRand', () {
    test('small amounts', () {
      expect(formatRand(0), 'R0');
      expect(formatRand(100), 'R1');
      expect(formatRand(15000), 'R150');
      expect(formatRand(35000), 'R350');
    });

    test('thousand separator uses space, SA convention', () {
      expect(formatRand(100000), 'R1 000');
      expect(formatRand(1250000), 'R12 500');
      expect(formatRand(125000000), 'R1 250 000');
    });

    test('rounds cents to nearest whole rand', () {
      expect(formatRand(15049), 'R150');
      expect(formatRand(15050), 'R151');
    });
  });
}
