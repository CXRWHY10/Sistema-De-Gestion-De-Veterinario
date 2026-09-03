class LoginRequest {
  final String usuario;
  final String contrasena;

  LoginRequest({
    required this.usuario,
    required this.contrasena,
  });

  Map<String, dynamic> toJson() {
    return {
      'usuario': usuario,
      'contrasena': contrasena,
    };
  }
}