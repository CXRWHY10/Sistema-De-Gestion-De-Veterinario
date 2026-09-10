import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_storage.dart';
import '../models/usuario_model.dart';
import '../models/cliente_request_model.dart'; 

class ApiService {
  // URL base para pruebas en Chrome Web
  static const String baseUrl = 'http://localhost:8080/api';
  final AuthStorage _authStorage = AuthStorage();

  /// Método privado para inyectar automáticamente el Token JWT y cabeceras obligatorias
  Future<Map<String, String>> _getHeaders() async {
    final String? token = await _authStorage.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Helper privado para extraer el mensaje de error personalizado enviado por Spring Boot
  String _extraerMensajeError(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map) {
        return body['mensaje'] ?? body['message'] ?? 'Error no especificado (${response.statusCode})';
      }
    } catch (_) {}
    return 'Error en la petición: Código ${response.statusCode}';
  }

  // ==========================================
  // MÓDULO DE AUTENTICACIÓN Y USUARIOS
  // ==========================================

  /// 1. LOGIN: Iniciar sesión y retornar el token JWT
  Future<String?> login(String usuario, String contrasena) async {
    final Uri url = Uri.parse('$baseUrl/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'usuario': usuario,
          'contrasena': contrasena,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['token'];
      } else {
        throw Exception(_extraerMensajeError(response));
      }
    } catch (e) {
      if (e is Exception && !e.toString().contains('FormatException')) rethrow;
      throw Exception('Error al conectar con el servidor backend.');
    }
  }

  /// 2. READ: Listar todos los usuarios (Requiere Administrador)
  Future<List<Usuario>> listarUsuarios() async {
    final Uri url = Uri.parse('$baseUrl/usuarios');
    final headers = await _getHeaders();

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      Iterable jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Usuario.fromJson(json)).toList();
    } else if (response.statusCode == 403) {
      throw Exception('Acceso denegado: Se requiere rol de Administrador.');
    } else {
      throw Exception(_extraerMensajeError(response));
    }
  }

  /// 3. CREATE: Registrar un nuevo usuario (Requiere Administrador)
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
      throw Exception(_extraerMensajeError(response));
    }
  }

  /// 4. UPDATE: Actualizar un usuario existente (Requiere Administrador)
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
      throw Exception(_extraerMensajeError(response));
    }
  }

  /// 5. PATCH: Cambiar estado activo/inactivo - Baja lógica (Requiere Administrador)
  Future<void> cambiarEstadoUsuario(int idPersona) async {
    final Uri url = Uri.parse('$baseUrl/usuarios/$idPersona/estado');
    final headers = await _getHeaders();

    final response = await http.patch(url, headers: headers);

    if (response.statusCode != 200) {
      throw Exception(_extraerMensajeError(response));
    }
  }

  // ==========================================
  // MÓDULO DE CLIENTES Y MASCOTAS
  // ==========================================

  /// 6. CREATE: Registrar un nuevo cliente con sus mascota(s)
  Future<void> registrarClienteConMascota(ClienteRegistroRequestDTO request) async {
    final Uri url = Uri.parse('$baseUrl/clientes');
    final headers = await _getHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_extraerMensajeError(response));
    }
  }

  /// 7. POST: Añadir una mascota adicional a un cliente existente
  Future<void> agregarMascotaACliente(int idCliente, MascotaDTO mascotaDto) async {
    final Uri url = Uri.parse('$baseUrl/clientes/$idCliente/mascotas');
    final headers = await _getHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(mascotaDto.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_extraerMensajeError(response));
    }
  }

  /// 8. READ: Listar todos los clientes registrados
  Future<List<dynamic>> listarClientes() async {
    final Uri url = Uri.parse('$baseUrl/clientes');
    final headers = await _getHeaders();

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(_extraerMensajeError(response));
    }
  }
}