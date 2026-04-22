/// Stubbed payment service per BuildSpec_MobileApp.md §0. Always succeeds
/// after a 2-second delay. Real PayFast / Stripe adapters will replace this
/// by implementing PaymentService.
abstract class PaymentService {
  Future<PaymentResult> charge({
    required String bookingId,
    required int amountCents,
    required String method, // "card" | "apple_pay" | "instant_eft"
  });
}

class PaymentResult {
  const PaymentResult({
    required this.success,
    required this.paymentId,
    this.errorMessage,
  });

  final bool success;
  final String paymentId;
  final String? errorMessage;
}

class FakePaymentService implements PaymentService {
  @override
  Future<PaymentResult> charge({
    required String bookingId,
    required int amountCents,
    required String method,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    return PaymentResult(
      success: true,
      paymentId: 'fake-${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}
