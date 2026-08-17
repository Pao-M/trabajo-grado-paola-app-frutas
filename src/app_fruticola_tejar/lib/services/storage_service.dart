import 'dart:io';

class StorageService {
  // Servicio desactivado - usa imágenes de prueba
  Future<String?> uploadImage(File imageFile, String path) async {
    // Simula una subida exitosa
    await Future.delayed(const Duration(milliseconds: 500));
    return 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=200&h=200&fit=crop';
  }

  Future<String?> uploadProductImage(File imageFile, String productoId) async {
    return await uploadImage(imageFile, 'productos/$productoId.jpg');
  }

  Future<bool> deleteImage(String path) async {
    return true;
  }

  Future<String?> getImageUrl(String path) async {
    return 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=200&h=200&fit=crop';
  }
}