/// Central config: which feature costs how much.
/// Matches app payment logic — single source of truth.
///
/// Payment logic:
/// - Login yearly: ₹21 (auto, yearly)
/// - Business registration: ₹201 (one-time)
/// - Social worker: Free
/// - Advertisement: ₹101 (24 hours) — Social News Event free
/// - News: ₹101 (24 hours) — Social News Event free
/// - Events: ₹101 (24 hours) — Social Event free
/// - Matrimonial registration: ₹2100 (yearly)
/// - Family Directory: Free
enum PaymentFeeType { yearly, oneTime, per24Hours, free }

class PaymentConfig {
  PaymentConfig._();

  // --- Feature IDs ---
  static const String loginYearly = 'login_yearly';
  static const String businessRegistration = 'business_registration';
  static const String socialWorker = 'social_worker';
  static const String advertisement = 'advertisement';
  static const String news = 'news';
  static const String events = 'events';
  static const String matrimonialYearly = 'matrimonial_yearly';
  static const String brideRegistration = 'bride_registration';
  static const String groomRegistration = 'groom_registration';
  static const String brideSearch = 'bride_search';
  static const String groomSearch = 'groom_search';
  static const String familyDirectory = 'family_directory';

  // --- Amounts (INR) ---
  static const int loginYearlyAmount = 21;
  static const int businessRegistrationAmount = 201;
  static const int socialWorkerAmount = 0;
  static const int advertisementAmount = 101;
  static const int newsAmount = 101;
  static const int eventsAmount = 101;
  static const int matrimonialYearlyAmount = 2100;
  static const int brideRegistrationAmount = 2100;
  static const int groomRegistrationAmount = 2100;
  static const int brideSearchAmount = 2100;
  static const int groomSearchAmount = 2100;
  static const int familyDirectoryAmount = 0;

  // --- Fee types ---
  static PaymentFeeType feeTypeFor(String featureId) {
    switch (featureId) {
      case loginYearly:
      case matrimonialYearly:
        return PaymentFeeType.yearly;
      case businessRegistration:
      case brideRegistration:
      case groomRegistration:
      case brideSearch:
      case groomSearch:
        return PaymentFeeType.oneTime;
      case familyDirectory:
        return PaymentFeeType.free;
      case advertisement:
      case news:
      case events:
        return PaymentFeeType.per24Hours;
      case socialWorker:
        return PaymentFeeType.free;
      default:
        return PaymentFeeType.oneTime;
    }
  }

  static int amountFor(String featureId) {
    switch (featureId) {
      case loginYearly:
        return loginYearlyAmount;
      case businessRegistration:
        return businessRegistrationAmount;
      case socialWorker:
        return socialWorkerAmount;
      case advertisement:
        return advertisementAmount;
      case news:
        return newsAmount;
      case events:
        return eventsAmount;
      case matrimonialYearly:
        return matrimonialYearlyAmount;
      case brideRegistration:
        return brideRegistrationAmount;
      case groomRegistration:
        return groomRegistrationAmount;
      case brideSearch:
        return brideSearchAmount;
      case groomSearch:
        return groomSearchAmount;
      case familyDirectory:
        return familyDirectoryAmount;
      default:
        return 0;
    }
  }

  /// Duration label for UI: "Yearly", "One-time", "24 hours", "Free"
  static String durationLabelFor(String featureId) {
    switch (feeTypeFor(featureId)) {
      case PaymentFeeType.yearly:
        return 'Yearly';
      case PaymentFeeType.oneTime:
        return 'One-time';
      case PaymentFeeType.per24Hours:
        return '24 hours';
      case PaymentFeeType.free:
        return 'Free';
    }
  }

  static String durationLabelMrFor(String featureId) {
    switch (feeTypeFor(featureId)) {
      case PaymentFeeType.yearly:
        return 'वार्षिक';
      case PaymentFeeType.oneTime:
        return 'एकदा';
      case PaymentFeeType.per24Hours:
        return '२४ तास';
      case PaymentFeeType.free:
        return 'मोफत';
    }
  }

