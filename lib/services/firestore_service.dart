import 'package:cloud_firestore/cloud_firestore.dart';

/// Razorpay (or other gateway) config fetched from Firestore.
/// keySecret is optional; when set (test only), app can create orders from client for UPI/Card checkout.
class PaymentGatewayConfig {
  const PaymentGatewayConfig({
    required this.keyId,
    this.mode = 'test',
    this.keySecret,
  });

  final String keyId;
  final String mode; // 'test' | 'live'
  /// Optional; only for test: create order from client. Never expose in production.
  final String? keySecret;

  bool get isTest => mode == 'test';
  bool get canCreateOrder => keySecret != null && keySecret!.isNotEmpty;
}

/// Firestore wrapper: user profile, payment gateway config, and placeholders for app data.
class FirestoreService {
  FirestoreService._();
  static final FirestoreService _instance = FirestoreService._();
  static FirestoreService get instance => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  /// Payment gateway config: collection [payment]. Tries doc [razorpay], then [test], then first doc.
  CollectionReference<Map<String, dynamic>> get _paymentCollection =>
      _firestore.collection('payment');

  /// Create or update user document after sign-in (phone or email).
  Future<void> setUserProfile({
    required String uid,
    String? email,
    String? phoneNumber,
    String? displayName,
    String? photoUrl,
  }) async {
    final ref = _users.doc(uid);
    final existing = await ref.get();
    final now = FieldValue.serverTimestamp();
    final data = <String, dynamic>{
      'email': email,
      'phoneNumber': phoneNumber,
      'displayName': displayName ?? email?.split('@').first ?? phoneNumber ?? 'User',
      'photoUrl': photoUrl,
      'updatedAt': now,
    };
    if (!existing.exists) {
      data['createdAt'] = now;
    }
    await ref.set(data, SetOptions(merge: true));
  }

