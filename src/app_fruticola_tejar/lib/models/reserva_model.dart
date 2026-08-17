import 'package:cloud_firestore/cloud_firestore.dart';

class ReservaModel {
  final String? idReserva;
  final DateTime fechaReserva;
  final int cantidad;
  final String estado;
  final String idUsuario;
  final String idProducto;
  final String idComerciante; // 🔥 AGREGADO

  ReservaModel({
    this.idReserva,
    required this.fechaReserva,
    required this.cantidad,
    required this.estado,
    required this.idUsuario,
    required this.idProducto,
    required this.idComerciante, // 🔥 AGREGADO
  });

  Map<String, dynamic> toFirestore() {
    return {
      'fecha_reserva': Timestamp.fromDate(fechaReserva),
      'cantidad': cantidad,
      'estado': estado,
      'id_usuario': idUsuario,
      'id_producto': idProducto,
      'id_comerciante': idComerciante, // 🔥 AGREGADO
    };
  }

  factory ReservaModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ReservaModel(
      idReserva: id,
      fechaReserva: (data['fecha_reserva'] as Timestamp?)?.toDate() ?? DateTime.now(),
      cantidad: data['cantidad'] ?? 0,
      estado: data['estado'] ?? 'pendiente',
      idUsuario: data['id_usuario'] ?? '',
      idProducto: data['id_producto'] ?? '',
      idComerciante: data['id_comerciante'] ?? '', // 🔥 AGREGADO
    );
  }
}