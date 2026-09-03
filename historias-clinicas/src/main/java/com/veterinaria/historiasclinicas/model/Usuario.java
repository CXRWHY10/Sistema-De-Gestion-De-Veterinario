package com.veterinaria.historiasclinicas.model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

@Data
@EqualsAndHashCode(callSuper = true) // Incluye los atributos de Persona en los métodos equals/hashCode
@NoArgsConstructor
@Entity
@Table(name = "Usuarios")
@PrimaryKeyJoinColumn(name = "id_persona")

public class Usuario extends Persona{
    @Column(name = "usuario", nullable = false, length = 50)
    private String usuario;

    @Column(name = "contrasena", nullable = false, length = 100)
    private String contrasena;

    @Column(name = "activo", nullable = false)
    private Boolean activo;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "id_roles", nullable = false)
    private Rol rol;
}
