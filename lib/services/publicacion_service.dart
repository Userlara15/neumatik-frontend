import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/publicacion_autoparte.dart';
import '../main.dart'; // Importamos para usar el navigatorKey en caso de sesión expirada

class PublicacionService {
  static const String _baseUrl = 'https://neumatik-backend.up.railway.app';

  // SOLUCIÓN: Renombramos el método para que coincida con el llamado en home_screen.dart
  Future<List<PublicacionAutoparte>> getPublicacionesActivas() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    // Endpoint correcto para obtener las publicaciones.
    final url = Uri.parse('$_baseUrl/api/publicaciones_autopartes');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          // Es buena práctica enviar el token, aunque el endpoint sea público,
          // por si en el futuro se hace privado.
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        // Usamos el modelo correcto: PublicacionAutoparte
        return data.map((json) => PublicacionAutoparte.fromJson(json)).toList();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // Manejo de sesión expirada consistente.
        await prefs.remove('auth_token');
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
        throw Exception('Sesión expirada. Por favor, inicie sesión de nuevo.');
      } else {
        // Manejo de errores del servidor
        throw Exception('Fallo al cargar publicaciones: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }
}
