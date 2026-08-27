package com.veterinaria.historiasclinicas.controller;

import com.veterinaria.historiasclinicas.dto.UsuarioRequestDTO;
import com.veterinaria.historiasclinicas.model.Usuario;
import com.veterinaria.historiasclinicas.service.UsuarioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/usuarios")
public class UsuarioController {

    @Autowired
    private UsuarioService usuarioService;

    // 1. CREATE: POST /api/usuarios
    @PostMapping
    public ResponseEntity<Usuario> crearUsuario(@RequestBody UsuarioRequestDTO request) {
        Usuario nuevoUsuario = usuarioService.crearUsuario(request);
        return new ResponseEntity<>(nuevoUsuario, HttpStatus.CREATED);
    }

    // 2. READ: GET /api/usuarios
    @GetMapping
    public ResponseEntity<List<Usuario>> listarUsuarios() {
        List<Usuario> usuarios = usuarioService.listarUsuarios();
        return ResponseEntity.ok(usuarios);
    }

    // 3. UPDATE: PUT /api/usuarios/{id}
    @PutMapping("/{id}")
    public ResponseEntity<Usuario> actualizarUsuario(@PathVariable Integer id, @RequestBody UsuarioRequestDTO request) {
        Usuario usuarioActualizado = usuarioService.actualizarUsuario(id, request);
        return ResponseEntity.ok(usuarioActualizado);
    }

    // 4. SOFT DELETE (Cambiar estado activo/inactivo): PATCH /api/usuarios/{id}/estado
    @PatchMapping("/{id}/estado")
    public ResponseEntity<Usuario> cambiarEstado(@PathVariable Integer id) {
        Usuario usuarioModificado = usuarioService.cambiarEstadoActivo(id);
        return ResponseEntity.ok(usuarioModificado);
    }
}