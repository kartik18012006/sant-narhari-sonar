import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

/// External window.Razorpay accessor
@JS('window')
external JSObject get _window;

/// Razorpay Web Service for web platform
class RazorpayWebService {
  RazorpayWebService._internal();
  static final RazorpayWebService instance = RazorpayWebService._internal();

  bool _scriptLoaded = false;

  /// Check if Razorpay is loaded
  bool _isRazorpayLoaded() {
    try {
      final windowMap = _window.dartify() as Map?;
      return windowMap?.containsKey('Razorpay') ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Get Razorpay constructor
  JSFunction? _getRazorpayConstructor() {
    try {
      final windowMap = _window.dartify() as Map?;
      final razorpay = windowMap?['Razorpay'];
      if (razorpay != null) {
        return (razorpay as Object).jsify() as JSFunction?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Initialize Razorpay script
  Future<void> initScript() async {
    if (_scriptLoaded) return;

    try {
      // Check if Razorpay is already loaded
      if (_isRazorpayLoaded()) {
        _scriptLoaded = true;
        debugPrint('Razorpay script already loaded');
        return;
      }

      // Load Razorpay checkout script
      final script = web.document.createElement('script') as web.HTMLScriptElement;
      script.src = 'https://checkout.razorpay.com/v1/checkout.js';
      script.async = true;

      final completer = Completer<void>();
      script.onLoad.listen((_) {
        _scriptLoaded = true;
        debugPrint('Razorpay script loaded successfully');
        completer.complete();
      });

      script.onError.listen((_) {
        debugPrint('Failed to load Razorpay script');
        completer.completeError('Failed to load Razorpay script');
      });

      web.document.head?.appendChild(script);

      await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('Razorpay script load timeout');
        },
      );
    } catch (e) {
      debugPrint('Error loading Razorpay script: $e');
    }
  }

  /// Open Razorpay checkout
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
    try {
      await initScript();

      if (!_isRazorpayLoaded()) {
        return {'success': false, 'message': 'Razorpay script not loaded'};
      }

      final razorpayConstructor = _getRazorpayConstructor();
      if (razorpayConstructor == null) {
        return {'success': false, 'message': 'Razorpay constructor not found'};
      }

      // Create options object
      final optionsObj = <String, Object>{
        'key': keyId,
        'amount': amount,
        'order_id': orderId,
        'name': name,
        'description': description,
        'handler': ((JSAny response) {
          final responseMap = _jsObjectToMap(response);
          onSuccess(responseMap);
        }).toJS,
        'modal': {
          'ondismiss': ((JSAny _) {
            onError({'message': 'Payment cancelled by user'});
          }).toJS,
        },
      };

      if (prefill != null) {
        optionsObj['prefill'] = prefill.jsify() as JSObject;
      }

      // Create Razorpay instance: new Razorpay(options)
      final razorpayInstance = razorpayConstructor.callAsFunction(
        null,
        optionsObj.jsify() as JSObject,
      ) as JSObject;
      
      // Call open() method directly on the instance
      // Convert to Dart map to access the 'open' method
      try {
        final instanceMap = razorpayInstance.dartify() as Map?;
        if (instanceMap != null && instanceMap.containsKey('open')) {
          final openMethod = instanceMap['open'];
          if (openMethod != null && openMethod is Function) {
            // Convert back to JS function and call it
            final openJs = (openMethod as Object).jsify() as JSFunction;
            openJs.callAsFunction(razorpayInstance);
          } else {
            debugPrint('Razorpay open method is not a function');
            return {'success': false, 'message': 'Razorpay open method is not a function'};
          }
        } else {
          debugPrint('Razorpay instance does not have open method');
          return {'success': false, 'message': 'Razorpay instance does not have open method'};
        }
      } catch (e) {
        debugPrint('Error calling Razorpay open: $e');
        return {'success': false, 'message': 'Failed to open Razorpay checkout: $e'};
      }

      return {'success': true};
    } catch (e) {
      debugPrint('Error opening Razorpay checkout: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Map<String, dynamic> _jsObjectToMap(JSAny jsAny) {
    try {
      final dartValue = jsAny.dartify();
      if (dartValue is Map) {
        return Map<String, dynamic>.from(dartValue);
      }
      return {'raw': dartValue?.toString() ?? 'Unknown response'};
    } catch (e) {
      debugPrint('Error converting JS object to map: $e');
      return {'error': e.toString()};
    }
  }
}
