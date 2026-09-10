import 'package:flutter/material.dart';
import '../models/cliente_request_model.dart';
import '../services/api_service.dart';
import '../utils/validators.dart';

class RegistrarClientePage extends StatefulWidget {
  const RegistrarClientePage({Key? key}) : super(key: key);

  @override
  State<RegistrarClientePage> createState() => _RegistrarClientePageState();
}

class _RegistrarClientePageState extends State<RegistrarClientePage> {
  final _formKey = GlobalKey<FormState>();
  final ClienteRegistroRequestDTO _request = ClienteRegistroRequestDTO();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (_request.mascotas.isEmpty) {
      _request.mascotas.add(MascotaDTO());
    }
  }

  void _enviarFormulario() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_request.mascotas.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: El cliente debe tener al menos una mascota.')),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        await _apiService.registrarClienteConMascota(_request);
        setState(() => _isLoading = false);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Cliente y mascota(s) registrados con éxito!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        setState(() => _isLoading = false);
        final String mensajeError = e.toString().replaceAll('Exception: ', '');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensajeError),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, corrige los errores en el formulario.')),
      );
    }
  }

  // Estilo visual limpio con colores forzados para legibilidad total
  InputDecoration _decoracionCampo(String label, IconData icono) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF4A5568), fontSize: 14),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      prefixIcon: Icon(icono, color: const Color(0xFF3182CE), size: 20),
      filled: true,
      fillColor: const Color(0xFFF7FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Color(0xFFCBD5E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Color(0xFF3182CE), width: 1.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light().copyWith(
        scaffoldBackgroundColor: const Color(0xFFEDF2F7),
        primaryColor: const Color(0xFF3182CE),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Registro Digital de Cliente y Mascota', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF2B6CB0),
          elevation: 1,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 850),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                children: [
                  _buildSeccionPropietario(),
                  const SizedBox(height: 24),
                  _buildSeccionMascotas(),
                  const SizedBox(height: 32),
                  _buildBotonGuardar(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- SECCIÓN DATO PROPIETARIO ---
  Widget _buildSeccionPropietario() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.person, color: Color(0xFF3182CE), size: 26),
                SizedBox(width: 10),
                Text(
                  'Información del Propietario',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3748)),
                ),
              ],
            ),
            const Divider(height: 30, color: Color(0xFFE2E8F0)),
            
            LayoutBuilder(
              builder: (context, constraints) {
                bool esAncho = constraints.maxWidth > 500;
                return Flex(
                  direction: esAncho ? Axis.horizontal : Axis.vertical,
                  children: [
                    Expanded(
                      flex: esAncho ? 1 : 0,
                      child: TextFormField(
                        style: const TextStyle(color: Color(0xFF1A202C)),
                        decoration: _decoracionCampo('Primer Nombre *', Icons.badge),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (v) => FormValidators.validarTextoSimple(v, 'Primer Nombre'),
                        onSaved: (v) => _request.primerNombre = v!.trim(),
                      ),
                    ),
                    SizedBox(width: esAncho ? 16 : 0, height: esAncho ? 0 : 16),
                    Expanded(
                      flex: esAncho ? 1 : 0,
                      child: TextFormField(
                        style: const TextStyle(color: Color(0xFF1A202C)),
                        decoration: _decoracionCampo('Segundo Nombre', Icons.badge_outlined),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        // CORREGIDO AQUÍ: Usa validarTextoOpcional en lugar de validarTextoMascota
                        validator: (v) => FormValidators.validarTextoOpcional(v, 'Segundo Nombre'),
                        onSaved: (v) => _request.segundoNombre = v?.trim(),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            LayoutBuilder(
              builder: (context, constraints) {
                bool esAncho = constraints.maxWidth > 500;
                return Flex(
                  direction: esAncho ? Axis.horizontal : Axis.vertical,
                  children: [
                    Expanded(
                      flex: esAncho ? 1 : 0,
                      child: TextFormField(
                        style: const TextStyle(color: Color(0xFF1A202C)),
                        decoration: _decoracionCampo('Primer Apellido *', Icons.badge),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (v) => FormValidators.validarTextoSimple(v, 'Primer Apellido'),
                        onSaved: (v) => _request.primerApellido = v!.trim(),
                      ),
                    ),
                    SizedBox(width: esAncho ? 16 : 0, height: esAncho ? 0 : 16),
                    Expanded(
                      flex: esAncho ? 1 : 0,
                      child: TextFormField(
                        style: const TextStyle(color: Color(0xFF1A202C)),
                        decoration: _decoracionCampo('Segundo Apellido', Icons.badge_outlined),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        // CORREGIDO AQUÍ: Usa validarTextoOpcional en lugar de validarTextoMascota
                        validator: (v) => FormValidators.validarTextoOpcional(v, 'Segundo Apellido'),
                        onSaved: (v) => _request.segundoApellido = v?.trim(),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    style: const TextStyle(color: Color(0xFF1A202C)),
                    decoration: _decoracionCampo('CI *', Icons.credit_card),
                    keyboardType: TextInputType.number,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: FormValidators.validarCI,
                    onSaved: (v) => _request.cedulaIdentidad = v!.trim(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    style: const TextStyle(color: Color(0xFF1A202C)),
                    decoration: _decoracionCampo('Compl.', Icons.extension),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: FormValidators.validarComplemento,
                    onSaved: (v) => _request.complementoCi = v?.trim(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              style: const TextStyle(color: Color(0xFF1A202C)),
              decoration: _decoracionCampo('Celular / WhatsApp *', Icons.phone),
              keyboardType: TextInputType.phone,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: FormValidators.validarCelular,
              onSaved: (v) => _request.celular = v!.trim(),
            ),
            const SizedBox(height: 12),

            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: const Text('Dirección y Facturación (Opcional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4A5568))),
              children: [
                const SizedBox(height: 8),
                TextFormField(
                  style: const TextStyle(color: Color(0xFF1A202C)),
                  decoration: _decoracionCampo('Dirección *', Icons.home),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: FormValidators.validarDireccion,
                  onSaved: (v) => _request.direccion = v!.trim(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  style: const TextStyle(color: Color(0xFF1A202C)),
                  decoration: _decoracionCampo('NIT (Opcional)', Icons.receipt_long),
                  keyboardType: TextInputType.number,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: FormValidators.validarNIT,
                  onSaved: (v) => _request.nit = v?.trim(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- SECCIÓN MASCOTAS DINÁMICAS ---
  Widget _buildSeccionMascotas() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.pets, color: Color(0xFFDD6B20), size: 24),
                SizedBox(width: 8),
                Text('Mascotas Registradas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
              ],
            ),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF3182CE),
                side: const BorderSide(color: Color(0xFF3182CE)),
              ),
              onPressed: () => setState(() => _request.mascotas.add(MascotaDTO())),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Añadir otra'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._request.mascotas.asMap().entries.map((entry) {
          int index = entry.key;
          MascotaDTO mascota = entry.value;

          return Card(
            color: Colors.white,
            elevation: 2,
            shadowColor: Colors.black12,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Mascota #${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2D3748))),
                      if (_request.mascotas.length > 1)
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => setState(() => _request.mascotas.removeAt(index)),
                        ),
                    ],
                  ),
                  const Divider(color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 8),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      bool esAncho = constraints.maxWidth > 500;
                      return Flex(
                        direction: esAncho ? Axis.horizontal : Axis.vertical,
                        children: [
                          Expanded(
                            flex: esAncho ? 1 : 0,
                            child: TextFormField(
                              style: const TextStyle(color: Color(0xFF1A202C)),
                              decoration: _decoracionCampo('Nombre de Mascota *', Icons.label),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (v) => FormValidators.validarTextoMascota(v, 'Nombre', obligatorio: true),
                              onSaved: (v) => mascota.nombreMascota = v!.trim(),
                            ),
                          ),
                          SizedBox(width: esAncho ? 16 : 0, height: esAncho ? 0 : 16),
                          Expanded(
                            flex: esAncho ? 1 : 0,
                            child: TextFormField(
                              style: const TextStyle(color: Color(0xFF1A202C)),
                              decoration: _decoracionCampo('Especie (Ej. Perro) *', Icons.category),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (v) => FormValidators.validarTextoSimple(v, 'Especie'),
                              onSaved: (v) => mascota.especie = v!.trim(),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      bool esAncho = constraints.maxWidth > 500;
                      return Flex(
                        direction: esAncho ? Axis.horizontal : Axis.vertical,
                        children: [
                          Expanded(
                            flex: esAncho ? 1 : 0,
                            child: TextFormField(
                              style: const TextStyle(color: Color(0xFF1A202C)),
                              decoration: _decoracionCampo('Raza (Opcional)', Icons.subtitles),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (v) => FormValidators.validarTextoMascota(v, 'Raza', obligatorio: false),
                              onSaved: (v) => mascota.raza = v?.trim(),
                            ),
                          ),
                          SizedBox(width: esAncho ? 16 : 0, height: esAncho ? 0 : 16),
                          Expanded(
                            flex: esAncho ? 1 : 0,
                            child: DropdownButtonFormField<String>(
                              value: mascota.sexo.isNotEmpty ? mascota.sexo : 'MACHO',
                              style: const TextStyle(color: Color(0xFF1A202C), fontSize: 14),
                              dropdownColor: Colors.white,
                              decoration: _decoracionCampo('Sexo *', Icons.wc),
                              items: const [
                                DropdownMenuItem(value: 'MACHO', child: Text('MACHO', style: TextStyle(color: Color(0xFF1A202C)))),
                                DropdownMenuItem(value: 'HEMBRA', child: Text('HEMBRA', style: TextStyle(color: Color(0xFF1A202C)))),
                              ],
                              onChanged: (v) {
                                if (v != null) setState(() => mascota.sexo = v);
                              },
                              onSaved: (v) => mascota.sexo = v ?? 'MACHO',
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: TextEditingController(text: mascota.fechaNacimiento),
                    readOnly: true,
                    style: const TextStyle(color: Color(0xFF1A202C)),
                    decoration: _decoracionCampo('Fecha de Nacimiento *', Icons.calendar_today),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          mascota.fechaNacimiento = pickedDate.toIso8601String().split('T')[0];
                        });
                      }
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (v) => (v == null || v.isEmpty) ? 'Selecciona una fecha válida' : null,
                    onSaved: (v) => mascota.fechaNacimiento = v?.trim(),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  // --- BOTÓN PRINCIPAL ---
  Widget _buildBotonGuardar() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3182CE),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 2,
        ),
        onPressed: _isLoading ? null : _enviarFormulario,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('GUARDAR Y CONTINUAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}