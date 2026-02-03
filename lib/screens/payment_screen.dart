import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// Web: stub (UPI/Card not supported); mobile: real Razorpay
import 'payment_razorpay_stub.dart' if (dart.library.io) 'package:razorpay_flutter/razorpay_flutter.dart';
import '../services/razorpay_web_service_stub.dart' if (dart.library.html) '../services/razorpay_web_service.dart';

import '../app_theme.dart';
import '../payment_config.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';

/// Payment screen: feature name, amount, payment method (UPI, Card/Net Banking), Pay button.
/// UPI and Card open Razorpay checkout when Firestore payment doc has key_id and key_secret (test).
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    required this.featureId,
    this.amount,
  });

  /// One of [PaymentConfig.*] e.g. familyDirectory, matrimonialYearly, businessRegistration, etc.
  final String featureId;

  /// Override amount; if null uses [PaymentConfig.amountFor].
  final int? amount;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // Web and mobile: upi | card
  String _selectedMethod = 'upi';
  PaymentGatewayConfig? _gatewayConfig;
  bool _configLoading = true;
  String? _configError;
  final Razorpay _razorpay = Razorpay();
  bool _checkoutOpen = false;

  int get _amount => widget.amount ?? PaymentConfig.amountFor(widget.featureId);

  @override
  void initState() {
    super.initState();
    _checkTestEmailAndBypass();
    _loadGatewayConfig();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (dynamic r) => _handlePaymentSuccess(r as PaymentSuccessResponse));
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (dynamic r) => _handlePaymentError(r as PaymentFailureResponse));
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (dynamic r) => _handleExternalWallet(r as ExternalWalletResponse));
  }

  /// Check if user is test email and bypass payment
  Future<void> _checkTestEmailAndBypass() async {
    final user = FirebaseAuthService.instance.currentUser;
    if (user?.email == FirestoreService.testEmail) {
      // Test email - automatically bypass payment
      final uid = user!.uid;
      final isSubscription = widget.featureId == PaymentConfig.loginYearly;
      
      // Record payment as success for tracking
      await FirestoreService.instance.recordPayment(
        userId: uid,
        featureId: widget.featureId,
        amountInr: _amount,
        status: 'success',
        transactionId: 'test_email_bypass',
      );
      
      if (isSubscription) {
        final validUntil = DateTime.now().add(const Duration(days: 365));
        await FirestoreService.instance.setSubscriptionValidUntil(uid, validUntil);
      }
      
      // Wait for next frame to ensure context is available
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isSubscription
                      ? 'Test account: Subscription active. You now have full app access.'
                      : 'Test account: Payment bypassed. Feature access granted.',
                ),
                backgroundColor: Colors.green.shade700,
              ),
            );
            Navigator.of(context).pop(true);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _checkoutOpen = false;
    if (!mounted) return;
    final uid = FirebaseAuthService.instance.currentUser?.uid;
    final isSubscription = widget.featureId == PaymentConfig.loginYearly;
    if (uid != null) {
      FirestoreService.instance.recordPayment(
        userId: uid,
        featureId: widget.featureId,
        amountInr: _amount,
        status: 'success',
        transactionId: response.paymentId,
      );
      if (isSubscription) {
        final validUntil = DateTime.now().add(const Duration(days: 365));
        FirestoreService.instance.setSubscriptionValidUntil(uid, validUntil);
      }
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isSubscription
              ? 'Subscription active. You now have full app access.'
              : 'Payment of ${PaymentConfig.formattedAmount(_amount)} successful.',
        ),
        backgroundColor: Colors.green.shade700,
      ),
    );
    Navigator.of(context).pop(true);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _checkoutOpen = false;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.message ?? 'Payment failed'),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _checkoutOpen = false;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External wallet: ${response.walletName}')),
    );
  }

  /// Create Razorpay order (test only: requires key_secret in Firestore).
  static Future<String?> _createRazorpayOrder({
    required String keyId,
    required String keySecret,
    required int amountPaise,
    required String receipt,
  }) async {
    final auth = 'Basic ${base64Encode(utf8.encode('$keyId:$keySecret'))}';
    final res = await http.post(
      Uri.parse('https://api.razorpay.com/v1/orders'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': auth,
      },
      body: jsonEncode({
        'amount': amountPaise,
        'currency': 'INR',
        'receipt': receipt,
      }),
    );
    if (res.statusCode != 200) return null;
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return data['id'] as String?;
  }

  Future<void> _loadGatewayConfig() async {
    setState(() {
      _configLoading = true;
      _configError = null;
    });
    try {
      final config = await FirestoreService.instance.getPaymentGatewayConfig();
      if (mounted) {
        setState(() {
          _gatewayConfig = config;
          _configLoading = false;
          _configError = config == null ? 'Payment gateway configuration not available. Please contact support.' : null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _configLoading = false;
          _configError = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = PaymentConfig.titleFor(widget.featureId);
    final titleMr = PaymentConfig.titleMrFor(widget.featureId);
    final subtitle = PaymentConfig.subtitleFor(widget.featureId);
    final subtitleMr = PaymentConfig.subtitleMrFor(widget.featureId);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade800),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          titleMr.isNotEmpty ? '$title / $titleMr' : 'Payment',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // Gateway config from Firestore (payment/razorpay) — replace keys there for production
              if (_configError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Material(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange.shade800, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _configError!,
                              style: TextStyle(fontSize: 12, color: Colors.orange.shade900),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (_gatewayConfig != null && !_configLoading)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Center(
                    child: Text(
                      'Gateway: Razorpay (${_gatewayConfig!.mode})',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ),
                ),
              // Amount card (with duration: Yearly / One-time / 24 hours)
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                    border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        PaymentConfig.durationLabelFor(widget.featureId) +
                            (PaymentConfig.durationLabelMrFor(widget.featureId).isNotEmpty
                                ? ' / ${PaymentConfig.durationLabelMrFor(widget.featureId)}'
                                : ''),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        PaymentConfig.formattedAmount(_amount),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Amount to pay',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                titleMr.isNotEmpty ? '$title / $titleMr' : title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.45,
                ),
              ),
              if (subtitleMr.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  subtitleMr,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: 28),
              // Payment method
              Text(
                'Select payment method',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 12),
              _PaymentOption(
                value: 'upi',
                label: 'UPI (GPay, PhonePe, Paytm)',
                subtitle: 'Pay using UPI ID or linked bank',
                icon: Icons.phone_android,
                isSelected: _selectedMethod == 'upi',
                onTap: () => setState(() => _selectedMethod = 'upi'),
              ),
              const SizedBox(height: 10),
              _PaymentOption(
                value: 'card',
                label: 'Card / Net Banking',
                subtitle: 'Credit, Debit or Net Banking',
                icon: Icons.credit_card,
                isSelected: _selectedMethod == 'card',
                onTap: () => setState(() => _selectedMethod = 'card'),
              ),
              const SizedBox(height: 32),
              // Pay button: enabled when config loaded
              SizedBox(
                width: double.infinity,
                height: AppTheme.buttonHeight,
                child: FilledButton(
                  onPressed: (_configLoading || _checkoutOpen)
                      ? null
                      : (_gatewayConfig != null)
                          ? _onPay
                          : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                    ),
                  ),
                  child: Text(
                    'Pay ${PaymentConfig.formattedAmount(_amount)} / आता पैसे द्या',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onPay() async {
    final config = _gatewayConfig;
    final isUpiOrCard = _selectedMethod == 'upi' || _selectedMethod == 'card';

    // UPI or Card: need gateway config and key_secret to create order (test)
    if (config == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment config not found. Add key_id and key_secret in Firestore payment collection.')),
        );
      }
      return;
    }

    if (isUpiOrCard && !config.canCreateOrder) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'For UPI/Card, add key_secret in Firestore (payment doc). Get test keys from Razorpay Dashboard.',
            ),
          ),
        );
      }
      return;
    }

    // Create order and open Razorpay checkout (UPI, Card)
    final keySecret = config.keySecret!;
    final amountPaise = _amount * 100;
    final receipt = '${widget.featureId}_${DateTime.now().millisecondsSinceEpoch}';
    setState(() => _checkoutOpen = true);
    final orderId = await _createRazorpayOrder(
      keyId: config.keyId,
      keySecret: keySecret,
      amountPaise: amountPaise,
      receipt: receipt,
    );
    if (!mounted) return;
    setState(() => _checkoutOpen = false);
    if (orderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not create order. Check key_id and key_secret in Firestore.')),
      );
      return;
    }

    final user = FirebaseAuthService.instance.currentUser;
    
    if (kIsWeb) {
      // Web: Use Razorpay Web Checkout
      _checkoutOpen = true;
      final result = await RazorpayWebService.instance.openCheckout(
        keyId: config.keyId,
        amount: amountPaise,
        orderId: orderId,
        name: 'Sant Narhari Sonar',
        description: PaymentConfig.titleFor(widget.featureId),
        prefill: {
          if (user?.phoneNumber != null) 'contact': user!.phoneNumber!.replaceAll(RegExp(r'\D'), ''),
          if (user?.email != null) 'email': user!.email,
        },
        onSuccess: (response) {
          _checkoutOpen = false;
          if (!mounted) return;
          _handlePaymentSuccess(PaymentSuccessResponse(
            response['razorpay_payment_id'] as String?,
            response['razorpay_order_id'] as String?,
            response['razorpay_signature'] as String?,
            response,
          ));
        },
        onError: (error) {
          _checkoutOpen = false;
          if (!mounted) return;
          // Convert code to int if it's a string, or use null
          int? errorCode;
          final codeValue = error['code'];
          if (codeValue is int) {
            errorCode = codeValue;
          } else if (codeValue is String) {
            errorCode = int.tryParse(codeValue);
          }
          _handlePaymentError(PaymentFailureResponse(
            errorCode,
            error['message'] as String? ?? 'Payment failed',
            error as Map<String, dynamic>?,
          ));
        },
      );
      
      if (!result['success'] && mounted) {
        _checkoutOpen = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] as String? ?? 'Failed to open payment checkout')),
        );
      }
    } else {
      // Mobile: Use Razorpay Flutter SDK
      final options = {
        'key': config.keyId,
        'amount': amountPaise,
        'order_id': orderId,
        'name': 'Sant Narhari Sonar',
        'description': PaymentConfig.titleFor(widget.featureId),
        'prefill': {
          if (user?.phoneNumber != null) 'contact': user!.phoneNumber!.replaceAll(RegExp(r'\D'), ''),
          if (user?.email != null) 'email': user!.email,
        },
      };

      _checkoutOpen = true;
      _razorpay.open(options);
    }
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.value,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String value;
  final String label;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusInput),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusInput),
            border: Border.all(
              color: isSelected ? AppTheme.gold : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.gold.withValues(alpha: 0.15)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: isSelected ? AppTheme.gold : Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: AppTheme.gold, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
