import 'package:flutter/material.dart';

import '../app_theme.dart';
import 'family_directory_list_screen.dart';
import 'family_directory_terms_screen.dart';

/// Family Directory — free registration and search. Matches APK.
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
              // Family icon
              const Icon(Icons.family_restroom, size: 80, color: AppTheme.gold),
              const SizedBox(height: 24),
              // Welcome message
              const Text(
                'Family Directory',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'कुटुंब निर्देशिका',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Register your family and search the directory for free.',
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _onRegisterFamily(BuildContext context) {
    // Family Directory is free - directly open registration form
    Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (_) => const FamilyDirectoryTermsScreen(),
      ),
    );
  }

  void _onSearch(BuildContext context) {
    // Family Directory is free - directly open search
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const FamilyDirectoryListScreen()),
    );
  }

}
