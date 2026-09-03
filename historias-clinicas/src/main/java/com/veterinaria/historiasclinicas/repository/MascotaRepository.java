package com.veterinaria.historiasclinicas.repository;

import com.veterinaria.historiasclinicas.model.Mascota;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface MascotaRepository extends JpaRepository<Mascota, Integer> {
}
