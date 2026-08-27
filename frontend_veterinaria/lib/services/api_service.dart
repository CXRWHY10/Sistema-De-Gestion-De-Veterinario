import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_storage.dart'; // Asegúrate de importar tu gestor de almacenamiento local
import '../models/usuario_model.dart';

class ApiService {
  // URL base para pruebas web en localhost
  static const String baseUrl = 'http://localhost:8080/api';
  final AuthStorage _authStorage = AuthStorage();

  /// Método auxiliar privado para inyectar automáticamente el Token JWT en las cabeceras
  Future<Map<String, String>> _getHeaders() async {
    final String? token = await _authStorage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// 1. LOGIN: Método para iniciar sesión y retornar el token JWT
  Future<String?> login(String usuario, String contrasena) async {
    final Uri url = Uri.parse('$baseUrl/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'usuario': usuario,
          'contrasena': contrasena,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['token']; // Retorna el token JWT generado por Spring Boot[cite: 3]
      } else {
        throw Exception('Error de autenticación. Código: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }

  /// 2. READ: Listar todos los usuarios (Requiere rol Administrador)
  Future<List<Usuario>> listarUsuarios() async {
    final Uri url = Uri.parse('$baseUrl/usuarios');
    final headers = await _getHeaders();

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      Iterable jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Usuario.fromJson(json)).toList();
    } else if (response.statusCode == 403) {
      throw Exception('Acceso denegado: Se requiere rol de Administrador');
    } else {
      throw Exception('Error al cargar los usuarios. Código: ${response.statusCode}');
    }
  }

  /// 3. CREATE: Registrar un nuevo usuario (Requiere rol Administrador)[cite: 3, 5]
  Future<Usuario> crearUsuario(Map<String, dynamic> usuarioData) async {
    final Uri url = Uri.parse('$baseUrl/usuarios');
    final headers = await _getHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(usuarioData),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Usuario.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear usuario. Código: ${response.statusCode}');
    }
  }

  /// 4. UPDATE: Actualizar un usuario existente (Requiere rol Administrador)[cite: 3, 5]
  Future<Usuario> actualizarUsuario(int idPersona, Map<String, dynamic> usuarioData) async {
    final Uri url = Uri.parse('$baseUrl/usuarios/$idPersona');
    final headers = await _getHeaders();

    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(usuarioData),
    );

    if (response.statusCode == 200) {
      return Usuario.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al actualizar usuario. Código: ${response.statusCode}');
    }
  }

  /// 5. PATCH: Cambiar estado activo/inactivo - Baja lógica (Requiere rol Administrador)[cite: 3, 5]
  Future<void> cambiarEstadoUsuario(int idPersona) async {
    final Uri url = Uri.parse('$baseUrl/usuarios/$idPersona/estado');
    final headers = await _getHeaders();

    final response = await http.patch(url, headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Error al cambiar el estado del usuario. Código: ${response.statusCode}');
    }
  }
}