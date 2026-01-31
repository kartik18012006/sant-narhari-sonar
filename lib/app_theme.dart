import 'package:flutter/material.dart';

/// Central theme and colors matching the original Sant Narhari Sonar app (from APK).
/// Use these everywhere for point-to-point UI match.
class AppTheme {
  AppTheme._();

  // Primary brand
  static const Color gold = Color(0xFFC9A227);
  static const Color goldDark = Color(0xFFA68521);

  // Backgrounds
  static const Color onboardingBackground = Color(0xFFFFFFFF); // white
  static const Color screenBackground = Color(0xFFFAFAFA);

  // Accents (Explore / feature cards)
  static const Color matrimonyPink = Color(0xFFFFE4EC);
  static const Color aboutBrown = Color(0xFF8D6E63);

  // Auth option icons (login screen)
  static const Color phoneIconBg = Color(0xFFFFF3E0);
  static const Color phoneIcon = Color(0xFFE65100);
  static const Color emailIconBg = Color(0xFFE3F2FD);
  static const Color emailIcon = Color(0xFF1976D2);

  // Border radius used across the app
  static const double radiusButton = 12.0;
  static const double radiusCard = 16.0;
  static const double radiusInput = 12.0;

  // Button height
  static const double buttonHeight = 52.0;

  /// Marital Status (वैवाहिक स्थिती) — 3 options, English + Hindi. Same for bride & groom forms.
  static const List<String> maritalStatusOptions = [
    'Unmarried / अविवाहित',
    'Divorced / घटस्फोटित',
    'Widowed / विधुर',
  ];

  /// Subcaste (पोटजात) options for Matrimony & Social Workers — matches final APK (bilingual).
  static const List<String> subcasteOptions = [
    'Panchal Sonar / पांचाळ सोनार',
    'Lad Sonar / लाड सोनार',
    'Daivajna Sonar / दैवज्ञ सोनार',
    'Vaishya Sonar / वैश्य सोनार',
    'Malavi Sonar / मालवी सोनार',
    'Ahir Sonar / अहिर सोनार',
    'Zhadi (Forest region) Sonar / झाडी सोनार',
    'Deshastha Sonar / देशस्थ सोनार',
    'Azhare Sonar / अझरे सोनार',
    'Deshi (Marathi) Sonar / देशी सोनार',
    'Pardeshi (Non-local) Sonar / परदेशी सोनार',
    'Shilawat Sonar / शिलायत सोनार',
    'Vishwabrāhman Sonar / विश्वब्राह्मण सोनार',
    'Gadhavi Bhatke Sonar / गाढयी भटके सोनार',
    'Takasale (Mint workers) Sonar / टकसाळे सोनार',
    'Kannada (Kanadi) Sonar / कन्नड सोनार',
    'Kadu (Dasiputra) Sonar / कडू सोनार',
    'Soni Sonar / सोनी सोनार',
    'Lingayat Sonar / लिंगायत सोनार',
    'Other / इतर',
  ];

  /// Place / city options for Business search & registration.
  static const List<String> businessPlaceOptions = [
    'Pune', 'Mumbai', 'Nagpur', 'Nashik', 'Kolhapur', 'Sangli', 'Other',
  ];

  /// Business nature / type for Business search & registration.
  static const List<String> businessNatureOptions = [
    'Jewellery / जवाहिरात',
    'Retail / खुदर',
    'Services / सेवा',
    'Manufacturing / उत्पादन',
    'Wholesale / घाऊक',
    'Other / इतर',
  ];

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: gold, brightness: Brightness.light),
      primaryColor: gold,
      scaffoldBackgroundColor: screenBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
    );
  }
}
