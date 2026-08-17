import 'dart:io';
import 'package:flutter/material.dart';
import 'package:app_fruticola_tejar/models/producto_model.dart';
import 'package:app_fruticola_tejar/services/producto_service.dart';
import 'package:app_fruticola_tejar/services/storage_service.dart';
import 'package:app_fruticola_tejar/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';

class EditProductScreen extends StatefulWidget {
  final ProductoModel producto;

  const EditProductScreen({
    super.key,
    required this.producto,
  });

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final ProductoService _productoService = ProductoService();
  final StorageService _storageService = StorageService();
  final AuthService _authService = AuthService();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();

  bool _isLoading = false;
  File? _selectedImage;
  String _imagePreviewUrl = '';
  bool _imagenCambiada = false;

  final List<String> _imagenesPrueba = [
    'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=200&h=200&fit=crop',
    'https://images.unsplash.com/photo-1545660276-394d6efda707?w=200&h=200&fit=crop',
    'https://images.unsplash.com/photo-1579613832125-5d34a13ffe2a?w=200&h=200&fit=crop',
    'https://images.unsplash.com/photo-1558618666-fcd25c85f17f?w=200&h=200&fit=crop',
    'https://images.unsplash.com/photo-1553279768-865429fa0078?w=200&h=200&fit=crop',
    'https://images.unsplash.com/photo-1517433670267-08bbd4be890f?w=200&h=200&fit=crop',
    'https://images.unsplash.com/photo-1528825871115-3581a5387919?w=200&h=200&fit=crop',
  ];

  @override
  void initState() {
    super.initState();
    _nombreController.text = widget.producto.nombreProducto;
    _descripcionController.text = widget.producto.descripcion;
    _precioController.text = widget.producto.precio.toString();
    _stockController.text = widget.producto.stock.toString();
    _categoriaController.text = widget.producto.idCategoria;
    _imagePreviewUrl = widget.producto.imagen;
  }

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
        _imagenCambiada = true;
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
                          _imagenCambiada = true;
                          _imagePreviewUrl = _imagenesPrueba[
                              DateTime.now().millisecondsSinceEpoch % _imagenesPrueba.length];
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildOptionButton(
                      icon: Icons.restore,
                      label: 'Restaurar',
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          _selectedImage = null;
                          _imagenCambiada = false;
                          _imagePreviewUrl = widget.producto.imagen;
                        });
                      },
                    ),
                  ),
                ],
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: Colors.green[700]),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.green[700]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _guardarCambios() async {
    if (_nombreController.text.isEmpty) {
      _mostrarMensaje('⚠️ El nombre es obligatorio', Colors.red);
      return;
    }

    if (_precioController.text.isEmpty) {
      _mostrarMensaje('⚠️ El precio es obligatorio', Colors.red);
      return;
    }

    if (_stockController.text.isEmpty) {
      _mostrarMensaje('⚠️ El stock es obligatorio', Colors.red);
      return;
    }

    if (double.tryParse(_precioController.text) == null) {
      _mostrarMensaje('⚠️ Precio inválido', Colors.red);
      return;
    }

    if (int.tryParse(_stockController.text) == null) {
      _mostrarMensaje('⚠️ Stock inválido', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _authService.currentUser;
      if (user == null) {
        _mostrarMensaje('❌ Debes iniciar sesión', Colors.red);
        return;
      }

      String imagenUrl = _imagePreviewUrl;

      if (_selectedImage != null) {
        final uploadResult = await _storageService.uploadProductImage(
          _selectedImage!,
          DateTime.now().millisecondsSinceEpoch.toString(),
        );
        if (uploadResult != null) {
          imagenUrl = uploadResult;
        }
      }

      final data = {
        'nombre_producto': _nombreController.text.trim(),
        'descripcion': _descripcionController.text.trim(),
        'precio': double.parse(_precioController.text.trim()),
        'stock': int.parse(_stockController.text.trim()),
        'id_categoria': _categoriaController.text.trim(),
        'imagen': imagenUrl,
      };

      final success = await _productoService.updateProducto(
        widget.producto.idProducto!,
        data,
      );

      if (success) {
        _mostrarMensaje('✅ Producto actualizado con éxito!', Colors.green);
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        _mostrarMensaje('❌ Error al actualizar el producto', Colors.red);
      }
    } catch (e) {
      _mostrarMensaje('❌ Error: $e', Colors.red);
    }

    setState(() => _isLoading = false);
  }

  Future<void> _confirmarEliminacion() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('⚠️ Confirmar eliminación'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este producto? Esta acción no se puede deshacer.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _eliminarProducto();
    }
  }

  Future<void> _eliminarProducto() async {
    setState(() => _isLoading = true);

    try {
      final success = await _productoService.deleteProducto(
        widget.producto.idProducto!,
      );

      if (success) {
        _mostrarMensaje('✅ Producto eliminado correctamente', Colors.green);
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pop(context, true);
          Navigator.pop(context);
        }
      } else {
        _mostrarMensaje('❌ Error al eliminar producto', Colors.red);
      }
    } catch (e) {
      _mostrarMensaje('❌ Error: $e', Colors.red);
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('✏️ Editar Producto'),
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
                                Text('Toca para cambiar imagen'),
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
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _guardarCambios,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
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
                              '💾 Guardar Cambios',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 10),

              // BOTÓN CANCELAR
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('❌ Cancelar'),
                ),
              ),
              const SizedBox(height: 10),

              // BOTÓN ELIMINAR
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _isLoading ? null : _confirmarEliminacion,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text(
                    '🗑️ Eliminar Producto',
                    style: TextStyle(fontWeight: FontWeight.bold),
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