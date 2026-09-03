import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    if (!mounted) return;
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

  void _mostrarDialogoPassword(Usuario usuario) {
    showDialog(
      context: context,
      builder: (context) => _DialogoPassword(
        usuario: usuario,
        apiService: _apiService,
      ),
    );
  }

  void _mostrarDialogoNuevoUsuario() async {
    try {
      final usuariosActuales = await _usuariosFuture;
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => _DialogoNuevoUsuario(
          apiService: _apiService,
          usuariosExistentes: usuariosActuales,
          onUsuarioCreado: _cargarUsuarios,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos previos: $e'), backgroundColor: Colors.redAccent),
      );
    }
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
          // Sidebar
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

          // Panel Principal
          Expanded(
            child: Column(
              children: [
                // Header Superior
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

                // Tabla de Gestión
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
                                onPressed: _mostrarDialogoNuevoUsuario,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Cabecera de la Tabla
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
                                Expanded(flex: 1, child: Align(alignment: Alignment.centerRight, child: Text('ACCIONES', style: TextStyle(color: Colors.white60, fontWeight: FontWeight.bold, fontSize: 12)))),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Listado dinámico
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
                                    
                                    final nombreCompleto = [
                                      usuario.primerNombre,
                                      usuario.segundoNombre,
                                      usuario.primerApellido,
                                      usuario.segundoApellido
                                    ].where((element) => element != null && element.trim().isNotEmpty).join(' ');

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
                                              nombreCompleto,
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
                                                  onPressed: () => _mostrarDialogoPassword(usuario),
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

// Modal para cambiar contraseña
class _DialogoPassword extends StatefulWidget {
  final Usuario usuario;
  final ApiService apiService;

  const _DialogoPassword({required this.usuario, required this.apiService});

  @override
  State<_DialogoPassword> createState() => _DialogoPasswordState();
}

class _DialogoPasswordState extends State<_DialogoPassword> {
  late final TextEditingController _passController;
  late final TextEditingController _confirmPassController;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _passController = TextEditingController();
    _confirmPassController = TextEditingController();
  }

  @override
  void dispose() {
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF132238),
      title: Text('Nueva Contraseña para: ${widget.usuario.usuario}', style: const TextStyle(color: Colors.white, fontSize: 16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _passController,
            obscureText: _obscurePass,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Escribe la nueva contraseña',
              hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
              suffixIcon: IconButton(
                icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility, color: Colors.white38),
                onPressed: () => setState(() => _obscurePass = !_obscurePass),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _confirmPassController,
            obscureText: _obscureConfirm,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Confirma la nueva contraseña',
              hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, color: Colors.white38),
                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: Colors.white60)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C896)),
          onPressed: () async {
            final pass = _passController.text.trim();
            final confirm = _confirmPassController.text.trim();

            if (pass.isEmpty || confirm.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No se puede dejar la contraseña vacía'), backgroundColor: Colors.orange),
              );
              return;
            }

            if (pass != confirm) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Las contraseñas no coinciden'), backgroundColor: Colors.redAccent),
              );
              return;
            }

            try {
              Map<String, dynamic> datosActualizados = widget.usuario.toJson();
              datosActualizados['contrasena'] = pass;
              datosActualizados['idRol'] = widget.usuario.rol.idRol;

              await widget.apiService.actualizarUsuario(widget.usuario.idPersona, datosActualizados);

              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Contraseña actualizada exitosamente'), backgroundColor: Color(0xFF00C896)),
              );
            } catch (e) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
            }
          },
          child: const Text('Guardar', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

// Modal de Creación Compacto con Validaciones Blindadas
class _DialogoNuevoUsuario extends StatefulWidget {
  final ApiService apiService;
  final List<Usuario> usuariosExistentes;
  final VoidCallback onUsuarioCreado;

  const _DialogoNuevoUsuario({
    required this.apiService,
    required this.usuariosExistentes,
    required this.onUsuarioCreado,
  });

  @override
  State<_DialogoNuevoUsuario> createState() => _DialogoNuevoUsuarioState();
}

class _DialogoNuevoUsuarioState extends State<_DialogoNuevoUsuario> {
  final _primerNombreController = TextEditingController();
  final _segundoNombreController = TextEditingController();
  final _primerApellidoController = TextEditingController();
  final _segundoApellidoController = TextEditingController();
  final _ciController = TextEditingController();
  final _complementoCiController = TextEditingController();
  final _celularController = TextEditingController();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();

  int _rolSeleccionado = 3; // ID 3 = Médico por defecto
  bool _obscurePass = true;
  bool _obscureConfirmPass = true;

  @override
  void dispose() {
    _primerNombreController.dispose();
    _segundoNombreController.dispose();
    _primerApellidoController.dispose();
    _segundoApellidoController.dispose();
    _ciController.dispose();
    _complementoCiController.dispose();
    _celularController.dispose();
    _userController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Widget _crearTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isOnlyText = false,         // Bloquea números/símbolos
    bool isNumericOnly = false,       // Bloquea letras
    bool isAlphanumericUpper = false,   // Para complemento
    bool isPassword = false,
    bool isConfirmPassword = false,
    int? maxLength,
  }) {
    bool obscureCurrent = isPassword ? _obscurePass : _obscureConfirmPass;

    List<TextInputFormatter>? formatters;
    if (isOnlyText) {
      formatters = [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]')),
      ];
    } else if (isNumericOnly) {
      formatters = [
        FilteringTextInputFormatter.digitsOnly,
        if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
      ];
    } else if (isAlphanumericUpper) {
      formatters = [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
        UpperCaseTextFormatter(),
        if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
      ];
    }

    return TextField(
      controller: controller,
      obscureText: (isPassword || isConfirmPassword) ? obscureCurrent : false,
      keyboardType: isNumericOnly ? TextInputType.number : TextInputType.text,
      inputFormatters: formatters,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.white38, size: 18),
        suffixIcon: (isPassword || isConfirmPassword)
            ? IconButton(
                icon: Icon(
                  obscureCurrent ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white38,
                  size: 18,
                ),
                onPressed: () {
                  setState(() {
                    if (isPassword) {
                      _obscurePass = !_obscurePass;
                    } else {
                      _obscureConfirmPass = !_obscureConfirmPass;
                    }
                  });
                },
              )
            : null,
        filled: true,
        fillColor: const Color(0xFF0B1626),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF132238),
      title: const Text('Registrar Nuevo Usuario', style: TextStyle(color: Colors.white, fontSize: 18)),
      content: SizedBox(
        width: 650,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Datos Personales', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              
              // FILA 1: Nombres (Solo Texto)
              Row(
                children: [
                  Expanded(child: _crearTextField(_primerNombreController, 'Primer Nombre *', Icons.person, isOnlyText: true)),
                  const SizedBox(width: 10),
                  Expanded(child: _crearTextField(_segundoNombreController, 'Segundo Nombre (Opcional)', Icons.person_outline, isOnlyText: true)),
                ],
              ),
              const SizedBox(height: 10),

              // FILA 2: Apellidos (Solo Texto)
              Row(
                children: [
                  Expanded(child: _crearTextField(_primerApellidoController, 'Primer Apellido *', Icons.person, isOnlyText: true)),
                  const SizedBox(width: 10),
                  Expanded(child: _crearTextField(_segundoApellidoController, 'Segundo Apellido (Opcional)', Icons.person_outline, isOnlyText: true)),
                ],
              ),
              const SizedBox(height: 10),

              // FILA 3: C.I., Comp. y Celular
              Row(
                children: [
                  Expanded(flex: 3, child: _crearTextField(_ciController, 'C.I. *', Icons.badge, isNumericOnly: true, maxLength: 9)),
                  const SizedBox(width: 8),
                  Expanded(flex: 2, child: _crearTextField(_complementoCiController, 'Comp.', Icons.credit_card, isAlphanumericUpper: true, maxLength: 2)),
                  const SizedBox(width: 8),
                  Expanded(flex: 4, child: _crearTextField(_celularController, 'Celular * (7-8 dígitos)', Icons.phone, isNumericOnly: true, maxLength: 8)),
                ],
              ),
              
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(color: Colors.white24),
              ),

              const Text('Credenciales de Acceso', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              // FILA 4: Usuario y Rol
              Row(
                children: [
                  Expanded(
                    child: _crearTextField(_userController, 'Nombre de Usuario *', Icons.account_circle),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _rolSeleccionado,
                      dropdownColor: const Color(0xFF0B1626),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Rol del Sistema *',
                        labelStyle: const TextStyle(color: Colors.white60),
                        prefixIcon: const Icon(Icons.security, color: Colors.white38, size: 18),
                        filled: true,
                        fillColor: const Color(0xFF0B1626),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                      ),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('Administrador')),
                        DropdownMenuItem(value: 2, child: Text('Pasante')),
                        DropdownMenuItem(value: 3, child: Text('Médico')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _rolSeleccionado = value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // FILA 5: Contraseñas
              Row(
                children: [
                  Expanded(child: _crearTextField(_passController, 'Contraseña *', Icons.lock, isPassword: true)),
                  const SizedBox(width: 10),
                  Expanded(child: _crearTextField(_confirmPassController, 'Confirmar Contraseña *', Icons.lock_outline, isConfirmPassword: true)),
                ],
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
            final pNombre = _primerNombreController.text.trim();
            final pApellido = _primerApellidoController.text.trim();
            final ciTexto = _ciController.text.trim();
            final celularTexto = _celularController.text.trim();
            final usuarioTexto = _userController.text.trim();
            final passTexto = _passController.text.trim();
            final confirmPassTexto = _confirmPassController.text.trim();

            if (pNombre.isEmpty || pApellido.isEmpty || ciTexto.isEmpty || celularTexto.isEmpty || usuarioTexto.isEmpty || passTexto.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No se puede dejar campos vacíos (* Obligatorios)'),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }

            if (ciTexto.length < 7) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('El C.I. debe tener al menos 7 dígitos válidos'),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }

            if (celularTexto.length < 7 || celularTexto.length > 8) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('El celular debe tener entre 7 y 8 dígitos válidos'),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }

            if (passTexto != confirmPassTexto) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Las contraseñas no coinciden. Por favor verifica.'),
                  backgroundColor: Colors.redAccent,
                ),
              );
              return;
            }

            // Validaciones de Unicidad
            final ciExistente = widget.usuariosExistentes.any(
              (u) => u.cedulaIdentidad.trim() == ciTexto,
            );
            if (ciExistente) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ya existe un usuario registrado con este C.I.'), backgroundColor: Colors.orange),
              );
              return;
            }

            final celularExistente = widget.usuariosExistentes.any(
              (u) => u.celular.trim() == celularTexto,
            );
            if (celularExistente) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ya existe un usuario registrado con este número de celular'), backgroundColor: Colors.orange),
              );
              return;
            }

            final userExistente = widget.usuariosExistentes.any(
              (u) => u.usuario.trim().toLowerCase() == usuarioTexto.toLowerCase(),
            );
            if (userExistente) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('El nombre de usuario ya no está disponible'), backgroundColor: Colors.orange),
              );
              return;
            }

            try {
              final Map<String, dynamic> nuevoUsuarioData = {
                'primerNombre': pNombre,
                'segundoNombre': _segundoNombreController.text.trim().isEmpty ? null : _segundoNombreController.text.trim(),
                'primerApellido': pApellido,
                'segundoApellido': _segundoApellidoController.text.trim().isEmpty ? null : _segundoApellidoController.text.trim(),
                'cedulaIdentidad': ciTexto,
                'complementoCi': _complementoCiController.text.trim().isEmpty ? null : _complementoCiController.text.trim(),
                'celular': celularTexto,
                'usuario': usuarioTexto,
                'contrasena': passTexto,
                'idRol': _rolSeleccionado,
              };

              await widget.apiService.crearUsuario(nuevoUsuarioData);

              if (!mounted) return;
              Navigator.of(context).pop();
              widget.onUsuarioCreado();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Usuario registrado exitosamente'), backgroundColor: Color(0xFF00C896)),
              );
            } catch (e) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al registrar usuario: $e'), backgroundColor: Colors.redAccent),
              );
            }
          },
          child: const Text('Registrar', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

// Formateador auxiliar para convertir el complemento del CI a mayúsculas
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}