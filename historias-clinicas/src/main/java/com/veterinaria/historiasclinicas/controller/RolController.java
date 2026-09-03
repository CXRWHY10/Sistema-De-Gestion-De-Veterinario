package com.veterinaria.historiasclinicas.controller;

import com.veterinaria.historiasclinicas.model.Rol;
import com.veterinaria.historiasclinicas.repository.RolRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/roles")
public class RolController {
    @Autowired
    private RolRepository rolRepository;
    // GET: http://localhost:8080/api/roles (Obtener la lista de roles)
    @GetMapping
    public List<Rol> listarRoles() {
        return rolRepository.findAll();
    }
    // POST: http://localhost:8080/api/roles (Crear un nuevo rol)
    @PostMapping
    public ResponseEntity<Rol> crearRol(@RequestBody Rol rol) {
        Rol nuevoRol = rolRepository.save(rol);
        return new ResponseEntity<>(nuevoRol, HttpStatus.CREATED);
    }
}
