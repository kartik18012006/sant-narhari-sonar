import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../app_theme.dart';
import '../payment_config.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../widgets/responsive_wrapper.dart';
import 'matrimony_list_screen.dart';
import 'matrimony_terms_screen.dart';
import 'payment_screen.dart';

/// Matrimony: "Search Grooms" / "Search Brides" and "Register as Groom/Bride".
/// Payment logic: Each action (registration/search) requires separate ₹2100 payment.
/// Use [isGroom] true for Search Grooms, false for Search Brides.
/// Bride section: Only groom search available. Groom section: Only bride search available.
class MatrimonySearchScreen extends StatefulWidget {
  const MatrimonySearchScreen({super.key, required this.isGroom});

  final bool isGroom;

  @override
  State<MatrimonySearchScreen> createState() => _MatrimonySearchScreenState();
}

class _MatrimonySearchScreenState extends State<MatrimonySearchScreen> {
  bool _checkingAccess = true;
  bool _hasRegistrationAccess = false;
  bool _hasSearchAccess = false;

  @override
  void initState() {
    super.initState();
    _checkPaymentAccess();
  }

  Future<void> _checkPaymentAccess() async {
    final user = FirebaseAuthService.instance.currentUser;
    if (user == null) {
      setState(() {
        _checkingAccess = false;
        _hasRegistrationAccess = false;
        _hasSearchAccess = false;
      });
      return;
    }
    final registrationFeatureId = widget.isGroom 
        ? PaymentConfig.groomRegistration 
        : PaymentConfig.brideRegistration;
    final searchFeatureId = widget.isGroom 
        ? PaymentConfig.groomSearch 
        : PaymentConfig.brideSearch;
    
    final hasRegAccess = await FirestoreService.instance.hasValidPaymentForFeature(
      user.uid,
      registrationFeatureId,
    );
    final hasSearchAccess = await FirestoreService.instance.hasValidPaymentForFeature(
      user.uid,
      searchFeatureId,
    );
    
    setState(() {
      _checkingAccess = false;
      _hasRegistrationAccess = hasRegAccess;
      _hasSearchAccess = hasSearchAccess;
    });
  }

  String get _titleEn => widget.isGroom ? 'Search Grooms' : 'Search Brides';
  String get _titleMr => widget.isGroom ? 'वर शोधा' : 'वधू शोधा';
  String get _registerPayMr =>
      widget.isGroom ? 'नोंदणी आणि पेमेंट केल्यानंतर शोधा' : 'नोंदणी आणि पेमेंट केल्यानंतर शोधा';
  String get _paragraphEn => widget.isGroom
      ? 'You can register as groom and search bride profiles after completing the payment. Each action requires separate payment of ₹2100.'
      : 'You can register as bride and search groom profiles after completing the payment. Each action requires separate payment of ₹2100.';
  String get _registerAsEn => widget.isGroom ? 'Register as Groom' : 'Register as Bride';
  String get _registerAsMr => widget.isGroom ? 'वर म्हणून नोंदणी करा' : 'वधू म्हणून नोंदणी करा';
  String get _registerInsteadEn => widget.isGroom ? 'Register as Bride instead' : 'Register as Groom instead';
  String get _registerInsteadMr =>
      widget.isGroom ? 'वधू म्हणून नोंदणी करा' : 'वर म्हणून नोंदणी करा';

  @override
  Widget build(BuildContext context) {
    if (_checkingAccess) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(child: CircularProgressIndicator()),
      );
    }


    // Payment required screen
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
          '$_titleEn / $_titleMr',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.grey.shade800),
            onPressed: () {
              // Filters appear on the list screen after you tap Search Grooms/Brides
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Use filters on the search results screen after payment.')),
              );
            },
          ),
        ],
      ),
      body: ResponsiveWrapper(
        maxWidth: kIsWeb ? 600 : double.infinity,
        padding: EdgeInsets.zero,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: kIsWeb ? 24 : 24,
              vertical: 0,
            ),
            child: Column(
              children: [
                const SizedBox(height: 32),
                // Lock icon
                Icon(Icons.lock, size: 80, color: AppTheme.gold),
                const SizedBox(height: 24),
                // Register & Pay to Search
                Text(
                  'Register & Pay to Search',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  _registerPayMr,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  _paragraphEn,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),
                // + Register as Groom/Bride
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: () => _onRegister(context),
                    icon: const Icon(Icons.person_add, size: 22, color: Colors.white),
                    label: Text('$_registerAsEn / $_registerAsMr'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.gold,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Search opposite gender only (groom section -> bride search, bride section -> groom search)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () => _onSearch(context),
                    icon: Icon(Icons.search, size: 22, color: AppTheme.gold),
                    label: Text(widget.isGroom ? 'Search Brides / वधू शोधा' : 'Search Grooms / वर शोधा'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: const BorderSide(color: AppTheme.gold, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                // Register as Bride/Groom instead
                TextButton(
                  onPressed: () => _onRegisterInstead(context),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                      children: [
                        TextSpan(text: '$_registerInsteadEn\n'),
                        TextSpan(text: _registerInsteadMr),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onRegister(BuildContext context) async {
    if (!_hasRegistrationAccess) {
      // Pay ₹2100 for registration (bride or groom separately)
      final featureId = widget.isGroom 
          ? PaymentConfig.groomRegistration 
          : PaymentConfig.brideRegistration;
      final amount = widget.isGroom 
          ? PaymentConfig.groomRegistrationAmount 
          : PaymentConfig.brideRegistrationAmount;
      
      final paid = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => PaymentScreen(
            featureId: featureId,
            amount: amount,
          ),
        ),
      );
      if (paid == true && mounted) {
        // Wait a bit for payment to be recorded
        await Future.delayed(const Duration(milliseconds: 500));
        await _checkPaymentAccess();
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute<bool>(
              builder: (_) => MatrimonyTermsScreen(isGroom: widget.isGroom),
            ),
          );
        }
      }
    } else {
      // User already has access, go directly to registration
      Navigator.of(context).push(
        MaterialPageRoute<bool>(
          builder: (_) => MatrimonyTermsScreen(isGroom: widget.isGroom),
        ),
      );
    }
  }

  void _onSearch(BuildContext context) async {
    // Search opposite gender: groom section searches brides, bride section searches grooms
    final searchIsGroom = !widget.isGroom;
    
    if (!_hasSearchAccess) {
      // Pay ₹2100 for search (bride search or groom search separately)
      final featureId = searchIsGroom 
          ? PaymentConfig.groomSearch 
          : PaymentConfig.brideSearch;
      final amount = searchIsGroom 
          ? PaymentConfig.groomSearchAmount 
          : PaymentConfig.brideSearchAmount;
      
      final paid = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => PaymentScreen(
            featureId: featureId,
            amount: amount,
          ),
        ),
      );
      if (paid == true && mounted) {
        // Wait a bit for payment to be recorded
        await Future.delayed(const Duration(milliseconds: 500));
        await _checkPaymentAccess();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment successful. You can now search ${searchIsGroom ? "groom" : "bride"} profiles.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MatrimonyListScreen(isGroom: searchIsGroom),
            ),
          );
        }
      }
    } else {
      // User already has access, go directly to search
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MatrimonyListScreen(isGroom: searchIsGroom),
        ),
      );
    }
  }

  void _onRegisterInstead(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MatrimonySearchScreen(isGroom: !widget.isGroom),
      ),
    );
  }
}
