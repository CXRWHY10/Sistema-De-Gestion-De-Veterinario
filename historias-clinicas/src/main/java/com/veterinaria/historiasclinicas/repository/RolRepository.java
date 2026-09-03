package com.veterinaria.historiasclinicas.repository;

import com.veterinaria.historiasclinicas.model.Rol;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

public interface RolRepository extends JpaRepository<Rol, Integer>{
// Al extender de JpaRepository, Spring JPA provee automáticamente todos los métodos CRUD.
}
