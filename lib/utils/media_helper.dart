import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';

class MediaHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Picks an image and compresses it to be under [targetSizeKb] (default 200KB).
  /// If [isVideo] is true, it picks a video but does not currently compress it here.
  static Future<File?> pickAndCompressImage({
    ImageSource source = ImageSource.gallery,
    int targetSizeKb = 200,
    bool isVideo = false,
    bool cropToSquare = false,
  }) async {
    if (isVideo) {
      final XFile? video = await _picker.pickVideo(source: source);
      return video != null ? File(video.path) : null;
    }

    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 100, // We will handle compression manually for precision
    );

    if (image == null) return null;

    File file = File(image.path);

    if (cropToSquare) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (croppedFile == null) return null;
      file = File(croppedFile.path);
    }

    int fileSize = await file.length();
    
    // If it's already under the target size, return it
    if (fileSize <= targetSizeKb * 1024) {
      return file;
    }

    // Compress in a loop to ensure we hit the target
    int quality = 85;
    File? compressedFile;

    // Use a temporary directory for compressed files
    final Directory tempDir = await getTemporaryDirectory();
    
    while (fileSize > targetSizeKb * 1024 && quality > 10) {
      final String targetPath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}_compressed.jpg';
      
      final XFile? result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
      );

      if (result == null) break;

      compressedFile = File(result.path);
      fileSize = await compressedFile.length();
      
      quality -= 15; // Reduce quality for the next iteration if needed
    }

    return compressedFile ?? file;
  }
}
