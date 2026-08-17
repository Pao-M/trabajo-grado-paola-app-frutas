import 'package:flutter/material.dart';
import 'package:app_fruticola_tejar/services/auth_service.dart';
import 'package:app_fruticola_tejar/services/usuario_service.dart';
import 'package:app_fruticola_tejar/screens/consumer/product_list_screen.dart';
import 'package:app_fruticola_tejar/screens/consumer/my_reservations_screen.dart';
import 'package:app_fruticola_tejar/screens/consumer/comerciantes_screen.dart';
import 'package:app_fruticola_tejar/screens/merchant/add_product_screen.dart';
import 'package:app_fruticola_tejar/screens/merchant/reservations_management_screen.dart';
import 'package:app_fruticola_tejar/screens/admin/admin_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final UsuarioService _usuarioService = UsuarioService();
  String _rol = 'consumidor';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarRol();
  }

  Future<void> _cargarRol() async {
    final user = _authService.currentUser;
    if (user != null) {
      final rol = await _usuarioService.getRolUsuario(user.email!);
      setState(() {
        _rol = rol ?? 'consumidor';
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final String nombreUsuario = user?.email ?? 'Usuario';

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF2E7D32),
          ),
        ),
      );
    }

    final bool esComerciante = _rol == 'comerciante';
    final bool esAdmin = _rol == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('🍎 App Frutícola El Tejar'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🍎 SALUDO
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2E7D32),
                    Color(0xFF4CAF50),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E7D32).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        '🍉 ¡Bienvenido!',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          esComerciante ? '👨‍🌾' : '🛒',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hola $nombreUsuario',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    esComerciante ? '👨‍🌾 Modo Comerciante' : '🛒 Modo Consumidor',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white60,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 📋 TÍTULO
            const Text(
              '📋 Menú Principal',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 16),

            // ========== TARJETA 1: Ver Productos ==========
            _buildMenuCard(
              context,
              icon: Icons.shopping_basket,
              title: 'Ver Productos',
              subtitle: 'Explora las frutas disponibles',
              color: Colors.green[100]!,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProductListScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            // ========== TARJETA 2: Mis Reservas ==========
            _buildMenuCard(
              context,
              icon: Icons.bookmark,
              title: 'Mis Reservas',
              subtitle: 'Consulta tus reservas',
              color: Colors.orange[100]!,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyReservationsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            // ========== TARJETA 3: Agregar Producto (solo comerciante) ==========
            if (esComerciante)
              _buildMenuCard(
                context,
                icon: Icons.add_business,
                title: 'Agregar Producto',
                subtitle: 'Sube un nuevo producto',
                color: Colors.purple[100]!,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddProductScreen(),
                    ),
                  );
                },
              ),
            if (esComerciante) const SizedBox(height: 12),

            // ========== TARJETA 4: Gestionar Reservas (solo comerciante) ==========
            if (esComerciante)
              _buildMenuCard(
                context,
                icon: Icons.list_alt,
                title: 'Gestionar Reservas',
                subtitle: 'Administra las reservas de tus productos',
                color: Colors.blue[100]!,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReservationsManagementScreen(),
                    ),
                  );
                },
              ),
            if (esComerciante) const SizedBox(height: 12),

            // ========== TARJETA 5: Panel de Administrador (solo admin) ==========
            if (esAdmin)
              _buildMenuCard(
                context,
                icon: Icons.admin_panel_settings,
                title: 'Panel de Administrador',
                subtitle: 'Supervisa y controla el sistema',
                color: Colors.red[100]!,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminDashboardScreen(),
                    ),
                  );
                },
              ),
            if (esAdmin) const SizedBox(height: 12),

            // ========== TARJETA 6: Comerciantes (todos) ==========
            _buildMenuCard(
              context,
              icon: Icons.storefront,
              title: 'Comerciantes',
              subtitle: 'Conoce a nuestros vendedores',
              color: Colors.amber[100]!,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ComerciantesScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
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
                child: Icon(
                  icon,
                  size: 32,
                  color: const Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFF2E7D32),
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}