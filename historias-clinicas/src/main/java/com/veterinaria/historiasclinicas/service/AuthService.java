package com.veterinaria.historiasclinicas.service;

import com.veterinaria.historiasclinicas.dto.AuthRequestDTO;
import com.veterinaria.historiasclinicas.dto.AuthResponseDTO;
import com.veterinaria.historiasclinicas.model.Usuario;
import com.veterinaria.historiasclinicas.repository.UsuarioRepository;
import com.veterinaria.historiasclinicas.security.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;


@Service
public class AuthService {

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private PasswordEncoder passwordEncoder;

     //Valida las credenciales del usuario y retorna el Token JWT si son correctas.
    public AuthResponseDTO login(AuthRequestDTO request) {
        // Busca al usuario en la base de datos usando el repositorio
        Usuario usuario = usuarioRepository.findByUsuario(request.getUsuario())
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        // Verificamos si el usuario está activo
        if (!usuario.getActivo()) {
            throw new RuntimeException("El usuario se encuentra inactivo");
        }

        // Verificamos la contraseña
        // (Nota: Por ahora comparamos texto plano; más adelante podemos integrar BCrypt
        if (!passwordEncoder.matches(request.getContrasena(), usuario.getContrasena())) {
            throw new RuntimeException("Contraseña incorrecta");
        }

        // Genera el Token JWT inyectando su rol
        String token = jwtUtil.generateToken(usuario);

        // Retorna el token envuelto en el DTO de respuesta
        return new AuthResponseDTO(token);
    }
}