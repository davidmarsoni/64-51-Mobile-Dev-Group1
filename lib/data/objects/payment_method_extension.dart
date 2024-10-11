import 'package:valais_roll/data/enums/payement_data.dart';

extension PaymentMethodExtension on PaymentMethod {
  String get name {
    switch (this) {
      case PaymentMethod.creditCard:
        return 'credit_card';
      case PaymentMethod.googlePay:
        return 'google_pay';
      case PaymentMethod.klarna:
        return 'klarna';
      case PaymentMethod.other:
        return 'other';
      case PaymentMethod.notSet:
        return 'not_set';
    }
  }

  static PaymentMethod fromString(String value) {
    switch (value) {
      case 'credit_card':
        return PaymentMethod.creditCard;
      case 'google_pay':
        return PaymentMethod.googlePay;
      case 'klarna':
        return PaymentMethod.klarna;
      case 'other':
        return PaymentMethod.other;
      case 'not_set':
        return PaymentMethod.notSet;
      default:
        throw ArgumentError('Invalid payment method: $value');
    }
  }
}