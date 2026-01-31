// Stub for Razorpay on web (razorpay_flutter is mobile-only).
// Payment screen uses "Other" on web; UPI/Card are hidden.

class Razorpay {
  static const String EVENT_PAYMENT_SUCCESS = 'payment.success';
  static const String EVENT_PAYMENT_ERROR = 'payment.error';
  static const String EVENT_EXTERNAL_WALLET = 'external.wallet';
  void on(String event, void Function(dynamic) handler) {}
  void open(Map<String, dynamic> options) {}
  void clear() {}
}

class PaymentSuccessResponse {
  final String? paymentId;
  final String? orderId;
  PaymentSuccessResponse({this.paymentId, this.orderId});
}

class PaymentFailureResponse {
  final String? message;
  final String? code;
  PaymentFailureResponse({this.message, this.code});
}

class ExternalWalletResponse {
  final String? walletName;
  ExternalWalletResponse({this.walletName});
}
