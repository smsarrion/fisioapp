class Paciente {
  final String id;
  final String empresaId;
  final String nombre;
  final String apellido;
  final String? email;
  final String? telefono;
  final String? direccion;
  final DateTime? fechaNacimiento;
  final String? dni;
  final String? historialMedico;
  final DateTime createdAt;
  final DateTime updatedAt;

  Paciente({
    required this.id,
    required this.empresaId,
    required this.nombre,
    required this.apellido,
    this.email,
    this.telefono,
    this.direccion,
    this.fechaNacimiento,
    this.dni,
    this.historialMedico,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Paciente.fromJson(Map<String, dynamic> json) {
    return Paciente(
      id: json['id'],
      empresaId: json['empresa_id'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      email: json['email'],
      telefono: json['telefono'],
      direccion: json['direccion'],
      fechaNacimiento: json['fecha_nacimiento'] != null
          ? DateTime.parse(json['fecha_nacimiento'])
          : null,
      dni: json['dni'],
      historialMedico: json['historial_medico'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'empresa_id': empresaId,
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'telefono': telefono,
      'direccion': direccion,
      'fecha_nacimiento': fechaNacimiento?.toIso8601String(),
      'dni': dni,
      'historial_medico': historialMedico,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
