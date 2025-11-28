// lib/models/usuario_autenticado.dart

import 'usuario.dart'; // Importa el modelo Usuario

//este es el usuario autenticado
class UsuarioAutenticado {
  final String token;
  final Usuario user; // Contiene la información del usuario

  UsuarioAutenticado({required this.token, required this.user});

  factory UsuarioAutenticado.fromJson(Map<String, dynamic> json) {
<<<<<<< HEAD
    // SOLUCIÓN: Validar que el objeto 'user' exista en la respuesta JSON.
    // Si 'user' es nulo o no es un mapa, se lanza un error controlado.
    if (json['user'] == null || json['user'] is! Map<String, dynamic>) {
      throw const FormatException(
        'La respuesta del servidor no contiene un objeto de usuario válido.',
      );
    }

    return UsuarioAutenticado(
      token: json['token'] as String,
      // Se utiliza Usuario.fromJson() para deserializar el objeto anidado 'user'
      // Ahora es seguro hacer el cast porque ya lo validamos arriba.
      user: Usuario.fromJson(json['user'] as Map<String, dynamic>),
    );
=======
    final dynamic tokenRaw = json['token'] ?? json['access_token'];
    final token = tokenRaw == null ? '' : tokenRaw.toString();

    final dynamic userRaw = json['user'] ?? json['usuario'] ?? json['perfil'];
    if (userRaw == null || userRaw is! Map<String, dynamic>) {
      throw Exception('Respuesta de autenticación inválida: faltan datos del usuario.');
    }

    final user = Usuario.fromJson(userRaw);

    return UsuarioAutenticado(token: token, user: user);
>>>>>>> 3d735dc7b8d8d511cab94dd9fadfd4c5272f633f
  }

  Map<String, dynamic> toJson() => {'token': token, 'user': user.toJson()};
}
