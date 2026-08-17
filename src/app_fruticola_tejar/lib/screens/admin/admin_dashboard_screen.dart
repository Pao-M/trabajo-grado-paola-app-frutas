import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_fruticola_tejar/services/auth_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _totalUsuarios = 0;
  int _totalProductos = 0;
  int _totalReservas = 0;
  int _reservasPendientes = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarEstadisticas();
  }

  Future<void> _cargarEstadisticas() async {
    setState(() => _isLoading = true);

    try {
      final usuariosSnapshot = await _firestore.collection('usuarios').get();
      _totalUsuarios = usuariosSnapshot.docs.length;

      final productosSnapshot = await _firestore.collection('productos').get();
      _totalProductos = productosSnapshot.docs.length;

      final reservasSnapshot = await _firestore.collection('reservas').get();
      _totalReservas = reservasSnapshot.docs.length;

      final pendientesSnapshot = await _firestore
          .collection('reservas')
          .where('estado', isEqualTo: 'pendiente')
          .get();
      _reservasPendientes = pendientesSnapshot.docs.length;
    } catch (e) {
      print('Error al cargar estadísticas: $e');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Panel de Administrador'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _cargarEstadisticas,
        color: const Color(0xFF2E7D32),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF2E7D32),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    const Text(
                      '📈 Resumen General',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Estadísticas de la aplicación',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tarjetas de estadísticas
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            '👤 Usuarios',
                            _totalUsuarios.toString(),
                            Icons.person,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            '🍎 Productos',
                            _totalProductos.toString(),
                            Icons.shopping_basket,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            '📋 Reservas',
                            _totalReservas.toString(),
                            Icons.bookmark,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            '⏳ Pendientes',
                            _reservasPendientes.toString(),
                            Icons.pending,
                            Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Acciones Rápidas
                    const Text(
                      '⚡ Acciones Rápidas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildActionButton(
                      context,
                      icon: Icons.people,
                      title: 'Ver Usuarios',
                      color: Colors.blue[100]!,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UsuariosListScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),

                    _buildActionButton(
                      context,
                      icon: Icons.shopping_basket,
                      title: 'Ver Todos los Productos',
                      color: Colors.green[100]!,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TodosProductosScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),

                    _buildActionButton(
                      context,
                      icon: Icons.bookmark,
                      title: 'Ver Todas las Reservas',
                      color: Colors.orange[100]!,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TodasReservasScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 28, color: const Color(0xFF2E7D32)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 🍎 PANTALLA: LISTA DE USUARIOS
// ============================================================
class UsuariosListScreen extends StatelessWidget {
  const UsuariosListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('👤 Usuarios Registrados'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('usuarios').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar usuarios',
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

          final usuarios = snapshot.data!.docs;

          if (usuarios.isEmpty) {
            return const Center(
              child: Text('No hay usuarios registrados'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: usuarios.length,
            itemBuilder: (context, index) {
              final data = usuarios[index].data() as Map<String, dynamic>;
              final rol = data['rol'] ?? 'consumidor';
              Color rolColor = rol == 'comerciante' ? Colors.orange : Colors.blue;

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: rolColor.withOpacity(0.2),
                    child: Icon(
                      rol == 'comerciante' ? Icons.store : Icons.person,
                      color: rolColor,
                    ),
                  ),
                  title: Text(
                    data['nombre'] ?? 'Sin nombre',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(data['correo'] ?? 'Sin correo'),
                  trailing: Chip(
                    label: Text(rol),
                    backgroundColor: rolColor.withOpacity(0.15),
                    labelStyle: TextStyle(color: rolColor),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ============================================================
// 🍎 PANTALLA: TODOS LOS PRODUCTOS
// ============================================================
class TodosProductosScreen extends StatelessWidget {
  const TodosProductosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🍎 Todos los Productos'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('productos').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar productos',
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

          final productos = snapshot.data!.docs;

          if (productos.isEmpty) {
            return const Center(
              child: Text('No hay productos registrados'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: productos.length,
            itemBuilder: (context, index) {
              final data = productos[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
                child: ListTile(
                  leading: data['imagen'] != null && data['imagen'].isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            data['imagen'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.image_not_supported);
                            },
                          ),
                        )
                      : const Icon(Icons.shopping_basket),
                  title: Text(
                    data['nombre_producto'] ?? 'Sin nombre',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('Bs. ${data['precio'] ?? 0}'),
                  trailing: Chip(
                    label: Text('Stock: ${data['stock'] ?? 0}'),
                    backgroundColor: Colors.blue[100],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ============================================================
// 🍎 PANTALLA: TODAS LAS RESERVAS
// ============================================================
class TodasReservasScreen extends StatelessWidget {
  const TodasReservasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📋 Todas las Reservas'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('reservas').snapshots(),
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
            return const Center(
              child: Text('No hay reservas registradas'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reservas.length,
            itemBuilder: (context, index) {
              final data = reservas[index].data() as Map<String, dynamic>;
              final estado = data['estado'] ?? 'pendiente';
              Color estadoColor = estado == 'confirmada'
                  ? Colors.green
                  : estado == 'cancelada'
                      ? Colors.red
                      : Colors.orange;

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: estadoColor.withOpacity(0.2),
                    child: Icon(
                      estado == 'confirmada'
                          ? Icons.check
                          : estado == 'cancelada'
                              ? Icons.close
                              : Icons.pending,
                      color: estadoColor,
                    ),
                  ),
                  title: Text(
                    'Reserva #${reservas[index].id.substring(0, 6)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('Cantidad: ${data['cantidad'] ?? 0}'),
                  trailing: Chip(
                    label: Text(estado),
                    backgroundColor: estadoColor.withOpacity(0.15),
                    labelStyle: TextStyle(color: estadoColor),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}