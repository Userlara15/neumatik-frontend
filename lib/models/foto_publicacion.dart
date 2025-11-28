// Modelo para una foto asociada a una Publicación
class FotoPublicacion {
  final String fotoId;
  final String publicacionId;
  final String url;
  final bool esPrincipal;

  FotoPublicacion({
    required this.fotoId,
    required this.publicacionId,
    required this.url,
    required this.esPrincipal,
  });

  factory FotoPublicacion.fromJson(Map<String, dynamic> json) {
    final idRaw = json['id'] ?? json['foto_id'];
    final pubIdRaw = json['id_publicacion'] ?? json['publicacion_id'] ?? json['publicacionId'];
    final urlRaw = json['url'] ?? json['ruta'] ?? '';
    final esPrincipalRaw = json['es_principal'] ?? json['esPrincipal'] ?? json['principal'];

    return FotoPublicacion(
      fotoId: idRaw == null ? '' : idRaw.toString(),
      publicacionId: pubIdRaw == null ? '' : pubIdRaw.toString(),
      url: urlRaw == null ? '' : urlRaw.toString(),
      esPrincipal: _parseBool(esPrincipalRaw),
    );
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      final v = value.toLowerCase();
      return v == '1' || v == 'true' || v == 'yes';
    }
    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': fotoId,
      'id_publicacion': publicacionId,
      'url': url,
      'es_principal': esPrincipal,
    };
  }
}
