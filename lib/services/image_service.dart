import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageService {
  static final ImageService _instance = ImageService._internal();
  final ImagePicker _imagePicker = ImagePicker();
  const uuid = const Uuid();

  factory ImageService() {
    return _instance;
  }

  ImageService._internal();

  Future<File?> pickImageFromCamera() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      print('Error picking image from camera: $e');
    }
    return null;
  }

  Future<File?> pickImageFromGallery() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      print('Error picking image from gallery: $e');
    }
    return null;
  }

  Future<List<File>> pickMultipleImages() async {
    try {
      final pickedFiles = await _imagePicker.pickMultiImage(imageQuality: 85);

      return pickedFiles.map((f) => File(f.path)).toList();
    } catch (e) {
      print('Error picking multiple images: $e');
    }
    return [];
  }

  Future<File?> compressImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) return imageFile;

      // Resize if too large
      img.Image resized = image;
      if (image.width > 1920 || image.height > 1920) {
        resized = img.copyResize(
          image,
          width: 1920,
          height: 1920,
          interpolation: img.Interpolation.cubic,
        );
      }

      // Compress
      final compressed = img.encodeJpg(resized, quality: 80);

      final tempDir = await getTemporaryDirectory();
      final compressedFile = File(
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}_compressed.jpg',
      );

      await compressedFile.writeAsBytes(compressed);
      return compressedFile;
    } catch (e) {
      print('Error compressing image: $e');
      return imageFile;
    }
  }

  Future<List<File>> compressMultipleImages(List<File> images) async {
    final compressed = <File>[];
    for (final image in images) {
      final result = await compressImage(image);
      if (result != null) {
        compressed.add(result);
      }
    }
    return compressed;
  }

  String generateFileName(File file) {
    final ext = file.path.split('.').last;
    return '${DateTime.now().millisecondsSinceEpoch}_${const Uuid().v4()}.$ext';
  }

  Future<String> getFileSizeString(File file) async {
    final bytes = await file.length();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
