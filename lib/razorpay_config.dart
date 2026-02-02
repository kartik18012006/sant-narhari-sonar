/// Razorpay Live API Configuration
/// 
/// This file contains the live Razorpay API keys.
/// Update these keys here for production use.
class RazorpayConfig {
  RazorpayConfig._();

  /// Live Razorpay API Key
  static const String liveKeyId = 'rzp_live_SBKZbDFnJztXdR';

  /// Live Razorpay Key Secret
  static const String liveKeySecret = 'p1Gaf125XURDut0FSDQeN2pF';

  /// Payment gateway mode: 'live' for production
  static const String mode = 'live';

  /// Whether to use live keys
  static const bool useLiveKeys = true;
}
