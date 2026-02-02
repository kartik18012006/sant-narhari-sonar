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

  // Button height (reduced for better visual balance)
  static const double buttonHeight = 40.0;
  
  // Max button width to prevent excessive stretching
  static const double maxButtonWidth = 400.0;

  /// Marital Status (वैवाहिक स्थिती) — 3 options, English + Marathi. Same for bride & groom forms.
  static const List<String> maritalStatusOptions = [
    'Unmarried / अविवाहित',
    'Married / विवाहित',
    'Widowed / विधवा/विदुर',
  ];

  /// Marital Status options for Groom
  static const List<String> maritalStatusOptionsGroom = [
    'Unmarried / अविवाहित',
    'Divorced / तलाक',
    'Widowed / विधुर',
  ];

  /// Marital Status options for Bride
  static const List<String> maritalStatusOptionsBride = [
    'Unmarried / अविवाहित',
    'Divorced / तलाक',
    'Widowed / विधवा',
  ];

  /// Complexion (रंग / वर्ण) options
  static const List<String> complexionOptions = [
    'Fair / गोरा',
    'Very Fair / अतीगोरा',
    'Wheatish / गहुवर्णीय',
    'Dark / काळा',
  ];

  /// Blood Group (रक्तगट) options
  static const List<String> bloodGroupOptions = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  /// Diet (आहार) options
  static const List<String> dietOptions = [
    'Veg / शाकाहारी',
    'Non-Veg / मांसाहारी',
    'Both / दोन्ही',
  ];

  /// Manglik (मांगलिक) options
  static const List<String> manglikOptions = [
    'Yes / हो',
    'No / नाही',
    'Partial / थोडा',
  ];

  /// Nakshatra (नक्षत्र) options
  static const List<String> nakshatraOptions = [
    'Rohini / रोहिणी',
    'Mrigashirsha / मृगशीर्ष',
    'Ashlesha / आश्लेषा',
    'Pushya / पुष्य',
    'Magha / मघा',
    'Purva Phalguni / पूर्या फाल्गुनी',
    'Uttara Phalguni / उत्तर फाल्गुनी',
    'Hasta / हस्त',
    'Swati / स्वाती',
    'Vishakha / विशाखा',
    'Anuradha / अनुराधा',
    'Shravana / श्रवण',
    'Dhanishtha / धनिष्ठा',
    'Shatabhisha / शतभिषा',
    'Purva Bhadrapada / पूर्वाभाद्रपदा',
    'Uttara Bhadrapada / उत्तराभाद्रपदा',
    'Revati / रेवती',
  ];

  /// Rashi (राशी) options
  static const List<String> rashiOptions = [
    'Mesh / मेष',
    'Vrishabha / वृषभ',
    'Mithun / मिथुन',
    'Karka / कर्क',
    'Simha / सिंह',
    'Kanya / कन्या',
    'Tula / तुला',
    'Vrishchik / वृश्चिक',
    'Dhanu / धनु',
    'Makar / मकर',
    'Kumbha / कुंभ',
    'Meen / मीन',
  ];

  /// Gotra (गोत्र) options
  static const List<String> gotraOptions = [
    'Kashyap / कश्यप',
    'Bharadwaj / भारद्वाज',
    'Gautam / गौतम',
    'Vashistha / वशिष्ठ',
    'Atri / अत्रि',
    'Angiras / अंगिरस',
    'Parashar / पराशर',
    'Jamadagni / जमदग्नी',
    'Shandilya / शांडिल्य',
    'Kaushik / कौशिक',
    'Other / इतर',
  ];

  /// Disability (अपंगत्व) options
  static const List<String> disabilityOptions = [
    'Yes / हो',
    'No / नाही',
  ];

  /// Family Values (कौटुंबिक मूल्ये) options
  static const List<String> familyValuesOptions = [
    'Traditional / पारंपारिक',
    'Moderate / मध्यम',
    'Modern / आधुनिक',
  ];

  /// Financial Outlook (आर्थिक दृष्टिकोन) options
  static const List<String> financialOutlookOptions = [
    'Saver / बचतकर्ता',
    'Spender / खर्चिक',
    'Balanced / संतुलित',
  ];

  /// Communication Style (संवाद शैली) options
  static const List<String> communicationStyleOptions = [
    'Open Discussion / खुली चर्चा',
    'Need Space Before Talking / बोलण्यापूर्वी वेळ हवा',
    'Prefer to Avoid Conflict / संघर्ष टाळणे पसंत',
  ];

  /// Gender (लिंग) options
  static const List<String> genderOptions = [
    'Male / पुरुष',
    'Female / महिला',
    'Other / इतर',
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

  /// Business Structure (व्यवसाय रचना) options
  static const List<String> businessStructureOptions = [
    'Proprietorship / मालकी',
    'Partnership / भागीदारी',
    'LLP / एलएलपी',
    'Pvt. Ltd. / प्रा. लि.',
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
      // Button themes - reduced padding and height, auto-width by default
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          minimumSize: const Size(0, buttonHeight),
          maximumSize: Size(maxButtonWidth, buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          minimumSize: const Size(0, buttonHeight),
          maximumSize: Size(maxButtonWidth, buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: const Size(0, 36),
          maximumSize: Size(maxButtonWidth, 36),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          minimumSize: const Size(0, buttonHeight),
          maximumSize: Size(maxButtonWidth, buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
        ),
      ),
    );
  }
}
