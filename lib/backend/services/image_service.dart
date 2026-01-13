import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageService {
  static final ImageService instance = ImageService._init();

  ImageService._init();

  Future<XFile?> pickImage(ImageSource source) async {
    final imagePicker = ImagePicker();
    return await imagePicker.pickImage(source: source);
  }
  
  Future<String> saveImage(XFile imageFile, String noteId) async {
    final directory = await getApplicationDocumentsDirectory();
    final imageDir = Directory('${directory.path}/images');
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }
    
    final fileName = '${noteId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedPath = '${imageDir.path}/$fileName';
    await imageFile.saveTo(savedPath);
    return savedPath;
  }
  
  Future<void> deleteImage(String? imagePath) async {
    if (imagePath != null) {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  // noteId로 시작하는 모든 이미지 파일 삭제 (업데이트 시 기존 이미지 정리용)
  Future<void> deleteImagesByNoteId(String noteId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imageDir = Directory('${directory.path}/images');
      
      if (!await imageDir.exists()) {
        return;
      }

      // noteId로 시작하는 모든 파일 찾기
      final files = imageDir.listSync();
      for (var file in files) {
        if (file is File) {
          final fileName = file.path.split('/').last;
          if (fileName.startsWith('${noteId}_')) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      // 에러 발생 시 무시 (파일이 없을 수도 있음)
    }
  }
}