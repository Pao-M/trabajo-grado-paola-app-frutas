class CategoriaModel {
  final String? idCategoria;
  final String nombreCategoria;

  CategoriaModel({
    this.idCategoria,
    required this.nombreCategoria,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'nombre_categoria': nombreCategoria,
    };
  }

  factory CategoriaModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CategoriaModel(
      idCategoria: id,
      nombreCategoria: data['nombre_categoria'] ?? '',
    );
  }
}