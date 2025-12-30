import 'dart:io';
import 'supabase_storage_service.dart';
import 'firestore_service.dart';

class UserService {
  final SupabaseStorageService storageService = SupabaseStorageService();
  final FirestoreService profileService = FirestoreService();

  /// Upload profile image and save profile data
  Future<void> uploadProfileAndSave({
    required String uid,
    required String fullName,
    required String email,
    required String phone,
    required String address,
    required File imageFile,
  }) async {
    // 1️⃣ Upload image to Supabase
    final imageUrl = await storageService.uploadImage(
      file: imageFile,
      userId: uid,
    );

    // 2️⃣ Save profile data to Firestore
    await profileService.saveUserProfile(
      uid: uid,
      fullName: fullName,
      email: email,
      phone: phone,
      address: address,
      imageUrl: imageUrl,
    );
  }
}
