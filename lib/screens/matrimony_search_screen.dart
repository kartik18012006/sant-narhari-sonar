import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../payment_config.dart';
import 'matrimony_list_screen.dart';
import 'matrimony_registration_screen.dart';
import 'payment_screen.dart';

/// Matrimony: "Search Grooms" / "Search Brides" and "Register as Groom/Bride".
/// Payment logic: Pay ₹2100 first, then open registration form or search. Matches APK exactly.
/// Use [isGroom] true for Search Grooms, false for Search Brides.
class MatrimonySearchScreen extends StatelessWidget {
  const MatrimonySearchScreen({super.key, required this.isGroom});

  final bool isGroom;

  String get _titleEn => isGroom ? 'Search Grooms' : 'Search Brides';
  String get _titleMr => isGroom ? 'वर शोधा' : 'वधू शोधा';
  String get _registerPayMr =>
      isGroom ? 'नोंदणी आणि पेमेंट केल्यानंतर शोधा' : 'नोंदणी आणि पेमेंट केल्यानंतर शोधा';
  String get _paragraphEn => isGroom
      ? 'You can register and search groom profiles only after you have completed the registration payment.'
      : 'You can register and search bride profiles only after you have completed the registration payment.';
  String get _registerAsEn => isGroom ? 'Register as Groom' : 'Register as Bride';
  String get _registerAsMr => isGroom ? 'वर म्हणून नोंदणी करा' : 'वधू म्हणून नोंदणी करा';
  String get _searchEn => isGroom ? 'Search Grooms' : 'Search Brides';
  String get _searchMr => isGroom ? 'वर शोधा' : 'वधू शोधा';
  String get _registerInsteadEn => isGroom ? 'Register as Bride instead' : 'Register as Groom instead';
  String get _registerInsteadMr =>
      isGroom ? 'वधू म्हणून नोंदणी करा' : 'वर म्हणून नोंदणी करा';

  @override
  Widget build(BuildContext context) {
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
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
              // Search Grooms/Brides
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => _onSearch(context),
                  icon: Icon(Icons.search, size: 22, color: AppTheme.gold),
                  label: Text('$_searchEn / $_searchMr'),
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
    );
  }

  void _onRegister(BuildContext context) {
    // Pay ₹2100 first, then open groom/bride registration form. "Final Step: Complete payment to submit your matrimonial profile."
    Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (_) => PaymentScreen(
          featureId: PaymentConfig.matrimonialYearly,
          amount: PaymentConfig.matrimonialYearlyAmount,
        ),
      ),
    ).then((paid) {
      if (paid == true && context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MatrimonyRegistrationScreen(isGroom: isGroom),
          ),
        );
      }
    });
  }

  void _onSearch(BuildContext context) {
    // "You can search bride/groom profiles only after you have registered as bride or groom and completed the registration payment."
    // Pay ₹2100 then show search (list of grooms/brides from Firestore).
    Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (_) => PaymentScreen(
          featureId: PaymentConfig.matrimonialYearly,
          amount: PaymentConfig.matrimonialYearlyAmount,
        ),
      ),
    ).then((paid) {
      if (paid == true && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment successful. You can now search $_titleEn.'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to matrimony list screen (grooms or brides)
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MatrimonyListScreen(isGroom: isGroom),
          ),
        );
      }
    });
  }

  void _onRegisterInstead(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MatrimonySearchScreen(isGroom: !isGroom),
      ),
    );
  }
}
