package com.veterinaria.historiasclinicas.dto;
import lombok.Data;
@Data
public class AuthRequestDTO {
    // Nombres de las llaves del JSON a enviar
    private String usuario;
    private String contrasena;
}
