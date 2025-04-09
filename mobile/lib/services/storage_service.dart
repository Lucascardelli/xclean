import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/constants.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  Future<String> uploadProfilePhoto(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: AppConstants.maxImageWidth.toDouble(),
        maxHeight: AppConstants.maxImageHeight.toDouble(),
        imageQuality: AppConstants.imageQuality,
      );

      if (image == null) {
        throw Exception('Nenhuma imagem selecionada');
      }

      // Verifica o tamanho do arquivo
      final File file = File(image.path);
      final int fileSize = await file.length();
      if (fileSize > AppConstants.maxImageSize) {
        throw Exception('A imagem deve ter no máximo 5MB');
      }

      // Verifica o tipo do arquivo
      final String extension = image.path.split('.').last.toLowerCase();
      if (!AppConstants.allowedImageTypes.contains(extension)) {
        throw Exception('Formato de imagem não suportado. Use JPG ou PNG');
      }

      // Gera um nome único para o arquivo
      final String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final Reference ref = _storage.ref().child('profile_photos/$fileName');

      // Faz o upload do arquivo
      final UploadTask uploadTask = ref.putFile(file);
      final TaskSnapshot snapshot = await uploadTask;

      // Retorna a URL do arquivo
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Erro ao fazer upload da foto: $e');
    }
  }

  Future<void> deleteProfilePhoto(String? photoUrl) async {
    if (photoUrl == null) return;

    try {
      final Reference ref = _storage.refFromURL(photoUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Erro ao deletar a foto: $e');
    }
  }
} 