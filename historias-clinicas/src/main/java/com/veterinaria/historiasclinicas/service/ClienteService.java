package com.veterinaria.historiasclinicas.service;

import com.veterinaria.historiasclinicas.dto.ClienteRegistroRequestDTO;
import com.veterinaria.historiasclinicas.model.Cliente;
import com.veterinaria.historiasclinicas.model.Mascota;
import com.veterinaria.historiasclinicas.repository.ClienteRepository;
import com.veterinaria.historiasclinicas.repository.MascotaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class ClienteService {

    @Autowired
    private ClienteRepository clienteRepository;

    @Autowired
    private MascotaRepository mascotaRepository;

    // CREATE: Crear cliente con al menos una mascota obligatoria
    @Transactional
    public Cliente crearClienteConMascota(ClienteRegistroRequestDTO request) {
        if (request.getMascotas() == null || request.getMascotas().isEmpty()) {
            throw new IllegalArgumentException("El cliente debe tener registrada al menos una mascota obligatoriamente.");
        }

        Cliente cliente = new Cliente();
        cliente.setPrimerNombre(request.getPrimerNombre());
        cliente.setSegundoNombre(request.getSegundoNombre());
        cliente.setPrimerApellido(request.getPrimerApellido());
        cliente.setSegundoApellido(request.getSegundoApellido());
        cliente.setCedulaIdentidad(request.getCedulaIdentidad());
        cliente.setComplementoCi(request.getComplementoCi());
        cliente.setCelular(request.getCelular());
        cliente.setDireccion(request.getDireccion());
        cliente.setNit(request.getNit());
        cliente.setFechaRegistro(LocalDate.now());

        // Mapear y asignar las mascotas
        List<Mascota> mascotas = request.getMascotas().stream().map(dto -> {
            Mascota m = new Mascota();
            m.setNombreMascota(dto.getNombreMascota());
            m.setEspecie(dto.getEspecie());
            m.setRaza(dto.getRaza());
            m.setSexo(dto.getSexo());
            m.setFechaNacimiento(dto.getFechaNacimiento());
            m.setCliente(cliente);
            return m;
        }).collect(Collectors.toList());

        cliente.setMascotas(mascotas);
        return clienteRepository.save(cliente);
    }

    // READ: Listar clientes y sus mascotas
    public List<Cliente> listarClientes() {
        return clienteRepository.findAll();
    }

    // UPDATE: Actualizar datos del cliente
    @Transactional
    public Cliente actualizarCliente(Integer id, ClienteRegistroRequestDTO request) {
        Cliente cliente = clienteRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Cliente no encontrado"));

        cliente.setPrimerNombre(request.getPrimerNombre());
        cliente.setSegundoNombre(request.getSegundoNombre());
        cliente.setPrimerApellido(request.getPrimerApellido());
        cliente.setSegundoApellido(request.getSegundoApellido());
        cliente.setCedulaIdentidad(request.getCedulaIdentidad());
        cliente.setComplementoCi(request.getComplementoCi());
        cliente.setCelular(request.getCelular());
        cliente.setDireccion(request.getDireccion());
        cliente.setNit(request.getNit());

        return clienteRepository.save(cliente);
    }

    // AÑADIR MASCOTA A CLIENTE EXISTENTE
    @Transactional
    public Mascota agregarMascotaACliente(Integer idCliente, ClienteRegistroRequestDTO.MascotaDTO dto) {
        Cliente cliente = clienteRepository.findById(idCliente)
                .orElseThrow(() -> new RuntimeException("Cliente no encontrado"));

        Mascota mascota = new Mascota();
        mascota.setNombreMascota(dto.getNombreMascota());
        mascota.setEspecie(dto.getEspecie());
        mascota.setRaza(dto.getRaza());
        mascota.setSexo(dto.getSexo());
        mascota.setFechaNacimiento(dto.getFechaNacimiento());
        mascota.setCliente(cliente);

        return mascotaRepository.save(mascota);
    }

    // UPDATE MASCOTA: Actualizar datos de una mascota
    @Transactional
    public Mascota actualizarMascota(Integer idMascota, ClienteRegistroRequestDTO.MascotaDTO dto) {
        Mascota mascota = mascotaRepository.findById(idMascota)
                .orElseThrow(() -> new RuntimeException("Mascota no encontrada"));

        mascota.setNombreMascota(dto.getNombreMascota());
        mascota.setEspecie(dto.getEspecie());
        mascota.setRaza(dto.getRaza());
        mascota.setSexo(dto.getSexo());
        mascota.setFechaNacimiento(dto.getFechaNacimiento());

        return mascotaRepository.save(mascota);
    }
}