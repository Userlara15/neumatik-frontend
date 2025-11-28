// lib/models/usuario.dart

class Usuario {
  // Se cambia a String, siguiendo el modelo proporcionado, pero
  // se utiliza la lógica robusta para manejar la deserialización.
  final String id;
  final String nombre;
  // CRÍTICO: Se hace REQUIRED aquí para evitar errores 500, ya que PostgreSQL
  // tiene este campo como NOT NULL.
  final String apellido;
  final String correo;
  final String? telefono;
  final bool esVendedor;

//estos son los usuarios normales xddd

  Usuario({
    required this.id,
    required this.nombre,
    required this.apellido, // Vuelve a ser requerido
    required this.correo,
    this.telefono, // Sigue siendo opcional (acepta NULL en DB)
    required this.esVendedor,
  });

  String get nombreCompleto => '$nombre ${apellido ?? ''}'.trim();

  // Factory para crear una instancia de Usuario a partir de un mapa JSON
  factory Usuario.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['user_id'];
    final idString = rawId != null ? rawId.toString() : '';

    final nombre = json['nombre']?.toString() ?? '';
    final apellido = json['apellido']?.toString() ?? '';
    final correo = json['correo']?.toString() ?? '';

    final telefono = json['telefono'] == null ? null : json['telefono'].toString();

    final esVendedorRaw = json['es_vendedor'] ?? json['esVendedor'] ?? json['vendedor'] ?? false;
    final bool isSeller = esVendedorRaw is bool
        ? esVendedorRaw
        : (esVendedorRaw.toString() == '1' || esVendedorRaw.toString().toLowerCase() == 'true');

    return Usuario(
      id: idString,
      nombre: nombre,
      apellido: apellido,
      correo: correo,
      telefono: telefono,
      esVendedor: isSeller,
    );
  }

  // Método para enviar datos al backend (útil en el registro o actualización)
  Map<String, dynamic> toJson() => {
    // 'id' no suele enviarse en el registro
    'nombre': nombre,
    'apellido': apellido, // Aseguramos que el campo se envíe
    'correo': correo,
    'telefono': telefono,
    // El backend de Node.js/Express.js generalmente prefiere booleanos si está configurado
    'es_vendedor': esVendedor,
  };
}
