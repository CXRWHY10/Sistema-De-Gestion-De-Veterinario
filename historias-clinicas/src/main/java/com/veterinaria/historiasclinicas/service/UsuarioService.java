package com.veterinaria.historiasclinicas.service;

import com.veterinaria.historiasclinicas.dto.UsuarioRequestDTO;
import com.veterinaria.historiasclinicas.model.Rol;
import com.veterinaria.historiasclinicas.model.Usuario;
import com.veterinaria.historiasclinicas.repository.RolRepository;
import com.veterinaria.historiasclinicas.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class UsuarioService {

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private RolRepository rolRepository;
    @Autowired
    private PasswordEncoder passwordEncoder;

    // CREATE: Crear un nuevo usuario
    public Usuario crearUsuario(UsuarioRequestDTO request) {
        Rol rol = rolRepository.findById(request.getIdRol())
                .orElseThrow(() -> new RuntimeException("Rol no encontrado"));

        Usuario usuario = new Usuario();
        // Seteamos campos de Persona
        usuario.setPrimerNombre(request.getPrimerNombre());
        usuario.setSegundoNombre(request.getSegundoNombre());
        usuario.setPrimerApellido(request.getPrimerApellido());
        usuario.setSegundoApellido(request.getSegundoApellido());
        usuario.setCedulaIdentidad(request.getCedulaIdentidad());
        usuario.setComplementoCi(request.getComplementoCi());
        usuario.setCelular(request.getCelular());

        // Seteamos campos de Usuario
        usuario.setUsuario(request.getUsuario());
        usuario.setContrasena(passwordEncoder.encode(request.getContrasena()));
        usuario.setActivo(true); // Por defecto nace activo
        usuario.setRol(rol);

        return usuarioRepository.save(usuario);
    }

    // READ: Listar todos los usuarios
    public List<Usuario> listarUsuarios() {
        return usuarioRepository.findAll();
    }

    // UPDATE: Actualizar datos de un usuario existente
    public Usuario actualizarUsuario(Integer id, UsuarioRequestDTO request) {
        Usuario usuario = usuarioRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        Rol rol = rolRepository.findById(request.getIdRol())
                .orElseThrow(() -> new RuntimeException("Rol no encontrado"));

        // Actualizamos campos de Persona
        usuario.setPrimerNombre(request.getPrimerNombre());
        usuario.setSegundoNombre(request.getSegundoNombre());
        usuario.setPrimerApellido(request.getPrimerApellido());
        usuario.setSegundoApellido(request.getSegundoApellido());
        usuario.setCedulaIdentidad(request.getCedulaIdentidad());
        usuario.setComplementoCi(request.getComplementoCi());
        usuario.setCelular(request.getCelular());

        // Actualizamos campos de Usuario
        usuario.setUsuario(request.getUsuario());
        if (request.getContrasena() != null && !request.getContrasena().isEmpty()) {
            usuario.setContrasena(passwordEncoder.encode(request.getContrasena()));
        }
        usuario.setRol(rol);
        return usuarioRepository.save(usuario);
    }

    // SOFT DELETE: Cambiar el estado activo (true/false) en lugar de eliminar
    public Usuario cambiarEstadoActivo(Integer id) {
        Usuario usuario = usuarioRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        // Alternamos el estado booleano actual
        usuario.setActivo(!usuario.getActivo());

        return usuarioRepository.save(usuario);
    }
}