import 'package:flutter/material.dart';
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

  // Método para refrescar y listar los usuarios desde el backend
  void _cargarUsuarios() {
    setState(() {
      _usuariosFuture = _apiService.listarUsuarios();
    });
  }
  // Importa la pantalla de login en la parte superior de tu archivo si no la tienes
  // import 'login_screen.dart';

  void _cerrarSesion() async {
    // 1. Eliminamos los datos guardados en el almacenamiento local
    await _authStorage.deleteToken(); // Asegúrate de que este método exista en tu AuthStorage

    if (!mounted) return;

    // 2. Navegamos al Login y destruimos el historial de pantallas para que no pueda volver atrás
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false, // Esta condición elimina todas las rutas previas
    );
  }

  // Método para ejecutar la baja lógica (cambiar estado activo/inactivo)
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
    final TextEditingController passController = TextEditingController();
    bool obscurePassword = true; // <--- Variable local para el modal

    showDialog(
      context: context,
      builder: (context) {
        // Envolvemos el AlertDialog en StatefulBuilder para poder cambiar el estado del icono
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF132238),
              title: Text('Nueva Contraseña para: ${usuario.usuario}', style: const TextStyle(color: Colors.white, fontSize: 16)),
              content: TextField(
                controller: passController,
                obscureText: obscurePassword, // <--- Usamos la variable aquí
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Escribe la nueva contraseña',
                  hintStyle: const TextStyle(color: Colors.white30),
                  
                  // --- INICIO DEL ICONO DEL OJO ---
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white38,
                    ),
                    onPressed: () {
                      setStateDialog(() { // Usamos el setStateDialog del modal
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                  // --- FIN DEL ICONO DEL OJO ---
                  
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
                    if (passController.text.isNotEmpty) {
                      try {
                        Map<String, dynamic> datosActualizados = usuario.toJson();
                        datosActualizados['contrasena'] = passController.text.trim();
                        datosActualizados['idRol'] = usuario.rol.idRol;

                        await _apiService.actualizarUsuario(usuario.idPersona, datosActualizados);

                        if (!mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Contraseña actualizada exitosamente'), backgroundColor: Color(0xFF00C896))
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
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
    
    int rolSeleccionado = 2; // 1=Admin, 2=Médico, 3=Pasante. Por defecto Médico.

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
                          Expanded(child: _crearTextField(primerNombreController, 'Primer Nombre *', Icons.person)),
                          const SizedBox(width: 10),
                          Expanded(child: _crearTextField(segundoNombreController, 'Segundo Nombre (Opcional)', Icons.person_outline)),
                        ],
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(child: _crearTextField(primerApellidoController, 'Primer Apellido *', Icons.person)),
                          const SizedBox(width: 10),
                          Expanded(child: _crearTextField(segundoApellidoController, 'Segundo Apellido (Opcional)', Icons.person_outline)),
                        ],
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(flex: 2, child: _crearTextField(ciController, 'C.I. *', Icons.badge)),
                          const SizedBox(width: 10),
                          Expanded(flex: 1, child: _crearTextField(complementoCiController, 'Comp.', Icons.credit_card)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      
                      _crearTextField(celularController, 'Celular *', Icons.phone),
                      
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
                    if (primerNombreController.text.isNotEmpty && 
                        primerApellidoController.text.isNotEmpty && 
                        ciController.text.isNotEmpty && 
                        celularController.text.isNotEmpty && 
                        userController.text.isNotEmpty && 
                        passController.text.isNotEmpty) {
                      
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
                          const SnackBar(content: Text('Usuario registrado exitosamente'), backgroundColor: Color(0xFF00C896))
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent));
                      }
                    } else {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Llena todos los campos con (*)'), backgroundColor: Colors.orange));
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

  // Widget auxiliar para no repetir código en el diseño de los inputs
  Widget _crearTextField(TextEditingController controller, String hint, IconData icon, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
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
          // Barra lateral (Sidebar) basada en tu diseño
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
                            _usuarioLogueado, // <--- Aquí se muestra dinámicamente el usuario logueado
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 12),
                          const CircleAvatar(
                            backgroundColor: Color(0xFF132238),
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          const SizedBox(width: 16), // Espaciador
                          
                          // --- INICIO DEL BOTÓN DE CERRAR SESIÓN ---
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
                                        Navigator.pop(context); // Cierra el modal
                                        _cerrarSesion(); // Llama a tu función
                                      },
                                      child: const Text('Salir', style: TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          // --- FIN DEL BOTÓN ---
                        ],
                      ),
                    ],
                  ),
                ),

                // Contenido de la Tabla de Gestión de Usuarios
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
                          // Título y Botón de Nuevo Usuario
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
                                Expanded( flex: 1, child: Align( alignment: Alignment.centerRight, child: Text( 'ACCIONES', style: TextStyle( color: Colors.white60, fontWeight: FontWeight.bold,fontSize: 12,),), ),),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Listado dinámico consumiendo el ApiService
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