  /// Get current user profile from Firestore.
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _users.doc(uid).get();
    return doc.data();
  }

  /// Stream user profile.
  Stream<Map<String, dynamic>?> userProfileStream(String uid) {
    return _users.doc(uid).snapshots().map((doc) => doc.data());
  }

  /// Get user by phone number (for checking if user already exists)
  Future<List<Map<String, dynamic>>?> getUserByPhone(String phoneNumber) async {
    final querySnapshot = await _users
        .where('phoneNumber', isEqualTo: phoneNumber)
        .limit(1)
        .get();
    
    if (querySnapshot.docs.isEmpty) return null;
    return querySnapshot.docs.map((doc) => {...doc.data(), 'uid': doc.id}).toList();
  }

  /// Subscription: 1-year app access after ₹21 payment. Stored on user doc.
  static const String subscriptionValidUntilKey = 'subscriptionValidUntil';

  /// Set subscription valid until (e.g. now + 1 year). Call after successful ₹21 payment.
  Future<void> setSubscriptionValidUntil(String uid, DateTime validUntil) async {
    await _users.doc(uid).set(
      {subscriptionValidUntilKey: Timestamp.fromDate(validUntil), 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }

  /// Check if user has active subscription (validUntil > now).
  Future<bool> hasActiveSubscription(String uid) async {
    final data = await getUserProfile(uid);
    final until = data?[subscriptionValidUntilKey];
    if (until == null) return false;
    if (until is Timestamp) return until.toDate().isAfter(DateTime.now());
    if (until is DateTime) return until.isAfter(DateTime.now());
    return false;
  }

  /// Stream subscription status (for auth gate).
  Stream<bool> subscriptionStatusStream(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      final data = doc.data();
      final until = data?[subscriptionValidUntilKey];
      if (until == null) return false;
      if (until is Timestamp) return until.toDate().isAfter(DateTime.now());
      if (until is DateTime) return until.isAfter(DateTime.now());
      return false;
    });
  }

  // --- Placeholder collections for future features ---

  CollectionReference<Map<String, dynamic>> get _payments =>
      _firestore.collection('payments');

  CollectionReference<Map<String, dynamic>> get _familyDirectory =>
      _firestore.collection('family_directory');

  CollectionReference<Map<String, dynamic>> get _matrimony =>
      _firestore.collection('matrimony');

  CollectionReference<Map<String, dynamic>> get _socialWorkers =>
      _firestore.collection('social_workers');

  CollectionReference<Map<String, dynamic>> get _advertisements =>
      _firestore.collection('advertisements');

  CollectionReference<Map<String, dynamic>> get _news =>
      _firestore.collection('news');

  CollectionReference<Map<String, dynamic>> get _events =>
      _firestore.collection('events');

  CollectionReference<Map<String, dynamic>> get _businesses =>
      _firestore.collection('businesses');

  /// Add business registration (after payment).
  /// [photos] map with keys: ownerPhoto, businessLogo, outdoorPhoto, interiorPhoto1, interiorPhoto2, interiorPhoto3 (all URLs).
  /// [workingHours] map with keys for each day (monday, tuesday, etc.) containing {enabled: bool, from: String, to: String}.
  /// [documents] map with keys: ownersAadhaar, ownersPanCard, businessPan, gstCertificate, udyamCertificate, shopActLicense, iec, businessAddressProof, signature (all booleans).
  Future<void> addBusiness({
    required String userId,
    required String businessName,
    String? typeOfBusiness,
    String? businessStructure,
    String? dateOfEstablishment,
    String? businessDescription,
    String? businessAddress,
    String? businessPincode,
    String? businessCityVillage,
    String? businessTaluka,
    String? businessDistrict,
    String? businessState,
    String? businessEmail,
    String? businessPhone,
    String? website,
    String? ownerName,
    String? ownerSubcaste,
    String? ownerDateOfBirth,
    String? ownerGender,
    String? ownerMobile,
    String? ownerEmail,
    String? ownerResidentialAddress,
    Map<String, String>? photos,
    Map<String, Map<String, dynamic>>? workingHours,
    Map<String, String?>? documents,
    String? createdBy,
  }) async {
    await _businesses.add({
      'userId': userId,
      'businessName': businessName,
      'typeOfBusiness': typeOfBusiness,
      'businessStructure': businessStructure,
      'dateOfEstablishment': dateOfEstablishment,
      'businessDescription': businessDescription,
      'businessAddress': businessAddress,
      'businessPincode': businessPincode,
      'businessCityVillage': businessCityVillage,
      'businessTaluka': businessTaluka,
      'businessDistrict': businessDistrict,
      'businessState': businessState,
      'businessEmail': businessEmail,
      'businessPhone': businessPhone,
      'website': website,
      'ownerName': ownerName,
      'ownerSubcaste': ownerSubcaste,
      'ownerDateOfBirth': ownerDateOfBirth,
      'ownerGender': ownerGender,
      'ownerMobile': ownerMobile,
      'ownerEmail': ownerEmail,
      'ownerResidentialAddress': ownerResidentialAddress,
      'photos': photos ?? {},
      'workingHours': workingHours ?? {},
      'documents': documents ?? {},
      'createdBy': createdBy,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Add family directory entry (after payment).
  /// [familyMembers] optional list of maps with keys: name, relation, age, contact (all strings).
  /// [documents] map with keys: aadhaar, panCard (both String URLs for uploaded images, or null if not uploaded).
  Future<void> addFamilyDirectoryEntry({
    required String userId,
    required String name,
    String? gender,
    String? bloodGroup,
    String? diet,
    String? subcaste,
    String? dateOfBirth,
    String? phone,
    String? whatsappNumber,
    String? email,
    String? permanentAddress,
    String? permanentPincode,
    String? permanentVillageCity,
    String? permanentTaluka,
    String? permanentDistrict,
    String? permanentState,
    String? permanentCountry,
    String? emergencyContactPerson,
    String? emergencyContactNumber,
    List<Map<String, String>>? familyMembers,
    String? createdBy,
    String? photoUrl,
    Map<String, String?>? documents,
  }) async {
    await _familyDirectory.add({
      'userId': userId,
      'name': name,
      'gender': gender,
      'bloodGroup': bloodGroup,
      'diet': diet,
      'subcaste': subcaste,
      'dateOfBirth': dateOfBirth,
      'phone': phone,
      'whatsappNumber': whatsappNumber,
      'email': email,
      'permanentAddress': permanentAddress,
      'permanentPincode': permanentPincode,
      'permanentVillageCity': permanentVillageCity,
      'permanentTaluka': permanentTaluka,
      'permanentDistrict': permanentDistrict,
      'permanentState': permanentState,
      'permanentCountry': permanentCountry,
      'emergencyContactPerson': emergencyContactPerson,
      'emergencyContactNumber': emergencyContactNumber,
      'familyMembers': familyMembers ?? [],
      'createdBy': createdBy,
      'photoUrl': photoUrl,
      'documents': documents ?? {},
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Add matrimony profile (groom or bride, after payment).
  /// [familyMembers] optional list of maps with keys: name, number, relation, age (all strings).
  /// [photoUrl] optional profile photo URL from Firebase Storage (kept for backward compatibility).
  /// [closeupPhotoUrl] optional close-up photo URL (circular).
  /// [fullPhotoUrl] optional full photo URL (rectangular).
  /// [halfPhotoUrl] optional half photo URL (rectangular).
  /// Passport and panCard are optional.
  /// [documents] map with keys: aadhaar, panCard, passport, educationCertificate (all String URLs for uploaded images, or null if not uploaded).
  Future<void> addMatrimonyProfile({
    required String userId,
    required String type,
    required String name,
    String? phone,
    String? whatsappNumber,
    String? email,
    String? dateOfBirth,
    String? age,
    String? birthTime,
    String? birthPlace,
    String? height,
    String? weight,
    String? complexion,
    String? bloodGroup,
    String? diet,
    String? manglik,
    String? nakshatra,
    String? rashi,
    String? gotra,
    String? maritalStatus,
    String? disability,
    String? familyValues,
    String? financialOutlook,
    String? communicationStyle,
    String? hobbiesInterests,
    String? lifeGoals,
    String? education,
    String? occupation,
    String? subcaste,
    String? district,
    String? state,
    String? country,
    String? expectedEducation,
    String? expectedOccupation,
    String? expectedHeight,
    String? expectedFamilyValues,
    String? expectedFinancialOutlook,
    String? expectedCommunicationStyle,
    String? otherExpectations,
    List<Map<String, String>>? familyMembers,
    String? createdBy,
    String? photoUrl,
    String? closeupPhotoUrl,
    String? fullPhotoUrl,
    String? halfPhotoUrl,
    Map<String, String?>? documents,
  }) async {
    await _matrimony.add({
      'userId': userId,
      'type': type,
      'name': name,
      'status': 'pending',
      'phone': phone,
      'whatsappNumber': whatsappNumber,
      'email': email,
      'dateOfBirth': dateOfBirth,
      'age': age,
      'birthTime': birthTime,
      'birthPlace': birthPlace,
      'height': height,
      'weight': weight,
      'complexion': complexion,
      'bloodGroup': bloodGroup,
      'diet': diet,
      'manglik': manglik,
      'nakshatra': nakshatra,
      'rashi': rashi,
      'gotra': gotra,
      'maritalStatus': maritalStatus,
      'disability': disability,
      'familyValues': familyValues,
      'financialOutlook': financialOutlook,
      'communicationStyle': communicationStyle,
      'hobbiesInterests': hobbiesInterests,
      'lifeGoals': lifeGoals,
      'education': education,
      'occupation': occupation,
      'subcaste': subcaste,
      'district': district,
      'state': state,
      'country': country,
      'expectedEducation': expectedEducation,
      'expectedOccupation': expectedOccupation,
      'expectedHeight': expectedHeight,
      'expectedFamilyValues': expectedFamilyValues,
      'expectedFinancialOutlook': expectedFinancialOutlook,
      'expectedCommunicationStyle': expectedCommunicationStyle,
      'otherExpectations': otherExpectations,
      'familyMembers': familyMembers ?? [],
      'createdBy': createdBy,
      'photoUrl': photoUrl,
      'closeupPhotoUrl': closeupPhotoUrl,
      'fullPhotoUrl': fullPhotoUrl,
      'halfPhotoUrl': halfPhotoUrl,
      'documents': documents ?? {},
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Add social worker application (after terms acceptance). Matches APK form fields.
  /// Passport and panCard are optional.
  /// [documents] map with keys: aadhaar, panCard (both String URLs for uploaded images, or null if not uploaded).
  Future<void> addSocialWorker({
    required String userId,
    required String name,
    String? phone,
    String? whatsappNumber,
    String? email,
    String? createdBy,
    String? gender,
    String? bloodGroup,
    String? diet,
    String? subcaste,
    String? dateOfBirth,
    String? permanentAddress,
    String? permanentPincode,
    String? permanentVillageCity,
    String? permanentTaluka,
    String? permanentDistrict,
    String? permanentState,
    String? permanentCountry,
    String? currentAddress,
    String? currentPincode,
    String? currentVillageCity,
    String? currentTaluka,
    String? currentDistrict,
    String? currentState,
    String? currentCountry,
    String? socialWorkInfo,
    int? yearsOfExperience,
    String? specialization,
    String? organization,
    String? description,
    String? photoUrl,
    Map<String, String?>? documents,
  }) async {
    await _socialWorkers.add({
      'userId': userId,
      'name': name,
      'phone': phone,
      'whatsappNumber': whatsappNumber,
      'email': email,
      'createdBy': createdBy,
      'gender': gender,
      'bloodGroup': bloodGroup,
      'diet': diet,
      'subcaste': subcaste,
      'dateOfBirth': dateOfBirth,
      'permanentAddress': permanentAddress,
      'permanentPincode': permanentPincode,
      'permanentVillageCity': permanentVillageCity,
      'permanentTaluka': permanentTaluka,
      'permanentDistrict': permanentDistrict,
      'permanentState': permanentState,
      'permanentCountry': permanentCountry,
      'currentAddress': currentAddress,
      'currentPincode': currentPincode,
      'currentVillageCity': currentVillageCity,
      'currentTaluka': currentTaluka,
      'currentDistrict': currentDistrict,
      'currentState': currentState,
      'currentCountry': currentCountry,
      'socialWorkInfo': socialWorkInfo,
      'yearsOfExperience': yearsOfExperience,
      'specialization': specialization,
      'organization': organization,
      'description': description,
      'photoUrl': photoUrl,
      'documents': documents ?? {},
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Fetch payment gateway config from Firestore (collection [payment]).
  /// Tries document IDs: razorpay, then test, then first document in collection.
  /// Expected fields: key_id or keyId (required), mode (optional, default 'test').
  Future<PaymentGatewayConfig?> getPaymentGatewayConfig() async {
    for (final docId in ['razorpay', 'test']) {
      final snap = await _paymentCollection.doc(docId).get();
      final data = snap.data();
      if (data != null) {
        final keyId = data['key_id'] as String? ?? data['keyId'] as String? ?? data['key'] as String?;
        if (keyId != null && keyId.isNotEmpty) {
          final mode = data['mode'] as String? ?? 'test';
          final keySecret = data['key_secret'] as String? ?? data['keySecret'] as String? ?? data['secret'] as String?;
          return PaymentGatewayConfig(keyId: keyId, mode: mode, keySecret: keySecret);
        }
      }
    }
    final first = await _paymentCollection.limit(1).get();
    if (first.docs.isNotEmpty) {
      final data = first.docs.first.data();
      final keyId = data['key_id'] as String? ?? data['keyId'] as String? ?? data['key'] as String?;
      if (keyId != null && keyId.isNotEmpty) {
        final mode = data['mode'] as String? ?? 'test';
        final keySecret = data['key_secret'] as String? ?? data['keySecret'] as String? ?? data['secret'] as String?;
        return PaymentGatewayConfig(keyId: keyId, mode: mode, keySecret: keySecret);
      }
    }
    return null;
  }

  /// Stream payment gateway config (single emit from same lookup as getPaymentGatewayConfig).
  Stream<PaymentGatewayConfig?> paymentGatewayConfigStream() async* {
    yield await getPaymentGatewayConfig();
  }

  /// Record a payment (for backend tracking; gateway integration later).
  /// When featureId is login_yearly and status is success, subscription is set in PaymentScreen.
  /// When featureId is events/advertisement/news and status is success, validUntil is set to 24 hours from now.
  Future<void> recordPayment({
    required String userId,
    required String featureId,
    required int amountInr,
    required String status,
    String? transactionId,
  }) async {
    await _payments.add({
      'userId': userId,
      'featureId': featureId,
      'amountInr': amountInr,
      'status': status,
      'transactionId': transactionId,
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    // For 24-hour features (events, advertisement, news), set validUntil
    if (status == 'success' && (featureId == 'events' || featureId == 'advertisement' || featureId == 'news')) {
      final validUntil = DateTime.now().add(const Duration(hours: 24));
      await _users.doc(userId).set({
        '${featureId}_validUntil': Timestamp.fromDate(validUntil),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  /// Check if user has valid payment for a feature (for 24-hour features, checks validUntil).
  Future<bool> hasValidPaymentForFeature(String userId, String featureId) async {
    if (featureId == 'events' || featureId == 'advertisement' || featureId == 'news') {
      final data = await getUserProfile(userId);
      final validUntil = data?['${featureId}_validUntil'];
      if (validUntil == null) return false;
      if (validUntil is Timestamp) return validUntil.toDate().isAfter(DateTime.now());
      if (validUntil is DateTime) return validUntil.isAfter(DateTime.now());
      return false;
    }
    // For other features, check if there's at least one successful payment
    final payments = await _payments
        .where('userId', isEqualTo: userId)
        .where('featureId', isEqualTo: featureId)
        .where('status', isEqualTo: 'success')
        .limit(1)
        .get();
    return payments.docs.isNotEmpty;
  }

  // --- Advertisements (Featured on Home) ---

  /// All advertisements (admin).
  Stream<List<Map<String, dynamic>>> streamAdvertisements({int limit = 20}) {
    return _advertisements
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => _docWithId(d)).toList());
  }

  /// Only approved advertisements (public listing).
  Stream<List<Map<String, dynamic>>> streamAdvertisementsApproved({int limit = 20}) {
    return _advertisements
        .where('status', isEqualTo: 'approved')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => _docWithId(d)).toList());
  }

  /// Add advertisement registration (after payment).
  /// [photos] map with keys: ownerPhoto, businessLogo, outdoorPhoto, interiorPhoto1, interiorPhoto2, interiorPhoto3 (all URLs).
  /// [workingHours] map with keys for each day (monday, tuesday, etc.) containing {enabled: bool, from: String, to: String}.
  /// [documents] map with keys: ownersAadhaar, ownersPanCard, businessPan, gstCertificate, udyamCertificate, shopActLicense, iec, businessAddressProof, signature (all booleans).
  Future<void> addAdvertisement({
    required String userId,
    required String businessName,
    String? typeOfBusiness,
    String? businessStructure,
    String? dateOfEstablishment,
    String? businessDescription,
    String? businessAddress,
    String? businessPincode,
    String? businessCityVillage,
    String? businessTaluka,
    String? businessDistrict,
    String? businessState,
    String? businessEmail,
    String? businessPhone,
    String? website,
    String? ownerName,
    String? ownerSubcaste,
    String? ownerDateOfBirth,
    String? ownerGender,
    String? ownerMobile,
    String? ownerEmail,
    String? ownerResidentialAddress,
    Map<String, String>? photos,
    Map<String, Map<String, dynamic>>? workingHours,
    Map<String, String?>? documents,
    String? createdBy,
  }) async {
    await _advertisements.add({
      'userId': userId,
      'businessName': businessName,
      'typeOfBusiness': typeOfBusiness,
      'businessStructure': businessStructure,
      'dateOfEstablishment': dateOfEstablishment,
      'businessDescription': businessDescription,
      'businessAddress': businessAddress,
      'businessPincode': businessPincode,
      'businessCityVillage': businessCityVillage,
      'businessTaluka': businessTaluka,
      'businessDistrict': businessDistrict,
      'businessState': businessState,
      'businessEmail': businessEmail,
      'businessPhone': businessPhone,
      'website': website,
      'ownerName': ownerName,
      'ownerSubcaste': ownerSubcaste,
      'ownerDateOfBirth': ownerDateOfBirth,
      'ownerGender': ownerGender,
      'ownerMobile': ownerMobile,
      'ownerEmail': ownerEmail,
      'ownerResidentialAddress': ownerResidentialAddress,
      'photos': photos ?? {},
      'workingHours': workingHours ?? {},
      'documents': documents ?? {},
      'createdBy': createdBy,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // --- Events (Upcoming on Home) ---

  /// All events (admin).
  Stream<List<Map<String, dynamic>>> streamEvents({int limit = 20}) {
    return _events
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => _docWithId(d)).toList());
  }

  /// Only approved events (public listing).
  Stream<List<Map<String, dynamic>>> streamEventsApproved({int limit = 20}) {
    return _events
        .where('status', isEqualTo: 'approved')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => _docWithId(d)).toList());
  }

  /// Events created by the given user (for "My Events" / organizer RSVP section).
  Stream<List<Map<String, dynamic>>> streamEventsByUser(String userId, {int limit = 50}) {
    return _events
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => _docWithId(d)).toList());
  }

  /// [eventType] 'free' or 'paid'. When 'paid', [ticketAmount] is the entry ticket in ₹.
  /// Add event registration. Matches form fields exactly.
  /// [bannerUrl] optional URL for event banner image.
  /// [date] format: dd/mm/yyyy.
  /// [time] format: HH:MM AM/PM.
  /// [venueAddress] full venue address.
  /// [contactNumber] should include country code prefix if provided.
  Future<void> addEvent({
    required String userId,
    required String title,
    String? bannerUrl,
    String? date,
    String? time,
    String? city,
    String? venueAddress,
    String? description,
    String? organizerName,
    String? contactNumber,
    String? createdBy,
    String eventType = 'free',
    num? ticketAmount,
  }) async {
    await _events.add({
      'userId': userId,
      'title': title,
      'bannerUrl': bannerUrl,
      'date': date,
      'time': time,
      'city': city,
      'venueAddress': venueAddress,
      'location': venueAddress ?? city, // Keep for backward compatibility
      'description': description,
      'organizerName': organizerName,
      'contactNumber': contactNumber,
      'createdBy': createdBy,
      'eventType': eventType == 'paid' ? 'paid' : 'free',
      'ticketAmount': eventType == 'paid' && ticketAmount != null ? ticketAmount : null,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // --- Event RSVPs (Home: RSVP button; OrganizerRSVPsScreen in APK) ---

  CollectionReference<Map<String, dynamic>> get _eventRsvps =>
      _firestore.collection('event_rsvps');

  /// Save RSVP for an event. "Participant information collected through RSVPs will be used only for event management purposes."
  Future<void> addEventRsvp({
    required String eventId,
    required String userId,
    String? displayName,
    String? email,
    String? phone,
  }) async {
    final ref = _eventRsvps.doc('${eventId}_$userId');
    await ref.set({
      'eventId': eventId,
      'userId': userId,
      'displayName': displayName,
      'email': email,
      'phone': phone,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Check if current user has RSVPed for this event.
  Future<bool> hasUserRsvpedForEvent(String eventId, String userId) async {
    final doc = await _eventRsvps.doc('${eventId}_$userId').get();
    return doc.exists;
  }

  /// Stream: has current user RSVPed (for button state on home).
  Stream<bool> streamHasUserRsvpedForEvent(String eventId, String userId) {
    return _eventRsvps.doc('${eventId}_$userId').snapshots().map((doc) => doc.exists);
  }

  /// List RSVPs for an event (for organizer).
  Stream<List<Map<String, dynamic>>> streamEventRsvps(String eventId) {
    return _eventRsvps
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snap) => snap.docs.map((d) => _docWithId(d)).toList());
  }

  /// Remove RSVP (cancel).
  Future<void> removeEventRsvp(String eventId, String userId) async {
    await _eventRsvps.doc('${eventId}_$userId').delete();
  }

  // --- News (Latest on Home) ---

  /// All news (admin).
  Stream<List<Map<String, dynamic>>> streamNews({int limit = 20}) {
    return _news
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => _docWithId(d)).toList());
  }

  /// Only approved news (public listing).
  Stream<List<Map<String, dynamic>>> streamNewsApproved({int limit = 20}) {
    return _news
        .where('status', isEqualTo: 'approved')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => _docWithId(d)).toList());
  }

  Future<void> addNews({
    required String userId,
    required String title,
    required String description,
    String? imageUrl,
    String? createdBy,
  }) async {
    await _news.add({
      'userId': userId,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'createdBy': createdBy,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // --- Feedback (user submissions; admin can list in AdminFeedbackScreen) ---

  CollectionReference<Map<String, dynamic>> get _feedback =>
      _firestore.collection('feedback');

  Future<void> addFeedback({
    required String userId,
    required String text,
    String? userEmail,
    String? userDisplayName,
  }) async {
    await _feedback.add({
      'userId': userId,
      'text': text,
      'userEmail': userEmail,
      'userDisplayName': userDisplayName,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> streamFeedback({int limit = 100}) {
    return _feedback
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => _docWithId(d)).toList());
  }

  Future<void> deleteFeedback(String feedbackId) async {
    await _feedback.doc(feedbackId).delete();
  }

  Future<void> updateFeedbackStatus(String id, String status) async {
    await _feedback.doc(id).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // --- Admin: delete content ---
  Future<void> deleteAdvertisement(String id) async {
    await _advertisements.doc(id).delete();
  }

  Future<void> updateAdvertisementStatus(String id, String status) async {
    await _advertisements.doc(id).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteNews(String id) async {
    await _news.doc(id).delete();
  }

  Future<void> updateNewsStatus(String id, String status) async {
    await _news.doc(id).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteEvent(String id) async {
    await _events.doc(id).delete();
  }

  Future<void> updateEventStatus(String id, String status) async {
    await _events.doc(id).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// All businesses (admin list).
  Stream<List<Map<String, dynamic>>> streamBusinesses({int limit = 200}) {
    return _businesses
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => _docWithId(d)).toList());
  }

  /// Only approved businesses (public listing).
  Stream<List<Map<String, dynamic>>> streamBusinessesApproved({int limit = 200}) {
    return _businesses
        .where('status', isEqualTo: 'approved')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => _docWithId(d)).toList());
  }

  Future<void> deleteBusiness(String id) async {
    await _businesses.doc(id).delete();
  }

  /// Update business status: pending | approved | rejected.
  Future<void> updateBusinessStatus(String id, String status) async {
    await _businesses.doc(id).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// All family_directory (admin list).
  Stream<List<Map<String, dynamic>>> streamFamilyDirectory({int limit = 200}) {
    return _familyDirectory
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => _docWithId(d)).toList());
  }

  /// Only approved family directory entries (public listing).
  Stream<List<Map<String, dynamic>>> streamFamilyDirectoryApproved({int limit = 200}) {
    return _familyDirectory
        .where('status', isEqualTo: 'approved')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => _docWithId(d)).toList());
  }

  /// True if this user has any family directory entry.
  Future<bool> hasUserRegisteredFamilyDirectory(String userId) async {
    final snap = await _familyDirectory.where('userId', isEqualTo: userId).limit(1).get();
    return snap.docs.isNotEmpty;
  }

  /// True if this user has any matrimony profile (bride or groom).
  Future<bool> hasUserRegisteredMatrimony(String userId) async {
    final snap = await _matrimony.where('userId', isEqualTo: userId).limit(1).get();
    return snap.docs.isNotEmpty;
  }

  /// True if this user has any business registration.
  Future<bool> hasUserRegisteredBusiness(String userId) async {
    final snap = await _businesses.where('userId', isEqualTo: userId).limit(1).get();
    return snap.docs.isNotEmpty;
  }

  /// True if this user has any social worker registration.
  Future<bool> hasUserRegisteredSocialWorker(String userId) async {
    final snap = await _socialWorkers.where('userId', isEqualTo: userId).limit(1).get();
    return snap.docs.isNotEmpty;
  }

  /// Get user's family directory registration (most recent).
  Future<Map<String, dynamic>?> getUserFamilyDirectoryRegistration(String userId) async {
    final snap = await _familyDirectory.where('userId', isEqualTo: userId).orderBy('createdAt', descending: true).limit(1).get();
    if (snap.docs.isEmpty) return null;
    return _docWithId(snap.docs.first);
  }

  /// Get user's matrimony registration (most recent, bride or groom).
  Future<Map<String, dynamic>?> getUserMatrimonyRegistration(String userId) async {
    final snap = await _matrimony.where('userId', isEqualTo: userId).orderBy('createdAt', descending: true).limit(1).get();
    if (snap.docs.isEmpty) return null;
    return _docWithId(snap.docs.first);
  }

  /// Get user's business registration (most recent).
  Future<Map<String, dynamic>?> getUserBusinessRegistration(String userId) async {
    final snap = await _businesses.where('userId', isEqualTo: userId).orderBy('createdAt', descending: true).limit(1).get();
    if (snap.docs.isEmpty) return null;
    return _docWithId(snap.docs.first);
  }

  /// Get user's social worker registration (most recent).
  Future<Map<String, dynamic>?> getUserSocialWorkerRegistration(String userId) async {
    final snap = await _socialWorkers.where('userId', isEqualTo: userId).orderBy('createdAt', descending: true).limit(1).get();
    if (snap.docs.isEmpty) return null;
    return _docWithId(snap.docs.first);
  }

  Future<void> deleteFamilyDirectoryEntry(String id) async {
    await _familyDirectory.doc(id).delete();
  }

  Future<void> updateFamilyDirectoryStatus(String id, String status) async {
    await _familyDirectory.doc(id).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// All matrimony (admin list).
  Stream<List<Map<String, dynamic>>> streamMatrimony({int limit = 200}) {
    return _matrimony
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => _docWithId(d)).toList());
  }

  /// Only approved matrimony profiles (public listing).
  Stream<List<Map<String, dynamic>>> streamMatrimonyApproved({int limit = 200}) {
    return _matrimony
        .where('status', isEqualTo: 'approved')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => _docWithId(d)).toList());
  }

  Future<void> deleteMatrimonyProfile(String id) async {
    await _matrimony.doc(id).delete();
  }

  Future<void> updateMatrimonyStatus(String id, String status) async {
    await _matrimony.doc(id).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// All social_workers (admin list).
  Stream<List<Map<String, dynamic>>> streamSocialWorkers({int limit = 200}) {
    return _socialWorkers
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => _docWithId(d)).toList());
  }

  /// Only approved social workers (public listing).
  Stream<List<Map<String, dynamic>>> streamSocialWorkersApproved({int limit = 200}) {
    return _socialWorkers
        .where('status', isEqualTo: 'approved')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => _docWithId(d)).toList());
  }

  Future<void> deleteSocialWorker(String id) async {
    await _socialWorkers.doc(id).delete();
  }

  Future<void> updateSocialWorkerStatus(String id, String status) async {
    await _socialWorkers.doc(id).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // --- Admin: user management ---
  Future<void> setUserAdmin(String uid, bool isAdmin) async {
    await _users.doc(uid).set(
      {'isAdmin': isAdmin, 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }

  Future<void> setUserSuspended(String uid, bool suspended) async {
    await _users.doc(uid).set(
      {'isSuspended': suspended, 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }

  /// Delete user profile document (Firestore only; Auth user unchanged).
  Future<void> deleteUserProfile(String uid) async {
    await _users.doc(uid).delete();
  }

  // --- Admin: check if user is admin (users/{uid}.isAdmin) ---

  Future<bool> isAdmin(String uid) async {
    final doc = await _users.doc(uid).get();
    final data = doc.data();
    return data?['isAdmin'] == true;
  }

  // --- User goals (stored in user profile) ---

  Future<void> setUserGoals(String uid, String goals) async {
    await _users.doc(uid).set(
      {'lifeGoals': goals, 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }

  Map<String, dynamic> _docWithId(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    data['id'] = doc.id;
    return data;
  }
}
