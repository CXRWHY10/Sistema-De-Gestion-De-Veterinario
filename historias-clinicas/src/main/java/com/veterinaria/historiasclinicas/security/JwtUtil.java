package com.veterinaria.historiasclinicas.security;

import com.veterinaria.historiasclinicas.model.Usuario;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.stereotype.Component;

import java.security.Key;
import java.util.Date;

@Component // Anotación que le dice a Spring que puede inyectar esta clase donde la necesitemos
public class JwtUtil {

    // Clave secreta para firmar el token (Debe tener al menos 32 caracteres / 256 bits)
    private static final String SECRET_KEY_STRING = "VeterinariaSecreta2026HistoriaClinicaToken++";
    private final Key key = Keys.hmacShaKeyFor(SECRET_KEY_STRING.getBytes());
    // Tiempo de expiración del token 10 horas en milisegundos
    private static final long EXPIRATION_TIME = 1000 * 60 * 60 * 10;
     // Inyectamos el Rol
    public String generateToken(Usuario usuario) {
        return Jwts.builder()
                .setSubject(usuario.getUsuario()) // Identificador principal
                .claim("rol", usuario.getRol().getNombreRol())
                // Guarda el ID para no consultarlo a la BD después
                .claim("id_persona", usuario.getIdPersona())
                .setIssuedAt(new Date(System.currentTimeMillis())) // Fecha de creación
                .setExpiration(new Date(System.currentTimeMillis() + EXPIRATION_TIME)) // Fecha de caducidad
                .signWith(key, SignatureAlgorithm.HS256) // Se firma criptográficamente
                .compact();
    }
     //Extrae el nombre de usuario (subject)
    public String extractUsername(String token) {
        return getClaims(token).getSubject();
    }
     // Extrae el Rol para que Spring Security sepa si bloquear o dejar pasar
    public String extractRole(String token) {
        return getClaims(token).get("rol", String.class);
    }
     // Revisa si le pertenece al usuario y si no ha expirado
    public boolean isTokenValid(String token, String username) {
        final String tokenUsername = extractUsername(token);
        return (tokenUsername.equals(username) && !isTokenExpired(token));
    }

    // Métodos Privados de Soporte

    private boolean isTokenExpired(String token) {
        return getClaims(token).getExpiration().before(new Date());
    }

    private Claims getClaims(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(key) // Usa la misma clave para desencriptar
                .build()
                .parseClaimsJws(token)
                .getBody();
    }
}