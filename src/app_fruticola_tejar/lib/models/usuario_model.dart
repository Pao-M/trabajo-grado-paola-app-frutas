class UsuarioModel {
  final String? idUsuario;
  final String nombre;
  final String telefono;
  final String correo;
  final String rol;

  UsuarioModel({
    this.idUsuario,
    required this.nombre,
    required this.telefono,
    required this.correo,
    required this.rol,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'telefono': telefono,
      'correo': correo,
      'rol': rol,
    };
  }

  factory UsuarioModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UsuarioModel(
      idUsuario: id,
      nombre: data['nombre'] ?? '',
      telefono: data['telefono'] ?? '',
      correo: data['correo'] ?? '',
      rol: data['rol'] ?? 'consumidor',
    );
  }
}