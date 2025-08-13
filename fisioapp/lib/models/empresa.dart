class Empresa {
  final String id;
  final String nombre;
  final String? direccion;
  final String? telefono;
  final String? email;
  final String? logoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Empresa({
    required this.id,
    required this.nombre,
    this.direccion,
    this.telefono,
    this.email,
    this.logoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Empresa.fromJson(Map<String, dynamic> json) {
    return Empresa(
      id: json['id'],
      nombre: json['nombre'],
      direccion: json['direccion'],
      telefono: json['telefono'],
      email: json['email'],
      logoUrl: json['logo_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'direccion': direccion,
      'telefono': telefono,
      'email': email,
      'logo_url': logoUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
