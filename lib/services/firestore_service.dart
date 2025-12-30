import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  /// Save or update user profile
  Future<void> saveUserProfile({
    required String uid,
    required String fullName,
    required String email,
    required String phone,
    required String address,
    required String imageUrl,
  }) async {
    await _db.collection('users').doc(uid).set({
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'imageUrl': imageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)); // merge true for update
  }
}
