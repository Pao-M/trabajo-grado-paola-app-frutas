import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_fruticola_tejar/models/producto_model.dart';

class ProductoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'productos';

  Future<String?> createProducto(ProductoModel producto) async {
    try {
      DocumentReference docRef = await _firestore.collection(_collection).add(
        producto.toFirestore(),
      );
      return docRef.id;
    } catch (e) {
      print('Error al crear producto: $e');
      return null;
    }
  }

  Stream<QuerySnapshot> getProductos() {
    return _firestore.collection(_collection).snapshots();
  }

  Stream<QuerySnapshot> getProductosByComerciante(String idComerciante) {
    return _firestore
        .collection(_collection)
        .where('id_comerciante', isEqualTo: idComerciante)
        .snapshots();
  }

  Future<ProductoModel?> getProductoById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return ProductoModel.fromFirestore(doc.data() as Map<String, dynamic>, id);
      }
      return null;
    } catch (e) {
      print('Error al obtener producto: $e');
      return null;
    }
  }

  Future<bool> updateProducto(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_collection).doc(id).update(data);
      return true;
    } catch (e) {
      print('Error al actualizar producto: $e');
      return false;
    }
  }

  Future<bool> deleteProducto(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      return true;
    } catch (e) {
      print('Error al eliminar producto: $e');
      return false;
    }
  }

  Future<bool> updateStock(String id, int newStock) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'stock': newStock,
      });
      return true;
    } catch (e) {
      print('Error al actualizar stock: $e');
      return false;
    }
  }
}