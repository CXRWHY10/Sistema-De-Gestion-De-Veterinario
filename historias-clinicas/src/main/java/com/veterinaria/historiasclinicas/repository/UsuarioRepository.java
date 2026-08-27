package com.veterinaria.historiasclinicas.repository;

import com.veterinaria.historiasclinicas.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UsuarioRepository extends JpaRepository<Usuario, Integer> {
// Spring boot hara la consulta
    Optional<Usuario> findByUsuario(String usuario);
}
