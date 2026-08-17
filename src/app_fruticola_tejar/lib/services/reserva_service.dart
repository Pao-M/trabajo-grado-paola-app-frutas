import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_fruticola_tejar/models/reserva_model.dart';

class ReservaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'reservas';

  // ========== CREAR RESERVA ==========
  Future<String?> createReserva(ReservaModel reserva) async {
    try {
      print('📝 Creando reserva en Firestore...');
      DocumentReference docRef = await _firestore.collection(_collection).add(
        reserva.toFirestore(),
      );
      print('✅ Reserva creada con ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error al crear reserva: $e');
      return null;
    }
  }

  // ========== ACTUALIZAR STOCK DEL PRODUCTO ==========
  Future<bool> actualizarStockProducto(String productoId, int nuevoStock) async {
    try {
      await _firestore.collection('productos').doc(productoId).update({
        'stock': nuevoStock,
      });
      print('✅ Stock actualizado a: $nuevoStock');
      return true;
    } catch (e) {
      print('❌ Error al actualizar stock: $e');
      return false;
    }
  }

  // ========== OBTENER TODAS LAS RESERVAS ==========
  Stream<QuerySnapshot> getReservas() {
    return _firestore.collection(_collection).snapshots();
  }

  // ========== OBTENER RESERVAS POR USUARIO ==========
  Stream<QuerySnapshot> getReservasByUsuario(String idUsuario) {
    return _firestore
        .collection(_collection)
        .where('id_usuario', isEqualTo: idUsuario)
        .snapshots();
  }

  // ========== OBTENER RESERVAS POR COMERCIANTE ==========
  Stream<QuerySnapshot> getReservasByComerciante(String idComerciante) {
    return _firestore
        .collection(_collection)
        .where('id_comerciante', isEqualTo: idComerciante)
        .snapshots();
  }

  // ========== OBTENER RESERVAS POR PRODUCTO ==========
  Stream<QuerySnapshot> getReservasByProducto(String idProducto) {
    return _firestore
        .collection(_collection)
        .where('id_producto', isEqualTo: idProducto)
        .snapshots();
  }

  // ========== OBTENER RESERVA POR ID ==========
  Future<ReservaModel?> getReservaById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return ReservaModel.fromFirestore(doc.data() as Map<String, dynamic>, id);
      }
      return null;
    } catch (e) {
      print('❌ Error al obtener reserva: $e');
      return null;
    }
  }

  // ========== ACTUALIZAR ESTADO DE RESERVA ==========
  Future<bool> updateEstado(String id, String nuevoEstado) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'estado': nuevoEstado,
      });
      print('✅ Estado actualizado a: $nuevoEstado');
      return true;
    } catch (e) {
      print('❌ Error al actualizar estado: $e');
      return false;
    }
  }

  // ========== CANCELAR RESERVA ==========
  Future<bool> cancelarReserva(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'estado': 'cancelada',
      });
      print('✅ Reserva cancelada');
      return true;
    } catch (e) {
      print('❌ Error al cancelar reserva: $e');
      return false;
    }
  }

  // ========== ELIMINAR RESERVA ==========
  Future<bool> deleteReserva(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      print('✅ Reserva eliminada');
      return true;
    } catch (e) {
      print('❌ Error al eliminar reserva: $e');
      return false;
    }
  }
}