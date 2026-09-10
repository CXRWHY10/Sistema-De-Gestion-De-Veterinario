import 'package:flutter/material.dart';

class FormValidators {
  // Nombres y Apellidos Obligatorios: Solo letras y espacios (entre 2 y 40 caracteres)
  static String? validarTextoSimple(String? value, String campo) {
    if (value == null || value.trim().isEmpty) {
      return 'El campo $campo es obligatorio';
    }
    final texto = value.trim();
    if (texto.length < 2 || texto.length > 40) {
      return '$campo debe tener entre 2 y 40 caracteres';
    }
    final regex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$');
    if (!regex.hasMatch(texto)) {
      return 'No se permiten números ni caracteres especiales en $campo';
    }
    return null;
  }

  // Nombres y Apellidos Opcionales (Segundo Nombre / Segundo Apellido): Solo letras y espacios
  static String? validarTextoOpcional(String? value, String campo) {
    if (value == null || value.trim().isEmpty) {
      return null; // Si está vacío, es válido por ser opcional
    }
    final texto = value.trim();
    if (texto.length < 2 || texto.length > 40) {
      return '$campo debe tener entre 2 y 40 caracteres';
    }
    final regex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$');
    if (!regex.hasMatch(texto)) {
      return 'No se permiten números ni caracteres especiales en $campo';
    }
    return null;
  }

  // Cédula de Identidad: Solo números (entre 5 y 10 dígitos)
  static String? validarCI(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El número de cédula es obligatorio';
    }
    final ci = value.trim();
    if (!RegExp(r'^[0-9]+$').hasMatch(ci)) {
      return 'La cédula solo debe contener números';
    }
    if (ci.length < 5 || ci.length > 10) {
      return 'La cédula debe tener entre 5 y 10 dígitos';
    }
    return null;
  }

  // Complemento CI: Opcional, alfanumérico (máximo 3 caracteres, ej: 1A, 2B)
  static String? validarComplemento(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Opcional
    final comp = value.trim();
    if (comp.length > 3) {
      return 'El complemento debe tener máximo 3 caracteres';
    }
    final regex = RegExp(r'^[a-zA-Z0-9\-]+$');
    if (!regex.hasMatch(comp)) {
      return 'Formato de complemento inválido';
    }
    return null;
  }

  // Celular: Solo números, de 7 a 8 dígitos
  static String? validarCelular(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El celular es obligatorio';
    }
    final cel = value.trim();
    final regex = RegExp(r'^[0-9]{7,8}$');
    if (!regex.hasMatch(cel)) {
      return 'Debe ser un número válido de 7 a 8 dígitos';
    }
    return null;
  }

  // Dirección: Entre 5 y 100 caracteres
  static String? validarDireccion(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La dirección es obligatoria';
    }
    final dir = value.trim();
    if (dir.length < 5 || dir.length > 100) {
      return 'La dirección debe tener entre 5 y 100 caracteres';
    }
    final regex = RegExp(r'^[a-zA-Z0-9áéíóúÁÉÍÓÚñÑ\s\.\,\#\-]+$');
    if (!regex.hasMatch(dir)) {
      return 'No se permiten caracteres especiales en la dirección';
    }
    return null;
  }

  // NIT: Opcional, entre 5 y 15 números
  static String? validarNIT(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Opcional
    final nit = value.trim();
    if (!RegExp(r'^[0-9]+$').hasMatch(nit)) {
      return 'El NIT solo debe contener números';
    }
    if (nit.length < 5 || nit.length > 15) {
      return 'El NIT debe tener entre 5 y 15 dígitos';
    }
    return null;
  }

  // Nombre de Mascota y Raza: Entre 2 y 30 caracteres
  static String? validarTextoMascota(String? value, String campo, {bool obligatorio = true}) {
    if (value == null || value.trim().isEmpty) {
      return obligatorio ? 'El campo $campo es obligatorio' : null;
    }
    final texto = value.trim();
    if (texto.length < 2 || texto.length > 30) {
      return '$campo debe tener entre 2 y 30 caracteres';
    }
    final regex = RegExp(r'^[a-zA-Z0-9áéíóúÁÉÍÓÚñÑ\s]+$');
    if (!regex.hasMatch(texto)) {
      return 'No se permiten caracteres especiales en $campo';
    }
    return null;
  }

  // Fecha de Nacimiento obligatoria (Formato AAAA-MM-DD y validación de fecha futura)
  static String? validarFechaNacimiento(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La fecha de nacimiento es obligatoria';
    }
    final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!regex.hasMatch(value)) {
      return 'Use el formato obligatorio AAAA-MM-DD';
    }

    try {
      DateTime fechaNac = DateTime.parse(value);
      DateTime hoy = DateTime.now();
      if (fechaNac.isAfter(hoy)) {
        return 'La fecha no puede ser en el futuro';
      }
    } catch (_) {
      return 'Fecha inválida';
    }

    return null;
  }
}