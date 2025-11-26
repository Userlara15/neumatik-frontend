// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registro_screen.dart';
import 'services/auth_service.dart';

void main() {
  // Asegura que los servicios de Flutter estén inicializados antes de usar SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neumatik App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const CheckAuthStateScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistroScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

// Pantalla intermedia para verificar si el usuario ya está logueado al iniciar la app
class CheckAuthStateScreen extends StatelessWidget {
  const CheckAuthStateScreen({super.key});

  Future<String> _getInitialRoute() async {
    final authService = AuthService();
    final isLoggedIn = await authService.isUserLoggedIn();
    return isLoggedIn ? '/home' : '/login';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getInitialRoute(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // Navegar inmediatamente una vez que se sabe el estado
          // Usamos replace para que esta pantalla no quede en el stack de navegación
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed(snapshot.data!);
          });
        }

        // Muestra un indicador de carga mientras se verifica el estado
        return const Scaffold(
          body: Center(child: CircularProgressIndicator(color: Colors.teal)),
        );
      },
    );
  }
}
