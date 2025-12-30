import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Upload image to Supabase and return public URL
  Future<String> uploadImage({
    required File file,
    required String userId,
  }) async {
    final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';

    // Upload file
    await _client.storage.from('user-images').upload(fileName, file);

    // Get public URL
    final imageUrl = _client.storage.from('user-images').getPublicUrl(fileName);

    return imageUrl;
  }
}
