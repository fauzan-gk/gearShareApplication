import 'dart:async';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PickedImage {
  final XFile file;
  final Uint8List bytes;

  PickedImage(this.file, this.bytes);
}

class ImageService {
  static final ImagePicker _picker = ImagePicker();
  static final SupabaseClient _supabase = Supabase.instance.client;
  static const String _bucket = 'gearshare-images';

  static Future<List<PickedImage>> pickImages({int maxCount = 5}) async {
    final images = await _picker.pickMultiImage(
      imageQuality: 85,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    final picked = <PickedImage>[];
    for (final img in images) {
      if (picked.length >= maxCount) break;
      picked.add(PickedImage(img, await img.readAsBytes()));
    }
    return picked;
  }

  static Future<PickedImage?> pickSingleImage() async {
    final img = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (img == null) return null;
    return PickedImage(img, await img.readAsBytes());
  }

  static String _filePath(String uid, String folder) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$folder/$uid/$timestamp';
  }

  static Future<String> uploadImage(
    PickedImage image,
    String uid,
    String folder,
  ) async {
    final path = _filePath(uid, folder);
    await _supabase.storage.from(_bucket).uploadBinary(
      path,
      image.bytes,
    ).timeout(const Duration(seconds: 30));
    final url = _supabase.storage.from(_bucket).getPublicUrl(path);
    return url;
  }

  static Future<List<String>> uploadImages(
    List<PickedImage> images,
    String uid,
    String folder,
  ) async {
    final urls = <String>[];
    for (final image in images) {
      final url = await uploadImage(image, uid, folder);
      urls.add(url);
    }
    return urls;
  }

  static Future<void> deleteImage(String url) async {
    try {
      final uri = Uri.parse(url);
      final path = uri.pathSegments.skip(2).join('/');
      await _supabase.storage.from(_bucket).remove([path]);
    } catch (_) {}
  }
}
