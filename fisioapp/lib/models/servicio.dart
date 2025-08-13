class Servicio {
  final String id;
  final String empresaId;
  final String nombre;
  final String descripcion;
  final int duracion;
  final double precio;
  final String color;
  final DateTime createdAt;
  final DateTime updatedAt;

  Servicio({
    required this.id,
    required this.empresaId,
    required this.nombre,
    required this.descripcion,
    required this.duracion,
    required this.precio,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Servicio.fromJson(Map<String, dynamic> json) {
    return Servicio(
      id: json['id'],
      empresaId: json['empresa_id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'] ?? '',
      duracion: json['duracion'],
      precio: (json['precio'] as num).toDouble(),
      color: json['color'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'empresa_id': empresaId,
      'nombre': nombre,
      'descripcion': descripcion,
      'duracion': duracion,
      'precio': precio,
      'color': color,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Servicio copyWith({
    String? id,
    String? empresaId,
    String? nombre,
    String? descripcion,
    int? duracion,
    double? precio,
    String? color,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Servicio(
      id: id ?? this.id,
      empresaId: empresaId ?? this.empresaId,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      duracion: duracion ?? this.duracion,
      precio: precio ?? this.precio,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
