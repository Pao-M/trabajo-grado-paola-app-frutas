import 'package:flutter/material.dart';
import 'package:app_fruticola_tejar/screens/auth/login_screen.dart';
import 'package:app_fruticola_tejar/screens/auth/register_screen.dart';
import 'package:app_fruticola_tejar/screens/consumer/home_screen.dart';
import 'package:app_fruticola_tejar/screens/consumer/product_list_screen.dart';
import 'package:app_fruticola_tejar/screens/consumer/product_detail_screen.dart';
import 'package:app_fruticola_tejar/screens/consumer/my_reservations_screen.dart';
import 'package:app_fruticola_tejar/screens/merchant/add_product_screen.dart';
import 'package:app_fruticola_tejar/screens/merchant/reservations_management_screen.dart';
import 'package:app_fruticola_tejar/screens/admin/admin_dashboard_screen.dart';
import 'package:app_fruticola_tejar/models/producto_model.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '🍎 App Frutícola El Tejar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2E7D32),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          primary: const Color(0xFF2E7D32),
          secondary: const Color(0xFFFF9800),
          surface: const Color(0xFFFFFFFF),
          error: const Color(0xFFE53935),
        ),
        useMaterial3: true,
        
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
          displaySmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
          headlineLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Color(0xFF1A1A1A),
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Color(0xFF424242),
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            color: Color(0xFF757575),
          ),
          labelLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF2E7D32),
            side: const BorderSide(color: Color(0xFF2E7D32), width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          labelStyle: const TextStyle(color: Color(0xFF757575)),
          hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
        ),
        
        chipTheme: const ChipThemeData(
          backgroundColor: Color(0xFFE8F5E9),
          labelStyle: TextStyle(
            fontWeight: FontWeight.w500,
            color: Color(0xFF2E7D32),
          ),
          shape: StadiumBorder(),
          side: BorderSide.none,
        ),
        
        // 🔥 CORREGIDO: CardThemeData en lugar de CardTheme
        cardTheme: const CardThemeData(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          color: Colors.white,
          margin: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        ),
      ),
      
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/productos': (context) => const ProductListScreen(),
        '/mis-reservas': (context) => const MyReservationsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/producto-detalle') {
          final producto = settings.arguments as ProductoModel;
          return MaterialPageRoute(
            builder: (context) => ProductDetailScreen(producto: producto),
          );
        }
        if (settings.name == '/agregar-producto') {
          return MaterialPageRoute(
            builder: (context) => const AddProductScreen(),
          );
        }
        if (settings.name == '/gestionar-reservas') {
          return MaterialPageRoute(
            builder: (context) => const ReservationsManagementScreen(),
          );
        }
        if (settings.name == '/admin-dashboard') {
          return MaterialPageRoute(
            builder: (context) => const AdminDashboardScreen(),
          );
        }
        return null;
      },
    );
  }
}