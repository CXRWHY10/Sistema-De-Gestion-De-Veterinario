import 'rol_model.dart';

class Usuario {
  // Atributos heredados de Persona
  final int idPersona;
  final String primerNombre;
  final String? segundoNombre; // Opcional
  final String primerApellido;
  final String? segundoApellido; // Opcional
  final String cedulaIdentidad;
  final String? complementoCi; // Opcional
  final String celular;

  // Atributos propios de Usuario
  final String usuario;
  final String? contrasena; // Opcional al recibir por seguridad, útil al enviar
  final bool activo;
  final Rol rol;

  Usuario({
    required this.idPersona,
    required this.primerNombre,
    this.segundoNombre,
    required this.primerApellido,
    this.segundoApellido,
    required this.cedulaIdentidad,
    this.complementoCi,
    required this.celular,
    required this.usuario,
    this.contrasena,
    required this.activo,
    required this.rol,
  });

  // Convertir el JSON del backend a un objeto Dart
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      idPersona: json['idPersona'] ?? 0,
      primerNombre: json['primerNombre'] ?? '',
      segundoNombre: json['segundoNombre'],
      primerApellido: json['primerApellido'] ?? '',
      segundoApellido: json['segundoApellido'],
      cedulaIdentidad: json['cedulaIdentidad'] ?? '',
      complementoCi: json['complementoCi'],
      celular: json['celular'] ?? '',
      usuario: json['usuario'] ?? '',
      contrasena: json['contrasena'],
      activo: json['activo'] ?? true,
      rol: json['rol'] != null ? Rol.fromJson(json['rol']) : Rol(idRol: 0, nombreRol: ''),
    );
  }

  // Convertir el objeto Dart a JSON para enviarlo al backend
  Map<String, dynamic> toJson() {
    return {
      'idPersona': idPersona,
      'primerNombre': primerNombre,
      'segundoNombre': segundoNombre,
      'primerApellido': primerApellido,
      'segundoApellido': segundoApellido,
      'cedulaIdentidad': cedulaIdentidad,
      'complementoCi': complementoCi,
      'celular': celular,
      'usuario': usuario,
      'contrasena': contrasena,
      'activo': activo,
      'rol': rol.toJson(),
    };
  }
}