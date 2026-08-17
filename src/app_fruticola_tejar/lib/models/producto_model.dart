class ProductoModel {
  final String? idProducto;
  final String nombreProducto;
  final String descripcion;
  final double precio;
  final int stock;
  final String imagen;
  final String idCategoria;
  final String idComerciante;

  ProductoModel({
    this.idProducto,
    required this.nombreProducto,
    required this.descripcion,
    required this.precio,
    required this.stock,
    required this.imagen,
    required this.idCategoria,
    required this.idComerciante,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'nombre_producto': nombreProducto,
      'descripcion': descripcion,
      'precio': precio,
      'stock': stock,
      'imagen': imagen,
      'id_categoria': idCategoria,
      'id_comerciante': idComerciante,
    };
  }

  factory ProductoModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ProductoModel(
      idProducto: id,
      nombreProducto: data['nombre_producto'] ?? '',
      descripcion: data['descripcion'] ?? '',
      precio: (data['precio'] ?? 0.0).toDouble(),
      stock: data['stock'] ?? 0,
      imagen: data['imagen'] ?? '',
      idCategoria: data['id_categoria'] ?? '',
      idComerciante: data['id_comerciante'] ?? '',
    );
  }
}