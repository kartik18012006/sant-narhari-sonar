import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

/// Upload images to Firebase Storage and return download URLs.
/// Works on mobile and web (uses bytes / putData for cross-platform).
class FirebaseStorageService {
  FirebaseStorageService._();
  static final FirebaseStorageService _instance = FirebaseStorageService._();
  static FirebaseStorageService get instance => _instance;

  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Max file size for photo uploads (1MB).
  static const int maxBytes = 1024 * 1024;

  /// Upload image bytes to the given path and return its download URL.
  /// Use [bytes] from XFile.readAsBytes() (works on mobile and web).
  /// Returns null on failure.
  Future<String?> uploadImage({
    required Uint8List bytes,
    required String path,
    int? maxSizeBytes,
  }) async {
    try {
      final max = maxSizeBytes ?? maxBytes;
      if (bytes.length > max) return null;
      final ref = _storage.ref().child(path);
      await ref.putData(bytes);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (_) {
      return null;
    }
  }

  /// Generate a unique path for a photo under a folder.
  String uniquePath(String folderPrefix, {String extension = 'jpg'}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$folderPrefix/$timestamp.$extension';
  }

  /// Delete a file at the given path.
  Future<void> delete(String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.delete();
    } catch (_) {}
  }
}
