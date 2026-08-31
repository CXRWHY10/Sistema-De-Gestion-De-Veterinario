
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importación para FilteringTextInputFormatter
import '../models/usuario_model.dart';
import '../services/api_service.dart';
import '../services/auth_storage.dart';
import 'login_screen.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final ApiService _apiService = ApiService();
  final AuthStorage _authStorage = AuthStorage();
  late Future<List<Usuario>> _usuariosFuture;
  String _usuarioLogueado = 'Cargando...';

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
    _cargarUsuarioLogueado();
  }

  void _cargarUsuarioLogueado() async {
    final nombre = await _authStorage.getUsername();
    setState(() {
      _usuarioLogueado = nombre ?? 'Administrador';
    });
  }

  void _cargarUsuarios() {
    setState(() {
      _usuariosFuture = _apiService.listarUsuarios();
    });
  }

  void _cerrarSesion() async {
    await _authStorage.deleteToken();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  void _cambiarEstado(int idPersona) async {
    try {
      await _apiService.cambiarEstadoUsuario(idPersona);
      _cargarUsuarios();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Estado del usuario actualizado correctamente'),
          backgroundColor: Color(0xFF00C896),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // MÉTODOS DE VALIDACIÓN MODULARIZADOS
  bool _esNombreValido(String texto) {
    if (texto.trim().isEmpty) return true;
    final RegExp regex = RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$");
    return regex.hasMatch(texto.trim());
  }

  bool _esContrasenaValida(String password) {
    final RegExp regex = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>_\-]).{8,}$');
    return regex.hasMatch(password);
  }

  // FORMATTERS REUTILIZABLES PARA RESTRICCIÓN DE TECLADO
  List<TextInputFormatter> get _sololetrasFormatter => [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]')),
      ];

  List<TextInputFormatter> get _soloNumerosFormatter => [
        FilteringTextInputFormatter.digitsOnly, // Restringe la entrada a dígitos únicamente
      ];

  void _mostrarDialogoPassword(Usuario usuario) {
    final TextEditingController passController = TextEditingController();
    bool obscurePassword = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF132238),
              title: Text('Nueva Contraseña para: ${usuario.usuario}', style: const TextStyle(color: Colors.white, fontSize: 16)),
              content: TextField(
                controller: passController,
                obscureText: obscurePassword,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Escribe la nueva contraseña',
                  hintStyle: const TextStyle(color: Colors.white30),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white38,
                    ),
                    onPressed: () {
                      setStateDialog(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.white60)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C896)),
                  onPressed: () async {
                    final pass = passController.text.trim();
                    if (!_esContrasenaValida(pass)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('La contraseña debe tener mín. 8 caracteres, 1 mayúscula, 1 número y 1 carácter especial.'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    try {
                      Map<String, dynamic> datosActualizados = usuario.toJson();
                      datosActualizados['contrasena'] = pass;
                      datosActualizados['idRol'] = usuario.rol.idRol;

                      await _apiService.actualizarUsuario(usuario.idPersona, datosActualizados);

                      if (!mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Contraseña actualizada exitosamente'), backgroundColor: Color(0xFF00C896)),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  },
                  child: const Text('Guardar', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarDialogoNuevoUsuario() {
    final TextEditingController primerNombreController = TextEditingController();
    final TextEditingController segundoNombreController = TextEditingController();
    final TextEditingController primerApellidoController = TextEditingController();
    final TextEditingController segundoApellidoController = TextEditingController();
    final TextEditingController ciController = TextEditingController();
    final TextEditingController complementoCiController = TextEditingController();
    final TextEditingController celularController = TextEditingController();
    final TextEditingController userController = TextEditingController();
    final TextEditingController passController = TextEditingController();

    int rolSeleccionado = 2;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF132238),
              title: const Text('Registrar Nuevo Usuario', style: TextStyle(color: Colors.white, fontSize: 18)),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Datos Personales', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _crearTextField(primerNombreController, 'Primer Nombre *', Icons.person, inputFormatters: _sololetrasFormatter)),
                          const SizedBox(width: 10),
                          Expanded(child: _crearTextField(segundoNombreController, 'Segundo Nombre (Opcional)', Icons.person_outline, inputFormatters: _sololetrasFormatter)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _crearTextField(primerApellidoController, 'Primer Apellido *', Icons.person, inputFormatters: _sololetrasFormatter)),
                          const SizedBox(width: 10),
                          Expanded(child: _crearTextField(segundoApellidoController, 'Segundo Apellido (Opcional)', Icons.person_outline, inputFormatters: _sololetrasFormatter)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          // C.I. restrictivo solo a números
                          Expanded(flex: 2, child: _crearTextField(ciController, 'C.I. *', Icons.badge, inputFormatters: _soloNumerosFormatter)),
                          const SizedBox(width: 10),
                          // Complemento se mantiene sin restricción estricta de números (admite ej. 1A)
                          Expanded(flex: 1, child: _crearTextField(complementoCiController, 'Comp.', Icons.credit_card)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Celular restrictivo solo a números
                      _crearTextField(celularController, 'Celular *', Icons.phone, inputFormatters: _soloNumerosFormatter),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Divider(color: Colors.white24),
                      ),
                      const Text('Credenciales de Acceso', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      _crearTextField(userController, 'Nombre de Usuario *', Icons.account_circle),
                      const SizedBox(height: 10),
                      _crearTextField(passController, 'Contraseña *', Icons.lock, obscureText: true),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: rolSeleccionado,
                        dropdownColor: const Color(0xFF0B1626),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Rol del Sistema *',
                          labelStyle: const TextStyle(color: Colors.white60),
                          prefixIcon: const Icon(Icons.security, color: Colors.white38),
                          filled: true,
                          fillColor: const Color(0xFF0B1626),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('Administrador')),
                          DropdownMenuItem(value: 2, child: Text('Médico')),
                          DropdownMenuItem(value: 3, child: Text('Pasante')),
                        ],
                        onChanged: (value) {
                          setStateDialog(() {
                            rolSeleccionado = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.white60)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C896)),
                  onPressed: () async {
                    if (primerNombreController.text.trim().isEmpty ||
                        primerApellidoController.text.trim().isEmpty ||
                        ciController.text.trim().isEmpty ||
                        celularController.text.trim().isEmpty ||
                        userController.text.trim().isEmpty ||
                        passController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Llena todos los campos obligatorios (*)'), backgroundColor: Colors.orange),
                      );
                      return;
                    }

                    if (!_esNombreValido(primerNombreController.text) ||
                        !_esNombreValido(segundoNombreController.text) ||
                        !_esNombreValido(primerApellidoController.text) ||
                        !_esNombreValido(segundoApellidoController.text)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Los nombres y apellidos solo deben contener letras.'), backgroundColor: Colors.orange),
                      );
                      return;
                    }

                    if (!_esContrasenaValida(passController.text)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('La contraseña debe contener mín. 8 caracteres, 1 mayúscula, 1 número y 1 carácter especial.'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    try {
                      final Map<String, dynamic> nuevoUsuarioData = {
                        'primerNombre': primerNombreController.text.trim(),
                        'segundoNombre': segundoNombreController.text.trim().isEmpty ? null : segundoNombreController.text.trim(),
                        'primerApellido': primerApellidoController.text.trim(),
                        'segundoApellido': segundoApellidoController.text.trim().isEmpty ? null : segundoApellidoController.text.trim(),
                        'cedulaIdentidad': ciController.text.trim(),
                        'complementoCi': complementoCiController.text.trim().isEmpty ? null : complementoCiController.text.trim(),
                        'celular': celularController.text.trim(),
                        'usuario': userController.text.trim(),
                        'contrasena': passController.text.trim(),
                        'idRol': rolSeleccionado,
                      };

                      await _apiService.crearUsuario(nuevoUsuarioData);

                      if (!mounted) return;
                      Navigator.pop(context);
                      _cargarUsuarios();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Usuario registrado exitosamente'), backgroundColor: Color(0xFF00C896)),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
                      );
                    }
                  },
                  child: const Text('Registrar', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _crearTextField(
    TextEditingController controller, 
    String hint, 
    IconData icon, 
    {bool obscureText = false, List<TextInputFormatter>? inputFormatters}
  ) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.white38, size: 18),
        filled: true,
        fillColor: const Color(0xFF0B1626),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Color _obtenerColorRol(String nombreRol) {
    switch (nombreRol.toUpperCase()) {
      case 'ADMINISTRADOR':
        return Colors.purpleAccent;
      case 'MEDICO':
        return const Color(0xFF00C896);
      case 'PASANTE':
        return Colors.blueAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: Row(
        children: [
          Container(
            width: 260,
            color: const Color(0xFF132238),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00C896),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.security, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'VetCare Pro',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            'Gestión Integral',
                            style: TextStyle(color: Colors.white60, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white10),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text(
                    'MÓDULOS HABILITADOS',
                    style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.group, color: Color(0xFF00C896)),
                  title: const Text('CRUD de Usuarios', style: TextStyle(color: Colors.white)),
                  tileColor: Colors.white.withOpacity(0.05),
                  onTap: () {},
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  color: Colors.white.withOpacity(0.02),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Panel Principal',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Bienvenido al sistema de administración veterinaria',
                            style: TextStyle(color: Colors.white60, fontSize: 13),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            _usuarioLogueado,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 12),
                          const CircleAvatar(
                            backgroundColor: Color(0xFF132238),
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(Icons.logout, color: Colors.redAccent),
                            tooltip: 'Cerrar Sesión',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: const Color(0xFF132238),
                                  title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
                                  content: const Text('¿Estás seguro de que deseas salir del sistema?', style: TextStyle(color: Colors.white70)),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancelar', style: TextStyle(color: Colors.white60)),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _cerrarSesion();
                                      },
                                      child: const Text('Salir', style: TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF132238),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.group, color: Color(0xFF00C896)),
                                  SizedBox(width: 10),
                                  Text(
                                    'Gestión de Usuarios (CRUD)',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00C896),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.person_add, size: 18),
                                label: const Text('Nuevo Usuario'),
                                onPressed: () {
                                  _mostrarDialogoNuevoUsuario();
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0B1626),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Expanded(flex: 2, child: Text('USUARIO', style: TextStyle(color: Colors.white60, fontWeight: FontWeight.bold, fontSize: 12))),
                                Expanded(flex: 3, child: Text('NOMBRE COMPLETO', style: TextStyle(color: Colors.white60, fontWeight: FontWeight.bold, fontSize: 12))),
                                Expanded(flex: 2, child: Text('ROL ASIGNADO', style: TextStyle(color: Colors.white60, fontWeight: FontWeight.bold, fontSize: 12))),
                                Expanded(flex: 2, child: Text('ESTADO', style: TextStyle(color: Colors.white60, fontWeight: FontWeight.bold, fontSize: 12))),
                                Expanded(
                                  flex: 1,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      'ACCIONES',
                                      style: TextStyle(color: Colors.white60, fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: FutureBuilder<List<Usuario>>(
                              future: _usuariosFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator(color: Color(0xFF00C896)));
                                } else if (snapshot.hasError) {
                                  return Center(
                                    child: Text(
                                      'Error de acceso o conexión:\n${snapshot.error}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.redAccent),
                                    ),
                                  );
                                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                  return const Center(
                                    child: Text('No hay usuarios registrados', style: TextStyle(color: Colors.white60)),
                                  );
                                }

                                final usuarios = snapshot.data!;

                                return ListView.builder(
                                  itemCount: usuarios.length,
                                  itemBuilder: (context, index) {
                                    final usuario = usuarios[index];
                                    return Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                      margin: const EdgeInsets.only(bottom: 8),
                                      decoration: BoxDecoration(
                                        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              usuario.usuario,
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              '${usuario.primerNombre} ${usuario.segundoNombre ?? ''} ${usuario.primerApellido}',
                                              style: const TextStyle(color: Colors.white70),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: _obtenerColorRol(usuario.rol.nombreRol).withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(color: _obtenerColorRol(usuario.rol.nombreRol)),
                                                ),
                                                child: Text(
                                                  usuario.rol.nombreRol,
                                                  style: TextStyle(
                                                    color: _obtenerColorRol(usuario.rol.nombreRol),
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: usuario.activo ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  usuario.activo ? 'Activo' : 'Inactivo',
                                                  style: TextStyle(
                                                    color: usuario.activo ? Colors.greenAccent : Colors.redAccent,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.key, color: Colors.amber, size: 18),
                                                  tooltip: 'Cambiar contraseña / Editar',
                                                  onPressed: () {
                                                    _mostrarDialogoPassword(usuario);
                                                  },
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                    usuario.activo ? Icons.block : Icons.check_circle,
                                                    color: usuario.activo ? Colors.redAccent : Colors.greenAccent,
                                                    size: 18,
                                                  ),
                                                  tooltip: usuario.activo ? 'Realizar baja lógica' : 'Activar usuario',
                                                  onPressed: () => _cambiarEstado(usuario.idPersona),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}