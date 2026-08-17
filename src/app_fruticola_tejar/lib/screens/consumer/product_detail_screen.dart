import 'package:flutter/material.dart';
import 'package:app_fruticola_tejar/models/producto_model.dart';
import 'package:app_fruticola_tejar/services/reserva_service.dart';
import 'package:app_fruticola_tejar/models/reserva_model.dart';
import 'package:app_fruticola_tejar/services/auth_service.dart';
import 'package:app_fruticola_tejar/services/usuario_service.dart';
import 'package:app_fruticola_tejar/screens/merchant/edit_product_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductoModel producto;

  const ProductDetailScreen({
    super.key,
    required this.producto,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ReservaService _reservaService = ReservaService();
  final AuthService _authService = AuthService();
  final UsuarioService _usuarioService = UsuarioService();
  int _cantidad = 1;
  bool _isLoading = false;
  String _rol = 'consumidor';

  @override
  void initState() {
    super.initState();
    _cargarRol();
  }

  Future<void> _cargarRol() async {
    final user = _authService.currentUser;
    if (user != null) {
      final rol = await _usuarioService.getRolUsuario(user.email!);
      setState(() {
        _rol = rol ?? 'consumidor';
      });
    }
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
        duration: const Duration(seconds: 2),
      ),
    );
  }

  bool _esComerciante() {
    return _rol == 'comerciante';
  }

  @override
  Widget build(BuildContext context) {
    final bool hasStock = widget.producto.stock > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🍎 Detalle del Producto'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          if (_esComerciante())
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProductScreen(
                      producto: widget.producto,
                    ),
                  ),
                ).then((result) {
                  if (result == true && mounted) {
                    Navigator.pop(context);
                  }
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGEN
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: widget.producto.imagen.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        widget.producto.imagen,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 60,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image,
                        size: 60,
                        color: Colors.grey,
                      ),
                    ),
            ),
            const SizedBox(height: 16),

            // NOMBRE Y PRECIO
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.producto.nombreProducto,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.attach_money,
                        color: Colors.white,
                        size: 16,
                      ),
                      Text(
                        widget.producto.precio.toStringAsFixed(2),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // STOCK
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: hasStock
                    ? const Color(0xFFE8F5E9)
                    : const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    hasStock ? Icons.check_circle : Icons.cancel,
                    color: hasStock ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    hasStock
                        ? '📦 Stock: ${widget.producto.stock} unidades'
                        : '❌ Producto agotado',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: hasStock ? Colors.green[700] : Colors.red[700],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // DESCRIPCIÓN
            const Text(
              '📝 Descripción',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                widget.producto.descripcion.isNotEmpty
                    ? widget.producto.descripcion
                    : 'Sin descripción disponible',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // CANTIDAD
            const Text(
              '🔢 Cantidad',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                GestureDetector(
                  onTap: _cantidad > 1
                      ? () {
                          setState(() {
                            _cantidad--;
                          });
                        }
                      : null,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _cantidad > 1
                          ? const Color(0xFF2E7D32)
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.remove,
                      color: _cantidad > 1 ? Colors.white : Colors.grey[500],
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Container(
                  width: 50,
                  alignment: Alignment.center,
                  child: Text(
                    '$_cantidad',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                GestureDetector(
                  onTap: _cantidad < widget.producto.stock
                      ? () {
                          setState(() {
                            _cantidad++;
                          });
                        }
                      : null,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _cantidad < widget.producto.stock
                          ? const Color(0xFF2E7D32)
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.add,
                      color: _cantidad < widget.producto.stock
                          ? Colors.white
                          : Colors.grey[500],
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  'Máx: ${widget.producto.stock}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // BOTÓN RESERVAR
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: hasStock && !_isLoading
                    ? _realizarReserva
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasStock
                      ? const Color(0xFFFF9800)
                      : Colors.grey[400],
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
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            hasStock ? Icons.shopping_cart : Icons.block,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            hasStock
                                ? '🛒 Reservar Ahora'
                                : 'Producto Agotado',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 10),

            // BOTÓN VOLVER
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: Color(0xFF2E7D32),
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '⬅️ Volver a productos',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _realizarReserva() async {
    final user = _authService.currentUser;

    if (user == null) {
      _mostrarMensaje('🔒 Debes iniciar sesión para reservar', Colors.red);
      return;
    }

    if (_cantidad > widget.producto.stock) {
      _mostrarMensaje('⚠️ No hay suficiente stock disponible', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final reserva = ReservaModel(
        fechaReserva: DateTime.now(),
        cantidad: _cantidad,
        estado: 'pendiente',
        idUsuario: user.uid,
        idProducto: widget.producto.idProducto!,
        idComerciante: widget.producto.idComerciante,
      );

      final reservaId = await _reservaService.createReserva(reserva);

      if (reservaId != null) {
        final nuevoStock = widget.producto.stock - _cantidad;
        await _reservaService.actualizarStockProducto(
          widget.producto.idProducto!,
          nuevoStock,
        );

        _mostrarMensaje('✅ ¡Reserva realizada con éxito!', Colors.green);
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        _mostrarMensaje('❌ Error al realizar la reserva', Colors.red);
      }
    } catch (e) {
      _mostrarMensaje('❌ Error: $e', Colors.red);
    }

    setState(() {
      _isLoading = false;
    });
  }
}