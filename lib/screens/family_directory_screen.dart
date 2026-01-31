import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../payment_config.dart';
import 'family_directory_list_screen.dart';
import 'family_directory_registration_screen.dart';
import 'payment_screen.dart';

/// Family Directory — pay ₹101 to access, then register family & search directory. Matches APK.
class FamilyDirectoryScreen extends StatelessWidget {
  const FamilyDirectoryScreen({super.key});

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
        title: const Text(
          'Family Directory / कुटुंब निर्देशिका',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.grey.shade800),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 28),
              // Lock icon
              const Icon(Icons.lock, size: 80, color: AppTheme.gold),
              const SizedBox(height: 24),
              // Pay to Access
              const Text(
                'Pay to Access Family Directory',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'पेमेंट केल्यानंतर कुटुंब निर्देशिका',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'You can register your family and search the directory only after you have completed the payment.',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Register Family
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => _onRegisterFamily(context),
                  icon: const Icon(Icons.add, size: 22, color: AppTheme.gold),
                  label: const Text('Register Family / कुटुंब नोंदणी करा'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    side: const BorderSide(color: AppTheme.gold, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Search Family Directory
              TextField(
                readOnly: true,
                onTap: () => _onSearch(context),
                decoration: InputDecoration(
                  hintText: 'Search Family Directory / कुटुंब निर्देशिका शोधा',
                  hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: AppTheme.gold, size: 22),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 32),
              // Pay Now
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () => _onPayNow(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                    ),
                  ),
                  child: Text(
                    'Pay Now (${PaymentConfig.formattedAmount(PaymentConfig.familyDirectoryAmount)}) / आता पैसे द्या',
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

  void _onRegisterFamily(BuildContext context) {
    // APK: Pay first, then open registration form. Same flow as Explore Business.
    Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (_) => PaymentScreen(
          featureId: PaymentConfig.familyDirectory,
          amount: PaymentConfig.familyDirectoryAmount,
        ),
      ),
    ).then((paid) {
      if (paid == true && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful. You can now add family details.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const FamilyDirectoryRegistrationScreen()),
        );
      }
    });
  }

  void _onSearch(BuildContext context) {
    // APK: Pay first, then search. Same flow.
    Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (_) => PaymentScreen(
          featureId: PaymentConfig.familyDirectory,
          amount: PaymentConfig.familyDirectoryAmount,
        ),
      ),
    ).then((paid) {
      if (paid == true && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful. You can now search the family directory.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const FamilyDirectoryListScreen()),
        );
      }
    });
  }

  void _onPayNow(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (_) => PaymentScreen(
          featureId: PaymentConfig.familyDirectory,
          amount: PaymentConfig.familyDirectoryAmount,
        ),
      ),
    ).then((paid) {
      if (paid == true && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful. You can now register family and search directory.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }
}
