/// Stub for Razorpay Web Service on non-web platforms
class RazorpayWebService {
  RazorpayWebService._internal();
  static final RazorpayWebService instance = RazorpayWebService._internal();

  Future<void> initScript() async {}

  Future<Map<String, dynamic>> openCheckout({
    required String keyId,
    required int amount,
    required String orderId,
    required String name,
    required String description,
    Map<String, dynamic>? prefill,
    required Function(Map<String, dynamic>) onSuccess,
    required Function(Map<String, dynamic>) onError,
  }) async {
    return {'success': false, 'message': 'Web service not available on this platform'};
  }
}
