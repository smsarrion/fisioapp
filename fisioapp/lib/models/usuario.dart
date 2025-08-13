class Usuario {
  final String id;
  final String empresaId;
  final String nombre;
  final String apellido;
  final String email;
  final String rol;

  Usuario({
    required this.id,
    required this.empresaId,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.rol,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      empresaId: json['empresa_id'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      email: json['email'],
      rol: json['rol'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'empresa_id': empresaId,
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'rol': rol,
    };
  }
}