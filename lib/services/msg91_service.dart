import 'package:flutter/foundation.dart';
import 'package:sendotp_flutter_sdk/sendotp_flutter_sdk.dart';

/// MSG91 OTP Service using sendotp_flutter_sdk
class Msg91Service {
  Msg91Service._internal();
  static final Msg91Service instance = Msg91Service._internal();

  static const String widgetId = '366262665447313838383232';
  static const String authToken = '491677TcLs96YOx6980608aP1';

  bool _initialized = false;
  String? _reqId;

  /// Initialize MSG91 widget (only once)
  void initWidget() {
    if (!_initialized) {
      OTPWidget.initializeWidget(widgetId, authToken);
      _initialized = true;
    }
  }

  /// Send OTP to phone number
  /// Phone number should be in format: 91XXXXXXXXXX (country code + 10 digits, no +)
  /// Returns response with reqId captured and stored
  Future<Map<String, dynamic>> sendOtp(String identifier) async {
    try {
      final data = {'identifier': identifier};
      final response = await OTPWidget.sendOTP(data);
      
      // Console.log full sendOTP response
      debugPrint('MSG91 sendOTP full response: $response');
      
      if (response is Map<String, dynamic>) {
        if (response['type'] == 'success' || response['success'] == true) {
          // Extract reqId from sendOTP response ONLY
          _reqId = response['message'] as String?;
          
          debugPrint('Extracted reqId: $_reqId');
          
          return {
            'success': true,
            'type': 'success',
            'message': response['message'] ?? 'OTP sent successfully',
          };
        }
        return {'success': false, 'message': response['message'] ?? 'Failed to send OTP'};
      }
      return {'success': false, 'message': 'Invalid response from MSG91'};
    } catch (e) {
      debugPrint('Error sending OTP: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Verify OTP
  /// Phone number should be in format: 91XXXXXXXXXX (country code + 10 digits, no +)
  /// OTP is the 4-digit code entered by user
  /// Uses stored reqId from sendOtp response
  Future<Map<String, dynamic>> verifyOtp(String identifier, String otp) async {
    try {
      final data = {
        'identifier': identifier,
        'otp': otp,
      };
      
      // Use reqId key when calling verifyOTP
      if (_reqId != null && _reqId!.isNotEmpty) {
        data['reqId'] = _reqId!;
      } else {
        return {
          'success': false,
          'message': 'Request ID missing. Please request OTP again.',
        };
      }
      
      final response = await OTPWidget.verifyOTP(data);
      
      if (response is Map<String, dynamic>) {
        if (response['type'] == 'success' || response['success'] == true) {
          // Clear reqId after successful verification
          _reqId = null;
          return {'success': true, 'type': 'success', 'message': response['message'] ?? 'OTP verified successfully'};
        }
        return {'success': false, 'message': response['message'] ?? 'Invalid OTP'};
      }
      return {'success': false, 'message': 'Invalid response from MSG91'};
    } catch (e) {
      debugPrint('Error verifying OTP: $e');
      return {'success': false, 'message': e.toString()};
    }
  }
}
