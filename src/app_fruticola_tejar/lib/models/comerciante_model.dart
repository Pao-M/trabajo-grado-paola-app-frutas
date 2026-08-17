class ComercianteModel {
  final String? idComerciante;
  final String nombre;
  final String telefono;
  final String correo;
  final String numeroPuesto;

  ComercianteModel({
    this.idComerciante,
    required this.nombre,
    required this.telefono,
    required this.correo,
    required this.numeroPuesto,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'telefono': telefono,
      'correo': correo,
      'numero_puesto': numeroPuesto,
    };
  }

  factory ComercianteModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ComercianteModel(
      idComerciante: id,
      nombre: data['nombre'] ?? '',
      telefono: data['telefono'] ?? '',
      correo: data['correo'] ?? '',
      numeroPuesto: data['numero_puesto'] ?? '',
    );
  }
}