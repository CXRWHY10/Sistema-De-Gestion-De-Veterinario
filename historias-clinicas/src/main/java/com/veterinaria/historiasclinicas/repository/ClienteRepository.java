package com.veterinaria.historiasclinicas.repository;

import com.veterinaria.historiasclinicas.model.Cliente;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ClienteRepository extends JpaRepository<Cliente, Integer> {

    // Método para verificar si ya existe una persona registrada con el mismo número de carnet
    boolean existsByCedulaIdentidad(String cedulaIdentidad);

}