  static String titleFor(String featureId) {
    switch (featureId) {
      case loginYearly:
        return 'Login Yearly (Auto)';
      case businessRegistration:
        return 'Business Registration';
      case socialWorker:
        return 'Social Worker';
      case advertisement:
        return 'Advertisement';
      case news:
        return 'News';
      case events:
        return 'Events';
      case matrimonialYearly:
        return 'Matrimonial Registration';
      case brideRegistration:
        return 'Bride Registration';
      case groomRegistration:
        return 'Groom Registration';
      case brideSearch:
        return 'Bride Search';
      case groomSearch:
        return 'Groom Search';
      case familyDirectory:
        return 'Family Directory';
      default:
        return 'Payment';
    }
  }

  static String titleMrFor(String featureId) {
    switch (featureId) {
      case loginYearly:
        return 'लॉगिन वार्षिक';
      case businessRegistration:
        return 'व्यवसाय नोंदणी';
      case socialWorker:
        return 'सामाजिक कार्यकर्ता';
      case advertisement:
        return 'जाहिरात';
      case news:
        return 'बातम्या';
      case events:
        return 'कार्यक्रम';
      case matrimonialYearly:
        return 'विवाह नोंदणी';
      case brideRegistration:
        return 'वधू नोंदणी';
      case groomRegistration:
        return 'वर नोंदणी';
      case brideSearch:
        return 'वधू शोध';
      case groomSearch:
        return 'वर शोध';
      case familyDirectory:
        return 'कुटुंब निर्देशिका';
      default:
        return '';
    }
  }

  static String subtitleFor(String featureId) {
    switch (featureId) {
      case loginYearly:
        return 'Yearly membership fee (auto-generated).';
      case businessRegistration:
        return 'One-time fee to register your business.';
      case socialWorker:
        return 'Registration is free.';
      case advertisement:
        return '₹101 for 24 hours. Social News Event free of charges.';
      case news:
        return '₹101 for 24 hours. Social News Event free of charges.';
      case events:
        return '₹101 for 24 hours. Social Event free of charges.';
      case matrimonialYearly:
        return 'Yearly fee to register and search groom/bride profiles.';
      case brideRegistration:
        return 'One-time fee to register as bride.';
      case groomRegistration:
        return 'One-time fee to register as groom.';
      case brideSearch:
        return 'One-time fee to search bride profiles.';
      case groomSearch:
        return 'One-time fee to search groom profiles.';
      case familyDirectory:
        return 'Registration and search are free.';
      default:
        return '';
    }
  }

  static String subtitleMrFor(String featureId) {
    switch (featureId) {
      case loginYearly:
        return 'वार्षिक सदस्यत्व शुल्क (स्वयं निर्मित).';
      case businessRegistration:
        return 'व्यवसाय नोंदणी एकदाचे शुल्क.';
      case advertisement:
        return '२४ तासांसाठी ₹१०१. सामाजिक बातमी कार्यक्रम मोफत.';
      case news:
        return '२४ तासांसाठी ₹१०१. सामाजिक बातमी कार्यक्रम मोफत.';
      case events:
        return '२४ तासांसाठी ₹१०१. सामाजिक कार्यक्रम मोफत.';
      case matrimonialYearly:
        return 'वर/वधू प्रोफाइल नोंदणी आणि शोधण्यासाठी वार्षिक शुल्क.';
      case brideRegistration:
        return 'वधू म्हणून नोंदणी करण्यासाठी एकदाचे शुल्क.';
      case groomRegistration:
        return 'वर म्हणून नोंदणी करण्यासाठी एकदाचे शुल्क.';
      case brideSearch:
        return 'वधू प्रोफाइल शोधण्यासाठी एकदाचे शुल्क.';
      case groomSearch:
        return 'वर प्रोफाइल शोधण्यासाठी एकदाचे शुल्क.';
      case familyDirectory:
        return 'नोंदणी आणि शोध मोफत आहेत.';
      default:
        return '';
    }
  }

  static bool isFree(String featureId) => amountFor(featureId) == 0;

  /// Formatted amount e.g. "₹2,100" or "Free"
  static String formattedAmount(int amount) {
    if (amount == 0) return 'Free';
    if (amount >= 1000) {
      final k = amount ~/ 1000;
      final rest = amount % 1000;
      return '₹$k,${rest.toString().padLeft(3, '0')}';
    }
    return '₹$amount';
  }
}
