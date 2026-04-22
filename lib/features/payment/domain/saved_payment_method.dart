enum PaymentMethodKind { card, applePay, googlePay, instantEft }

class SavedPaymentMethod {
  const SavedPaymentMethod({
    required this.id,
    required this.kind,
    required this.label,
    this.last4,
    this.expiry,
    this.brand,
    this.isDefault = false,
  });

  final String id;
  final PaymentMethodKind kind;
  final String label;
  final String? last4;
  final String? expiry;
  final String? brand;
  final bool isDefault;

  SavedPaymentMethod copyWith({
    String? id,
    PaymentMethodKind? kind,
    String? label,
    String? last4,
    String? expiry,
    String? brand,
    bool? isDefault,
  }) {
    return SavedPaymentMethod(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      label: label ?? this.label,
      last4: last4 ?? this.last4,
      expiry: expiry ?? this.expiry,
      brand: brand ?? this.brand,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
