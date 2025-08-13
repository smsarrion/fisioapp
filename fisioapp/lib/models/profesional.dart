class Profesional {
  final String id;
  final String empresaId;
  final String nombre;
  final String apellido;
  final String? email;
  final String? telefono;
  final String? especialidad;
  final DateTime createdAt;
  final DateTime updatedAt;

  Profesional({
    required this.id,
    required this.empresaId,
    required this.nombre,
    required this.apellido,
    this.email,
    this.telefono,
    this.especialidad,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Profesional.fromJson(Map<String, dynamic> json) {
    return Profesional(
      id: json['id'],
      empresaId: json['empresa_id'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      email: json['email'],
      telefono: json['telefono'],
      especialidad: json['especialidad'],
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
      'especialidad': especialidad,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Método para obtener el nombre completo
  String get nombreCompleto => '$nombre $apellido';

  // Copia del profesional con algunos campos modificados
  Profesional copyWith({
    String? id,
    String? empresaId,
    String? nombre,
    String? apellido,
    String? email,
    String? telefono,
    String? especialidad,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Profesional(
      id: id ?? this.id,
      empresaId: empresaId ?? this.empresaId,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      especialidad: especialidad ?? this.especialidad,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Método para crear un profesional con datos iniciales
  factory Profesional.initial({
    required String empresaId,
    required String nombre,
    required String apellido,
    String? email,
    String? telefono,
    String? especialidad,
  }) {
    return Profesional(
      id: '', // Se asignará en la base de datos
      empresaId: empresaId,
      nombre: nombre,
      apellido: apellido,
      email: email,
      telefono: telefono,
      especialidad: especialidad,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Método para verificar si el profesional tiene información de contacto
  bool tieneInformacionContacto() {
    return email != null && email!.isNotEmpty ||
        telefono != null && telefono!.isNotEmpty;
  }

  // Método para obtener la información de contacto como una cadena
  String get informacionContacto {
    if (email != null &&
        email!.isNotEmpty &&
        telefono != null &&
        telefono!.isNotEmpty) {
      return '$email - $telefono';
    } else if (email != null && email!.isNotEmpty) {
      return email!;
    } else if (telefono != null && telefono!.isNotEmpty) {
      return telefono!;
    } else {
      return 'Sin información de contacto';
    }
  }

  // Método para obtener la especialidad o un valor por defecto
  String get especialidadFormateada {
    return especialidad?.isNotEmpty == true ? especialidad! : 'General';
  }

  @override
  String toString() {
    return 'Profesional{id: $id, nombre: $nombre, apellido: $apellido, especialidad: $especialidad}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Profesional &&
        other.id == id &&
        other.empresaId == empresaId &&
        other.nombre == nombre &&
        other.apellido == apellido &&
        other.email == email &&
        other.telefono == telefono &&
        other.especialidad == especialidad &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        empresaId.hashCode ^
        nombre.hashCode ^
        apellido.hashCode ^
        email.hashCode ^
        telefono.hashCode ^
        especialidad.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
