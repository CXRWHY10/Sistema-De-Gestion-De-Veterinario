class ClienteRegistroRequestDTO {
  String primerNombre;
  String? segundoNombre;
  String primerApellido;
  String? segundoApellido;
  String cedulaIdentidad;
  String? complementoCi;
  String celular;
  String direccion;
  String? nit;
  List<MascotaDTO> mascotas;

  ClienteRegistroRequestDTO({
    this.primerNombre = '',
    this.segundoNombre,
    this.primerApellido = '',
    this.segundoApellido,
    this.cedulaIdentidad = '',
    this.complementoCi,
    this.celular = '',
    this.direccion = '',
    this.nit,
    List<MascotaDTO>? mascotas,
  }) : mascotas = mascotas ?? [];

  Map<String, dynamic> toJson() {
    return {
      'primerNombre': primerNombre,
      'segundoNombre': _cadenaONull(segundoNombre),
      'primerApellido': primerApellido,
      'segundoApellido': _cadenaONull(segundoApellido),
      'cedulaIdentidad': cedulaIdentidad,
      'complementoCi': _cadenaONull(complementoCi),
      'celular': celular,
      'direccion': direccion,
      'nit': _cadenaONull(nit),
      'mascotas': mascotas.map((m) => m.toJson()).toList(),
    };
  }

  static String? _cadenaONull(String? val) {
    if (val == null || val.trim().isEmpty) return null;
    return val.trim();
  }
}

class MascotaDTO {
  String nombreMascota;
  String especie;
  String? raza;
  String sexo;
  String? fechaNacimiento;

  MascotaDTO({
    this.nombreMascota = '',
    this.especie = '',
    this.raza,
    this.sexo = 'MACHO',
    this.fechaNacimiento,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombreMascota': nombreMascota,
      'especie': especie,
      'raza': _cadenaONull(raza),
      'sexo': sexo,
      'fechaNacimiento': _cadenaONull(fechaNacimiento),
    };
  }

  static String? _cadenaONull(String? val) {
    if (val == null || val.trim().isEmpty) return null;
    return val.trim();
  }
}