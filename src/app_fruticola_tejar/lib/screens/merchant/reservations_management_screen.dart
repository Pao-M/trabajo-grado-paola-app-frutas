import 'package:flutter/material.dart';
import 'package:app_fruticola_tejar/services/reserva_service.dart';
import 'package:app_fruticola_tejar/services/auth_service.dart';
import 'package:app_fruticola_tejar/models/reserva_model.dart';

class ReservationsManagementScreen extends StatefulWidget {
  const ReservationsManagementScreen({super.key});

  @override
  State<ReservationsManagementScreen> createState() =>
      _ReservationsManagementScreenState();
}

class _ReservationsManagementScreenState
    extends State<ReservationsManagementScreen> {
  final ReservaService _reservaService = ReservaService();
  final AuthService _authService = AuthService();
  String? _comercianteId;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _comercianteId = _authService.currentUser?.uid;
  }

  // 🔥 Formatear fecha manualmente
  String _formatFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final anio = fecha.year;
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');
    return '$dia/$mes/$anio $hora:$minuto';
  }

  void _mostrarMensaje(String mensaje, Color color) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(color == Colors.green ? Icons.check_circle : Icons.error,
                color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(mensaje)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_comercianteId == null) {
      return const Scaffold(
        body: Center(child: Text('Debes iniciar sesión como comerciante')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('📋 Gestión de Reservas'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[50],
        child: StreamBuilder(
          stream: _reservaService.getReservasByComerciante(_comercianteId!),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text('Error al cargar reservas',
                        style: TextStyle(fontSize: 18, color: Colors.grey[700])),
                  ],
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
              );
            }

            final reservasDocs = snapshot.data!.docs;

            if (reservasDocs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 80, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text('No hay reservas',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        )),
                    const SizedBox(height: 8),
                    Text('Cuando los clientes reserven, aparecerán aquí',
                        style: TextStyle(fontSize: 14, color: Colors.grey[400])),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: reservasDocs.length,
              itemBuilder: (context, index) {
                final data = reservasDocs[index].data() as Map<String, dynamic>;
                final reserva = ReservaModel.fromFirestore(data, reservasDocs[index].id);
                return _buildReservaCard(context, reserva);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildReservaCard(BuildContext context, ReservaModel reserva) {
    final Map<String, dynamic> estadoInfo = _getEstadoInfo(reserva.estado);
    final bool isPending = reserva.estado == 'pendiente';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(estadoInfo['icon'], color: estadoInfo['color'], size: 14),
                    const SizedBox(width: 6),
                    Text(
                      '#${reserva.idReserva?.substring(0, 6) ?? 'N/A'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                  decoration: BoxDecoration(
                    color: estadoInfo['color'].withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    estadoInfo['texto'],
                    style: TextStyle(
                      color: estadoInfo['color'],
                      fontWeight: FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Detalles
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                _buildDetailItem(Icons.production_quantity_limits, '${reserva.cantidad}'),
                _buildDetailItem(Icons.calendar_today, _formatFecha(reserva.fechaReserva)),
                _buildDetailItem(Icons.person_outline, '${reserva.idUsuario.substring(0, 6)}...'),
              ],
            ),

            // Botones
            if (isPending) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 32,
                      child: ElevatedButton(
                        onPressed: _isProcessing
                            ? null
                            : () => _updateEstado(context, reserva.idReserva!, 'confirmada'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('✅ Confirmar', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 32,
                      child: ElevatedButton(
                        onPressed: _isProcessing
                            ? null
                            : () => _updateEstado(context, reserva.idReserva!, 'cancelada'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('❌ Cancelar', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.grey),
        const SizedBox(width: 2),
        Text(text, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Map<String, dynamic> _getEstadoInfo(String estado) {
    switch (estado) {
      case 'pendiente':
        return {'color': Colors.orange, 'icon': Icons.pending, 'texto': 'Pendiente'};
      case 'confirmada':
        return {'color': Colors.green, 'icon': Icons.check_circle, 'texto': 'Confirmada'};
      case 'cancelada':
        return {'color': Colors.red, 'icon': Icons.cancel, 'texto': 'Cancelada'};
      default:
        return {'color': Colors.grey, 'icon': Icons.help, 'texto': estado};
    }
  }

  Future<void> _updateEstado(BuildContext context, String reservaId, String nuevoEstado) async {
    setState(() => _isProcessing = true);
    try {
      final success = await _reservaService.updateEstado(reservaId, nuevoEstado);
      if (success) {
        _mostrarMensaje(
          nuevoEstado == 'confirmada' ? '✅ Reserva confirmada' : '❌ Reserva cancelada',
          Colors.green,
        );
      } else {
        _mostrarMensaje('❌ Error al actualizar', Colors.red);
      }
    } catch (e) {
      _mostrarMensaje('❌ Error: $e', Colors.red);
    }
    setState(() => _isProcessing = false);
  }
}