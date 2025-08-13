class Cita {
  final String id;
  final String empresaId;
  final String pacienteId;
  final String profesionalId;
  final String servicioId;
  final DateTime fechaHoraInicio;
  final DateTime fechaHoraFin;
  final String estado;
  final String? notas;
  final DateTime createdAt;
  final DateTime updatedAt;

  Cita({
    required this.id,
    required this.empresaId,
    required this.pacienteId,
    required this.profesionalId,
    required this.servicioId,
    required this.fechaHoraInicio,
    required this.fechaHoraFin,
    required this.estado,
    this.notas,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cita.fromJson(Map<String, dynamic> json) {
    return Cita(
      id: json['id'],
      empresaId: json['empresa_id'],
      pacienteId: json['paciente_id'],
      profesionalId: json['profesional_id'],
      servicioId: json['servicio_id'],
      fechaHoraInicio: DateTime.parse(json['fecha_hora_inicio']),
      fechaHoraFin: DateTime.parse(json['fecha_hora_fin']),
      estado: json['estado'],
      notas: json['notas'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'empresa_id': empresaId,
      'paciente_id': pacienteId,
      'profesional_id': profesionalId,
      'servicio_id': servicioId,
      'fecha_hora_inicio': fechaHoraInicio.toIso8601String(),
      'fecha_hora_fin': fechaHoraFin.toIso8601String(),
      'estado': estado,
      'notas': notas,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
