import 'package:flutter/material.dart';
import 'package:app_fruticola_tejar/services/reserva_service.dart';
import 'package:app_fruticola_tejar/services/auth_service.dart';
import 'package:app_fruticola_tejar/models/reserva_model.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  @override
  void initState() {
    super.initState();
    // Inicializar fechas en español
    initializeDateFormatting('es', null);
  }

  @override
  Widget build(BuildContext context) {
    final ReservaService _reservaService = ReservaService();
    final AuthService _authService = AuthService();

    final user = _authService.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Debes iniciar sesión para ver tus reservas'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('📋 Mis Reservas'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[50],
        child: StreamBuilder(
          stream: _reservaService.getReservasByUsuario(user.uid),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar reservas',
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    ),
                  ],
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF2E7D32),
                ),
              );
            }

            final reservas = snapshot.data!.docs;

            if (reservas.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bookmark_border,
                      size: 80,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tienes reservas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Explora los productos y reserva',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/productos');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('🛒 Ver Productos'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reservas.length,
              itemBuilder: (context, index) {
                final data = reservas[index].data() as Map<String, dynamic>;
                final reserva = ReservaModel.fromFirestore(
                  data,
                  reservas[index].id,
                );
                return _buildReservaCard(context, reserva);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildReservaCard(BuildContext context, ReservaModel reserva) {
    // 🔥 Formato de fecha en español
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'es');
    final Map<String, dynamic> estadoInfo = _getEstadoInfo(reserva.estado);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: estadoInfo['color'].withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        estadoInfo['icon'],
                        color: estadoInfo['color'],
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Reserva #${reserva.idReserva?.substring(0, 6) ?? 'N/A'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: estadoInfo['color'].withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: estadoInfo['color'].withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    estadoInfo['texto'],
                    style: TextStyle(
                      color: estadoInfo['color'],
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.production_quantity_limits,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  'Cantidad: ${reserva.cantidad}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF424242),
                  ),
                ),
                const SizedBox(width: 20),
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  dateFormat.format(reserva.fechaReserva),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF424242),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  'Usuario: ${reserva.idUsuario.substring(0, 8)}...',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getEstadoInfo(String estado) {
    switch (estado) {
      case 'pendiente':
        return {
          'color': Colors.orange,
          'icon': Icons.pending,
          'texto': 'Pendiente',
        };
      case 'confirmada':
        return {
          'color': Colors.green,
          'icon': Icons.check_circle,
          'texto': 'Confirmada',
        };
      case 'cancelada':
        return {
          'color': Colors.red,
          'icon': Icons.cancel,
          'texto': 'Cancelada',
        };
      default:
        return {
          'color': Colors.grey,
          'icon': Icons.help,
          'texto': estado,
        };
    }
  }
}