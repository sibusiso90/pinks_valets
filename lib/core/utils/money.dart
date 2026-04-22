/// Format cents as a Rand string, SA style: R350, R1 250, R12 450.
String formatRand(int cents) {
  final whole = (cents / 100).round();
  final s = whole.toString();
  if (s.length <= 3) return 'R$s';
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    // Insert a thin space every 3 digits, counting from the right.
    final fromRight = s.length - i;
    if (i > 0 && fromRight % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return 'R$buf';
}

/// 350 -> 35000 cents. Convenience for fixtures & tests.
int rands(num rand) => (rand * 100).round();
