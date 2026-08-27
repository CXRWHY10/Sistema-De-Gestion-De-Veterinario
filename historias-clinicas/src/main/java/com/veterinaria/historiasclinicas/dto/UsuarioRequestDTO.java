package com.veterinaria.historiasclinicas.dto;

import lombok.Data;

@Data
public class UsuarioRequestDTO {
    // Datos de Persona
    private String primerNombre;
    private String segundoNombre;
    private String primerApellido;
    private String segundoApellido;
    private String cedulaIdentidad;
    private String complementoCi;
    private String celular;

    // Datos de Usuario
    private String usuario;
    private String contrasena;
    private Integer idRol; // ID del rol al que pertenecerá (Ej: 1 para Admin)
}