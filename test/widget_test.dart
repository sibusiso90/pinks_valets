import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pinks_valets/main.dart';

void main() {
  testWidgets("App boots without throwing", (tester) async {
    // Pretend to be an iPhone 14 Pro; the default 800×600 canvas won't fit
    // the welcome screen's hero typography.
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ProviderScope(child: PinksApp()));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(PinksApp), findsOneWidget);
  });
}
