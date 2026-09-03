package com.veterinaria.historiasclinicas.model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import java.time.LocalDate;
import java.util.List;

@Data
@EqualsAndHashCode(callSuper = true)
@NoArgsConstructor
@Entity
@Table(name = "Clientes")
@PrimaryKeyJoinColumn(name = "id_persona")
public class Cliente extends Persona {

    @Column(name = "direccion", nullable = false, length = 100)
    private String direccion;

    @Column(name = "nit", nullable = false, length = 50)
    private String nit;

    @Column(name = "fecha_registro", nullable = false)
    private LocalDate fechaRegistro;

    // Relación de Uno a Muchos con Mascota (CascadeType.ALL para registrar la mascota junto al cliente)
    @OneToMany(mappedBy = "cliente", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Mascota> mascotas;
}
