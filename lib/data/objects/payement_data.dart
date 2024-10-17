class PaymentData {
  String? cardNumber;
  String? expirationDate;
  String? cardOwner;
  String? cvv;
  String? paymentMethod;

  PaymentData({
    this.cardNumber,
    this.expirationDate,
    this.cardOwner,
    this.cvv,
    this.paymentMethod,
  });

  Map<String, dynamic> toMap() {
    return {
      'card_number': cardNumber,
      'expiration_date': expirationDate,
      'card_owner': cardOwner,
      'cvv': cvv,
      'payment_method': paymentMethod,
    };
  }

  factory PaymentData.fromMap(Map<String, dynamic> map) {
    return PaymentData(
      cardNumber: map['card_number'] ?? '',
      expirationDate: map['expiration_date'] ?? '',
      cardOwner: map['card_owner'] ?? '',
      cvv: map['cvv'] ?? '',
      paymentMethod: map['payment_method'] ?? '',
    );
  }
}