package com.veterinaria.historiasclinicas.controller;

import com.veterinaria.historiasclinicas.dto.ClienteRegistroRequestDTO;
import com.veterinaria.historiasclinicas.model.Cliente;
import com.veterinaria.historiasclinicas.model.Mascota;
import com.veterinaria.historiasclinicas.service.ClienteService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@CrossOrigin(origins = "*") // <-- ¡AGREGAR ESTA LÍNEA OBLIGATORIA!
@RestController
@RequestMapping("/api/clientes")
public class ClienteController {

    @Autowired
    private ClienteService clienteService;

    // CREATE: POST /api/clientes (Crea cliente + mascota obligatoria)
    @PostMapping
    public ResponseEntity<Cliente> crearCliente(@RequestBody ClienteRegistroRequestDTO request) {
        Cliente nuevoCliente = clienteService.crearClienteConMascota(request);
        return new ResponseEntity<>(nuevoCliente, HttpStatus.CREATED);
    }

    // READ: GET /api/clientes
    @GetMapping
    public ResponseEntity<List<Cliente>> listarClientes() {
        return ResponseEntity.ok(clienteService.listarClientes());
    }

    // UPDATE: PUT /api/clientes/{id}
    @PutMapping("/{id}")
    public ResponseEntity<Cliente> actualizarCliente(@PathVariable Integer id, @RequestBody ClienteRegistroRequestDTO request) {
        return ResponseEntity.ok(clienteService.actualizarCliente(id, request));
    }

    // POST: Añadir más mascotas a un cliente existente -> POST /api/clientes/{id}/mascotas
    @PostMapping("/{id}/mascotas")
    public ResponseEntity<Mascota> agregarMascota(@PathVariable Integer id, @RequestBody ClienteRegistroRequestDTO.MascotaDTO dto) {
        return new ResponseEntity<>(clienteService.agregarMascotaACliente(id, dto), HttpStatus.CREATED);
    }

    // UPDATE: Actualizar mascota -> PUT /api/clientes/mascotas/{idMascota}
    @PutMapping("/mascotas/{idMascota}")
    public ResponseEntity<Mascota> actualizarMascota(@PathVariable Integer idMascota, @RequestBody ClienteRegistroRequestDTO.MascotaDTO dto) {
        return ResponseEntity.ok(clienteService.actualizarMascota(idMascota, dto));
    }
}