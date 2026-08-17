import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_fruticola_tejar/models/usuario_model.dart';
import 'package:app_fruticola_tejar/models/comerciante_model.dart';

class UsuarioService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _usuariosCollection = 'usuarios';
  final String _comerciantesCollection = 'comerciantes';

  // ========== USUARIOS (Consumidores) ==========

  Future<String?> createUsuario(UsuarioModel usuario) async {
    try {
      DocumentReference docRef = await _firestore.collection(_usuariosCollection).add(
        usuario.toFirestore(),
      );
      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  Future<UsuarioModel?> getUsuarioById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(_usuariosCollection).doc(id).get();
      if (doc.exists) {
        return UsuarioModel.fromFirestore(doc.data() as Map<String, dynamic>, id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<UsuarioModel?> getUsuarioByEmail(String email) async {
    try {
      QuerySnapshot query = await _firestore
          .collection(_usuariosCollection)
          .where('correo', isEqualTo: email)
          .get();
      if (query.docs.isNotEmpty) {
        return UsuarioModel.fromFirestore(
          query.docs.first.data() as Map<String, dynamic>,
          query.docs.first.id,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateUsuario(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_usuariosCollection).doc(id).update(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ========== COMERCIANTES ==========

  Future<String?> createComerciante(ComercianteModel comerciante) async {
    try {
      DocumentReference docRef = await _firestore.collection(_comerciantesCollection).add(
        comerciante.toFirestore(),
      );
      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  Future<ComercianteModel?> getComercianteById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(_comerciantesCollection).doc(id).get();
      if (doc.exists) {
        return ComercianteModel.fromFirestore(doc.data() as Map<String, dynamic>, id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<ComercianteModel?> getComercianteByEmail(String email) async {
    try {
      QuerySnapshot query = await _firestore
          .collection(_comerciantesCollection)
          .where('correo', isEqualTo: email)
          .get();
      if (query.docs.isNotEmpty) {
        return ComercianteModel.fromFirestore(
          query.docs.first.data() as Map<String, dynamic>,
          query.docs.first.id,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateComerciante(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_comerciantesCollection).doc(id).update(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ========== 🔥 NUEVO: OBTENER ROL DE USUARIO ==========
  Future<String?> getRolUsuario(String email) async {
    try {
      // 1. Buscar en colección de usuarios
      QuerySnapshot query = await _firestore
          .collection(_usuariosCollection)
          .where('correo', isEqualTo: email)
          .get();
      
      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data() as Map<String, dynamic>;
        return data['rol'] ?? 'consumidor';
      }
      
      // 2. Buscar en colección de comerciantes
      QuerySnapshot queryComerciante = await _firestore
          .collection(_comerciantesCollection)
          .where('correo', isEqualTo: email)
          .get();
      
      if (queryComerciante.docs.isNotEmpty) {
        return 'comerciante';
      }
      
      // 3. Si no se encuentra en ninguna, es consumidor
      return 'consumidor';
    } catch (e) {
      print('Error al obtener rol: $e');
      return 'consumidor';
    }
  }
}