// lib/services/auth_service.dart
import 'dart:convert';
import 'dart:io'; // Necesario para SocketException
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario_autenticado.dart'; // Asegúrate de tener este modelo

class AuthService {
  // Tu URL base de backend
  // NOTA: 'https://neumatik-backend.up.railway.app' ya es una URL pública, no necesita IP.
  final String _baseUrl = 'https://neumatik-backend.up.railway.app';
  final String _loginEndpoint = '/api/auth/login';
  final String _registerEndpoint = '/api/auth/register';

  // Clave de almacenamiento local para el token
  static const String _tokenKey = 'authToken';

  // ====================================================================
  // 1. Lógica de Registro de Usuario (CORREGIDA)
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

      // 1. Manejo de respuesta exitosa (201 Created)
      if (response.statusCode == 201) {
        try {
          // Intentamos decodificar el JSON
          final Map<String, dynamic> responseBody = jsonDecode(response.body);

          final usuarioAutenticado = UsuarioAutenticado.fromJson(responseBody);
          await _saveToken(usuarioAutenticado.token);
          return usuarioAutenticado;
        } on FormatException {
          // Captura el error de sintaxis JSON. Esto es lo que estaba fallando.
          throw Exception(
            'Registro exitoso, pero el servidor devolvió un formato JSON inválido.',
          );
        }
      }
      // 2. Manejo de códigos de error (4xx, 5xx)
      else {
        String errorDetail =
            'Error desconocido (Código HTTP: ${response.statusCode})';

        try {
          // Intentamos decodificar el JSON de error (si existe)
          final Map<String, dynamic> responseBody = jsonDecode(response.body);

          // Buscamos los mensajes de error típicos de un backend (msg, detail, error)
          errorDetail =
              responseBody['msg'] ??
              responseBody['detail'] ??
              responseBody['error'] ??
              errorDetail;
        } on FormatException {
          // El servidor devolvió un error (ej. 500) pero el cuerpo NO era JSON (ej. HTML).
          // Usamos una versión truncada de la respuesta no-JSON.
          final bodySnippet = response.body.length > 100
              ? '${response.body.substring(0, 100)}...'
              : response.body;
          errorDetail =
              'Error del servidor, no es formato JSON. Mensaje: $bodySnippet';
        }

        // Lanzamos la excepción para que la UI la muestre
        throw Exception('Fallo al registrar usuario: $errorDetail');
      }
    } on SocketException {
      // Error de conexión (offline, servidor no responde)
      throw Exception(
        'No se pudo conectar con el servidor. Verifica tu conexión a internet.',
      );
    } catch (e) {
      // Otros errores (ej. TimeoutException, etc.)
      throw Exception(
        'Ocurrió un error inesperado durante el registro: ${e.toString()}',
      );
    }
  }

  // ====================================================================
  // 2. Lógica de Inicio de Sesión (Se mantuvo la lógica anterior, ya es funcional)
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

      final Map<String, dynamic> responseBody = jsonDecode(
        response.body,
      ); // Asume que el backend devuelve JSON para 200 y 401

      if (response.statusCode == 200) {
        final usuarioAutenticado = UsuarioAutenticado.fromJson(responseBody);
        await _saveToken(usuarioAutenticado.token);
        return usuarioAutenticado;
      } else if (response.statusCode == 401) {
        // En este caso, asumimos que responseBody tiene el error, pero el código original ya manejaba el 401
        throw Exception(
          'Credenciales inválidas. Por favor, verifica tu correo y contraseña.',
        );
      } else {
        final errorDetail =
            responseBody['detail'] ??
            responseBody['msg'] ??
            'Error desconocido';
        throw Exception('Fallo al iniciar sesión: $errorDetail');
      }
    } catch (e) {
      // Se agregó manejo de errores de conexión y formato
      if (e is FormatException) {
        throw Exception(
          'Respuesta inválida del servidor. (Error de formato JSON en login)',
        );
      } else if (e is SocketException) {
        throw Exception(
          'No se pudo conectar con el servidor para iniciar sesión.',
        );
      }
      throw Exception('Ocurrió un error de conexión: ${e.toString()}');
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
