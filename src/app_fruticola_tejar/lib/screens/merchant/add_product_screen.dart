import 'dart:io';
import 'package:flutter/material.dart';
import 'package:app_fruticola_tejar/models/producto_model.dart';
import 'package:app_fruticola_tejar/services/producto_service.dart';
import 'package:app_fruticola_tejar/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final ProductoService _productoService = ProductoService();
  final AuthService _authService = AuthService();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();

  bool _isLoading = false;
  File? _selectedImage;
  String _imagePreviewUrl = '';

  final List<String> _imagenesPrueba = [
    'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=200&h=200&fit=crop',
    'https://images.unsplash.com/photo-1545660276-394d6efda707?w=200&h=200&fit=crop',
    'https://images.unsplash.com/photo-1579613832125-5d34a13ffe2a?w=200&h=200&fit=crop',
    'https://images.unsplash.com/photo-1558618666-fcd25c85f17f?w=200&h=200&fit=crop',
    'https://images.unsplash.com/photo-1553279768-865429fa0078?w=200&h=200&fit=crop',
    'https://images.unsplash.com/photo-1517433670267-08bbd4be890f?w=200&h=200&fit=crop',
    'https://images.unsplash.com/photo-1528825871115-3581a5387919?w=200&h=200&fit=crop',
  ];
  int _imagenSeleccionadaIndex = 0;

  void _mostrarMensaje(String mensaje, Color color) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == Colors.green ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(mensaje)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _imagePreviewUrl = '';
      });
    }
  }

  void _selectImageFromGallery() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🍎 Seleccionar imagen',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _buildOptionButton(
                      icon: Icons.photo_library,
                      label: 'Imagen de prueba',
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          _selectedImage = null;
                          _imagePreviewUrl = _imagenesPrueba[_imagenSeleccionadaIndex];
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildOptionButton(
                      icon: Icons.camera_alt,
                      label: 'Mi imagen',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_imagePreviewUrl.isEmpty && _selectedImage == null)
                const Text(
                  'Selecciona una imagen de prueba o sube una propia',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.green[700]),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: Colors.green[700])),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProduct() async {
    // Validar nombre
    if (_nombreController.text.isEmpty) {
      _mostrarMensaje('⚠️ El nombre del producto es obligatorio', Colors.red);
      return;
    }

    // Validar precio
    if (_precioController.text.isEmpty) {
      _mostrarMensaje('⚠️ El precio es obligatorio', Colors.red);
      return;
    }

    // Validar stock
    if (_stockController.text.isEmpty) {
      _mostrarMensaje('⚠️ El stock es obligatorio', Colors.red);
      return;
    }

    // Validar que precio sea número
    if (double.tryParse(_precioController.text) == null) {
      _mostrarMensaje('⚠️ Ingresa un precio válido (ej: 5.00)', Colors.red);
      return;
    }

    // Validar que stock sea número
    if (int.tryParse(_stockController.text) == null) {
      _mostrarMensaje('⚠️ Ingresa un stock válido (ej: 10)', Colors.red);
      return;
    }

    // Validar que precio sea mayor a 0
    if (double.parse(_precioController.text) <= 0) {
      _mostrarMensaje('⚠️ El precio debe ser mayor a 0', Colors.red);
      return;
    }

    // Validar que stock sea mayor a 0
    if (int.parse(_stockController.text) <= 0) {
      _mostrarMensaje('⚠️ El stock debe ser mayor a 0', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = _authService.currentUser;
      if (user == null) {
        _mostrarMensaje('❌ Debes iniciar sesión como comerciante', Colors.red);
        return;
      }

      String imagenUrl = '';

      if (_imagePreviewUrl.isNotEmpty) {
        imagenUrl = _imagePreviewUrl;
      } else if (_selectedImage != null) {
        imagenUrl = _imagenesPrueba[_imagenSeleccionadaIndex];
      }

      if (imagenUrl.isEmpty) {
        imagenUrl = 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=200&h=200&fit=crop';
      }

      final producto = ProductoModel(
        nombreProducto: _nombreController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        precio: double.parse(_precioController.text.trim()),
        stock: int.parse(_stockController.text.trim()),
        imagen: imagenUrl,
        idCategoria: _categoriaController.text.trim(),
        idComerciante: user.uid,
      );

      final result = await _productoService.createProducto(producto);

      if (result != null) {
        _mostrarMensaje('✅ ¡Producto agregado con éxito!', Colors.green);
        _nombreController.clear();
        _descripcionController.clear();
        _precioController.clear();
        _stockController.clear();
        _categoriaController.clear();
        setState(() {
          _selectedImage = null;
          _imagePreviewUrl = '';
        });
      } else {
        _mostrarMensaje('❌ Error al guardar el producto', Colors.red);
      }
    } catch (e) {
      _mostrarMensaje('❌ Error: $e', Colors.red);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🍎 Agregar Producto'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[50],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // IMAGEN
              GestureDetector(
                onTap: _selectImageFromGallery,
                child: Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.image_not_supported, size: 50);
                            },
                          ),
                        )
                      : _imagePreviewUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                _imagePreviewUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.image_not_supported, size: 50);
                                },
                              ),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Toca para seleccionar imagen'),
                                Text(
                                  '(Prueba o propia)',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 16),

              // NOMBRE
              TextField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: '🍎 Nombre del producto',
                  prefixIcon: Icon(Icons.apple),
                ),
              ),
              const SizedBox(height: 14),

              // DESCRIPCIÓN
              TextField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: '📝 Descripción',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 14),

              // PRECIO
              TextField(
                controller: _precioController,
                decoration: const InputDecoration(
                  labelText: '💰 Precio (Bs.)',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 14),

              // STOCK
              TextField(
                controller: _stockController,
                decoration: const InputDecoration(
                  labelText: '📦 Stock disponible',
                  prefixIcon: Icon(Icons.production_quantity_limits),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 14),

              // CATEGORÍA
              TextField(
                controller: _categoriaController,
                decoration: const InputDecoration(
                  labelText: '🏷️ Categoría',
                  prefixIcon: Icon(Icons.category),
                ),
              ),
              const SizedBox(height: 20),

              // BOTÓN GUARDAR
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save, color: Colors.white),
                            SizedBox(width: 10),
                            Text(
                              ' Guardar Producto',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}