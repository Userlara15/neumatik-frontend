// lib/models/usuario_autenticado.dart

import 'usuario.dart'; // Importa el modelo Usuario

//este es el usuario autenticado
class UsuarioAutenticado {
  final String token;
  final Usuario user; // Contiene la información del usuario

  UsuarioAutenticado({required this.token, required this.user});

  factory UsuarioAutenticado.fromJson(Map<String, dynamic> json) {
    final dynamic tokenRaw = json['token'] ?? json['access_token'];
    final token = tokenRaw == null ? '' : tokenRaw.toString();

    final dynamic userRaw = json['user'] ?? json['usuario'] ?? json['perfil'];
    if (userRaw == null || userRaw is! Map<String, dynamic>) {
      throw Exception('Respuesta de autenticación inválida: faltan datos del usuario.');
    }

    final user = Usuario.fromJson(userRaw);

    return UsuarioAutenticado(token: token, user: user);
  }

  Map<String, dynamic> toJson() => {'token': token, 'user': user.toJson()};
}
