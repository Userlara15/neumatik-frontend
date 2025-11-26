// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario_autenticado.dart'; // Asegúrate de tener este modelo

class AuthService {
  // Tu URL base de backend
  final String _baseUrl = 'https://neumatik-backend.up.railway.app';
  final String _loginEndpoint = '/api/auth/login';
  final String _registerEndpoint = '/api/auth/register';

  // Clave de almacenamiento local para el token
  static const String _tokenKey = 'authToken';

  // ====================================================================
  // 1. Lógica de Registro de Usuario
  // ====================================================================

  Future<UsuarioAutenticado> registerUser({
    required String nombre,
    required String apellido,
    required String correo,
    required String contrasena,
    required String telefono,
    required bool esVendedor,
  }) async {
    final url = Uri.parse('$_baseUrl$_registerEndpoint');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          // Las claves deben coincidir exactamente con lo que espera tu backend
          'nombre': nombre,
          'apellido': apellido,
          'correo': correo,
          'contrasena': contrasena,
          'telefono': telefono,
          'es_vendedor': esVendedor,
        }),
      );

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Código de estado típico para creación exitosa
        final usuarioAutenticado = UsuarioAutenticado.fromJson(responseBody);
        await _saveToken(usuarioAutenticado.token);
        return usuarioAutenticado;
      } else {
        // Manejo de errores (ej. correo ya existe)
        final errorDetail =
            responseBody['msg'] ??
            responseBody['detail'] ??
            'Error desconocido';
        throw Exception('Fallo al registrar usuario: $errorDetail');
      }
    } catch (e) {
      throw Exception('Ocurrió un error de conexión durante el registro: $e');
    }
  }

  // ====================================================================
  // 2. Lógica de Inicio de Sesión
  // ====================================================================

  Future<UsuarioAutenticado> login(String correo, String contrasena) async {
    final url = Uri.parse('$_baseUrl$_loginEndpoint');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          // Ajusta las claves 'email' y 'password' para que coincidan con tu backend
          'email': correo,
          'password': contrasena,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        final usuarioAutenticado = UsuarioAutenticado.fromJson(responseBody);

        await _saveToken(usuarioAutenticado.token);

        return usuarioAutenticado;
      } else if (response.statusCode == 401) {
        throw Exception(
          'Credenciales inválidas. Por favor, verifica tu correo y contraseña.',
        );
      } else {
        final errorDetail =
            jsonDecode(response.body)['detail'] ?? 'Error desconocido';
        throw Exception('Fallo al iniciar sesión: $errorDetail');
      }
    } catch (e) {
      throw Exception('Ocurrió un error de conexión: $e');
    }
  }

  // ====================================================================
  // 3. Gestión del Token (Persistencia)
  // ====================================================================

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // ====================================================================
  // 4. Verificación de Estado de Sesión
  // ====================================================================

  Future<bool> isUserLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
