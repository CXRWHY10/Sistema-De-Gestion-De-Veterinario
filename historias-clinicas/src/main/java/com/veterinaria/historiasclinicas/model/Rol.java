package com.veterinaria.historiasclinicas.model;
import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@Entity
@Table(name = "Roles")
public class Rol {
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "roles_seq")
    @SequenceGenerator(name = "roles_seq", sequenceName = "roles_id_roles_seq_1", allocationSize = 1)
    @Column(name = "id_roles")
    private Integer idRol;
    @Column(name = "nombre_rol", nullable = false, length = 50)
    private String nombreRol;
}
