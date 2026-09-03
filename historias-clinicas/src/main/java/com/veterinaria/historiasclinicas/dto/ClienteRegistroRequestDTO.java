package com.veterinaria.historiasclinicas.dto;

import lombok.Data;
import java.time.LocalDate;
import java.util.List;

@Data
public class ClienteRegistroRequestDTO {
    // Datos de Persona
    private String primerNombre;
    private String segundoNombre;
    private String primerApellido;
    private String segundoApellido;
    private String cedulaIdentidad;
    private String complementoCi;
    private String celular;

    // Datos de Cliente
    private String direccion;
    private String nit;

    // Lista obligatoria de mascotas (al menos 1)
    private List<MascotaDTO> mascotas;

    @Data
    public static class MascotaDTO {
        private String nombreMascota;
        private String especie;
        private String raza;
        private String sexo;
        private LocalDate fechaNacimiento;
    }
}
