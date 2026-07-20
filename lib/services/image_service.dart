import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static Future<List<XFile>> pickImages({int maxCount = 5}) async {
    final images = await _picker.pickMultiImage(
      imageQuality: 85,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (images.length > maxCount) return images.sublist(0, maxCount);
    return images;
  }

  static Future<XFile?> pickSingleImage() async {
    return _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
      maxHeight: 1024,
    );
  }

  static Future<String> uploadImage(String filePath, String uid, String folder) async {
    final ref = _storage
        .ref()
        .child('$folder/$uid/${DateTime.now().millisecondsSinceEpoch}');
    await ref.putFile(File(filePath));
    return await ref.getDownloadURL();
  }

  static Future<List<String>> uploadImages(List<XFile> images, String uid, String folder) async {
    final urls = <String>[];
    for (final image in images) {
      final url = await uploadImage(image.path, uid, folder);
      urls.add(url);
    }
    return urls;
  }

  static Future<void> deleteImage(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (_) {}
  }
}
