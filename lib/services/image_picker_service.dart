import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'firebase_auth_service.dart';
import 'firebase_storage_service.dart';

/// Shared service for picking and uploading images across all forms.
class ImagePickerService {
  ImagePickerService._internal();
  static final ImagePickerService instance = ImagePickerService._internal();

  final ImagePicker _picker = ImagePicker();

  /// Show modal bottom sheet to select image source (Gallery or Camera).
  /// Returns the selected ImageSource or null if cancelled.
  Future<ImageSource?> showImageSourcePicker(BuildContext context) async {
    return await showModalBottomSheet<ImageSource>(
      context: context,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: const Text('Gallery / गॅलरी'),
                onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.green),
                title: const Text('Camera / कॅमेरा'),
                onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
                title: const Text('Cancel / रद्द करा'),
                onTap: () => Navigator.of(ctx).pop(),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  /// Pick and upload an image. Returns the download URL or null on failure.
  /// Shows loading indicator and error messages automatically.
  Future<String?> pickAndUploadImage({
    required BuildContext context,
    required String storagePath,
    int maxWidth = 1920,
    int maxHeight = 1080,
    int imageQuality = 85,
    String? successMessage,
    String? errorMessage,
  }) async {
    final user = FirebaseAuthService.instance.currentUser;
    if (user == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to upload images')),
        );
      }
      return null;
    }

    // Show image source picker
    final source = await showImageSourcePicker(context);
    if (source == null || !context.mounted) return null;

    try {
      // Pick image
      final xFile = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
      );

      if (xFile == null || !context.mounted) return null;

      // Read bytes
      final bytes = await xFile.readAsBytes();
      
      // Check file size
      if (bytes.length > FirebaseStorageService.maxBytes) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image must be under 1MB. Please choose a smaller image.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return null;
      }

      // Upload to Firebase Storage
      final path = FirebaseStorageService.instance.uniquePath(storagePath, extension: 'jpg');
      final url = await FirebaseStorageService.instance.uploadImage(bytes: bytes, path: path);

      if (!context.mounted) return null;

      if (url != null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successMessage ?? 'Image uploaded successfully.'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return url;
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage ?? 'Upload failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return null;
      }
    } catch (e) {
      if (context.mounted) {
        String errorMsg = 'Failed to upload image.';
        if (e.toString().contains('permission')) {
          errorMsg = 'Permission denied. Please grant camera/gallery access in settings.';
        } else if (e.toString().contains('camera')) {
          errorMsg = 'Camera not available. Please try gallery instead.';
        } else {
          errorMsg = 'Error: ${e.toString()}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return null;
    }
  }
}
