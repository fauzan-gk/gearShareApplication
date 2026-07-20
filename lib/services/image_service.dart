import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PickedImage {
  final XFile file;
  final Uint8List bytes;

  PickedImage(this.file, this.bytes);
}

class ImageService {
  static final ImagePicker _picker = ImagePicker();
  static final FirebaseStorage _storage = FirebaseStorage.instance;

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

  static Future<String> uploadImage(
    PickedImage image,
    String uid,
    String folder,
  ) async {
    final ref = _storage
        .ref()
        .child('$folder/$uid/${DateTime.now().millisecondsSinceEpoch}');
    await ref.putData(image.bytes);
    return await ref.getDownloadURL();
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
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (_) {}
  }
}
