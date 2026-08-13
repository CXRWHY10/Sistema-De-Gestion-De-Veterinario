package com.veterinaria.historiasclinicas.model;
import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@Entity
@Table(name = "Persona")
@Inheritance(strategy = InheritanceType.JOINED)
public class Persona {
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "persona_seq")
    @SequenceGenerator(name = "persona_seq", sequenceName = "persona_id_persona_seq", allocationSize = 1)
    @Column(name = "id_persona")
    private Integer idPersona;

    @Column(name = "primer_nombre", nullable = false, length = 50)
    private String primerNombre;

    @Column(name = "segundo_nombre", length = 50)
    private String segundoNombre;

    @Column(name = "primer_apellido", nullable = false, length = 50)
    private String primerApellido;

    @Column(name = "segundo_apellido", length = 50)
    private String segundoApellido;

    @Column(name = "cedula_identidad", nullable = false, length = 10)
    private String cedulaIdentidad;

    @Column(name = "complemento_ci", length = 5)
    private String complementoCi;

    @Column(name = "celular", nullable = false, length = 8)
    private String celular;

}
