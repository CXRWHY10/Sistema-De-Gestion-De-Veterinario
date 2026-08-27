const express = require('express');
const path = require('path');
const sqlite3 = require('sqlite3').verbose();
const app = express();

app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// Archivo de base de datos SQLite (se generará automáticamente en la raíz)
const dbPath = path.join(__dirname, 'veterinaria.db');
const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    console.error('Error al conectar con SQLite:', err.message);
  } else {
    console.log('✅ Conectado exitosamente a la base de datos SQLite (veterinaria.db)');
  }
});

db.serialize(() => {
  // Tabla de Usuarios
  db.run(`CREATE TABLE IF NOT EXISTS usuarios (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    usuario TEXT UNIQUE,
    clave TEXT,
    nombre TEXT,
    rol TEXT,
    estado TEXT
  )`);

  // Tabla de Pacientes
  db.run(`CREATE TABLE IF NOT EXISTS pacientes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    propietario TEXT,
    telefono TEXT,
    mascota TEXT,
    especie TEXT,
    raza TEXT,
    edad TEXT,
    peso TEXT,
    estado TEXT,
    medicoAsignado TEXT
  )`);

  // Tabla de Historiales Clínicos
  db.run(`CREATE TABLE IF NOT EXISTS historiales (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    pacienteId INTEGER,
    mascota TEXT,
    fecha TEXT,
    medico TEXT,
    diagnostico TEXT,
    tratamiento TEXT,
    notas TEXT
  )`);

  // Tabla de Citas y Fechas de Control
  db.run(`CREATE TABLE IF NOT EXISTS citas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    paciente TEXT,
    propietario TEXT,
    fecha TEXT,
    hora TEXT,
    motivo TEXT,
    estado TEXT,
    asignadoA TEXT
  )`);

  // Tabla de Logs de Auditoría
  db.run(`CREATE TABLE IF NOT EXISTS auditoria_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    fecha TEXT,
    usuario TEXT,
    rol TEXT,
    accion TEXT,
    detalle TEXT
  )`);

  // Poblar datos iniciales de prueba si la tabla usuarios está vacía
  db.get("SELECT COUNT(*) AS count FROM usuarios", (err, row) => {
    if (!err && row.count === 0) {
      const stmtUser = db.prepare("INSERT INTO usuarios (usuario, clave, nombre, rol, estado) VALUES (?, ?, ?, ?, ?)");
      stmtUser.run('admin', '1234', 'Carlos Ruiz', 'ADMINISTRADOR', 'Activo');
      stmtUser.run('vet1', '1234', 'Dra. María Fernández', 'MEDICO', 'Activo');
      stmtUser.run('pasante1', '1234', 'Lucas Gómez', 'PASANTE', 'Activo');
      stmtUser.finalize();

      const stmtPac = db.prepare("INSERT INTO pacientes (propietario, telefono, mascota, especie, raza, edad, peso, estado, medicoAsignado) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");
      stmtPac.run('Ana Mendoza', '78945612', 'Firulais', 'Perro', 'Golden Retriever', '3 años', '28 kg', 'Saludable', 'Dra. María Fernández');
      stmtPac.run('Roberto Arce', '65498732', 'Michi', 'Gato', 'Siamés', '2 años', '4.5 kg', 'En Tratamiento', 'Dra. María Fernández');
      stmtPac.finalize();

      const stmtHist = db.prepare("INSERT INTO historiales (pacienteId, mascota, fecha, medico, diagnostico, tratamiento, notas) VALUES (?, ?, ?, ?, ?, ?, ?)");
      stmtHist.run(1, 'Firulais', '2026-08-10', 'Dra. María Fernández', 'Chequeo anual y desparasitación', 'Pastilla antiparasitaria administrada', 'Paciente en excelente peso.');
      stmtHist.run(2, 'Michi', '2026-08-18', 'Dra. María Fernández', 'Infección leve en oído derecho', 'Gotas oticas cada 12 horas por 7 días', 'Revisión programada en 1 semana.');
      stmtHist.finalize();

      const stmtCita = db.prepare("INSERT INTO citas (paciente, propietario, fecha, hora, motivo, estado, asignadoA) VALUES (?, ?, ?, ?, ?, ?, ?)");
      stmtCita.run('Michi', 'Roberto Arce', '2026-08-28', '10:30', 'Control de infección otica', 'Programada', 'Dra. María Fernández');
      stmtCita.finalize();

      const stmtAudit = db.prepare("INSERT INTO auditoria_logs (fecha, usuario, rol, accion, detalle) VALUES (?, ?, ?, ?, ?)");
      stmtAudit.run('2026-08-18 11:20', 'Dra. María Fernández', 'MEDICO', 'Creación de Consulta', 'Añadió diagnóstico para paciente Michi');
      stmtAudit.run('2026-08-20 09:15', 'admin', 'ADMINISTRADOR', 'Auditoría Sistema', 'Revisó historiales médicos de Dra. María Fernández');
      stmtAudit.finalize();
      console.log('🌱 Datos iniciales insertados en la base de datos SQLite.');
    }
  });
});

function registrarAuditoria(usuario, rol, accion, detalle) {
  const now = new Date();
  const fechaStr = now.toISOString().replace('T', ' ').substring(0, 16);
  db.run(
    `INSERT INTO auditoria_logs (fecha, usuario, rol, accion, detalle) VALUES (?, ?, ?, ?, ?)`,
    [fechaStr, usuario, rol, accion, detalle]
  );
}

// Ruta de inicio de sesión
app.post('/api/login', (req, res) => {
  const { usuario, clave } = req.body;
  db.get('SELECT * FROM usuarios WHERE usuario = ? AND clave = ?', [usuario, clave], (err, user) => {
    if (err || !user) {
      return res.status(401).json({ mensaje: 'Nombre de usuario o contraseña incorrectos' });
    }
    if (user.estado !== 'Activo') {
      return res.status(403).json({ mensaje: 'Su cuenta se encuentra inactiva. Contacte al administrador.' });
    }
    registrarAuditoria(user.nombre, user.rol, 'Inicio de Sesión', 'El usuario ingresó al sistema');
    res.json({
      mensaje: 'Autenticación exitosa',
      usuario: user.usuario,
      nombre: user.nombre,
      rol: user.rol,
      redirectUrl: '/dashboard.html'
    });
  });
});

// CRUD USUARIOS (ADMINISTRADOR)
app.get('/api/usuarios', (req, res) => {
  db.all('SELECT * FROM usuarios', [], (err, rows) => {
    if (err) return res.status(500).json({ mensaje: err.message });
    res.json(rows);
  });
});

app.post('/api/usuarios', (req, res) => {
  const { usuario, clave, nombre, rol } = req.body;
  if (!usuario || !clave || !nombre || !rol) {
    return res.status(400).json({ mensaje: 'Todos los campos son obligatorios' });
  }

  db.get('SELECT id FROM usuarios WHERE usuario = ?', [usuario], (err, row) => {
    if (row) return res.status(400).json({ mensaje: 'El nombre de usuario ya existe' });

    db.run(
      'INSERT INTO usuarios (usuario, clave, nombre, rol, estado) VALUES (?, ?, ?, ?, ?)',
      [usuario, clave, nombre, rol, 'Activo'],
      function (err2) {
        if (err2) return res.status(500).json({ mensaje: err2.message });
        registrarAuditoria(req.headers['x-user-name'] || 'admin', 'ADMINISTRADOR', 'Crear Usuario', `Creó al usuario ${usuario} (${rol})`);
        res.status(201).json({ id: this.lastID, usuario, clave, nombre, rol, estado: 'Activo' });
      }
    );
  });
});

app.put('/api/usuarios/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const { nombre, rol, estado } = req.body;

  db.run(
    'UPDATE usuarios SET nombre = COALESCE(?, nombre), rol = COALESCE(?, rol), estado = COALESCE(?, estado) WHERE id = ?',
    [nombre, rol, estado, id],
    function (err) {
      if (err) return res.status(500).json({ mensaje: err.message });
      registrarAuditoria(req.headers['x-user-name'] || 'admin', 'ADMINISTRADOR', 'Modificar Usuario', `Actualizó datos de usuario ID ${id}`);
      res.json({ mensaje: 'Usuario actualizado' });
    }
  );
});

app.post('/api/usuarios/:id/reset-password', (req, res) => {
  const id = parseInt(req.params.id);
  const { nuevaClave } = req.body;

  db.run('UPDATE usuarios SET clave = ? WHERE id = ?', [nuevaClave || '1234', id], function (err) {
    if (err) return res.status(500).json({ mensaje: err.message });
    registrarAuditoria(req.headers['x-user-name'] || 'admin', 'ADMINISTRADOR', 'Restablecer Clave', `Restableció la contraseña del usuario ID ${id}`);
    res.json({ mensaje: 'Contraseña restablecida exitosamente' });
  });
});

app.delete('/api/usuarios/:id', (req, res) => {
  const id = parseInt(req.params.id);
  db.run('DELETE FROM usuarios WHERE id = ?', [id], function (err) {
    if (err) return res.status(500).json({ mensaje: err.message });
    registrarAuditoria(req.headers['x-user-name'] || 'admin', 'ADMINISTRADOR', 'Eliminar Usuario', `Eliminó al usuario ID ${id}`);
    res.json({ mensaje: 'Usuario eliminado' });
  });
});

// GESTIÓN DE PACIENTES
app.get('/api/pacientes', (req, res) => {
  db.all('SELECT * FROM pacientes', [], (err, rows) => {
    if (err) return res.status(500).json({ mensaje: err.message });
    res.json(rows);
  });
});

app.post('/api/pacientes', (req, res) => {
  const { propietario, telefono, mascota, especie, raza, edad, peso, medicoAsignado } = req.body;
  db.run(
    `INSERT INTO pacientes (propietario, telefono, mascota, especie, raza, edad, peso, estado, medicoAsignado)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    [propietario, telefono, mascota, especie, raza, edad, peso, 'Registrado', medicoAsignado || 'Sin Asignar'],
    function (err) {
      if (err) return res.status(500).json({ mensaje: err.message });
      registrarAuditoria(req.headers['x-user-name'] || 'Sistema', req.headers['x-user-role'] || 'PASANTE', 'Registro Paciente', `Registró mascota ${mascota} (${propietario})`);
      res.status(201).json({ id: this.lastID, propietario, mascota });
    }
  );
});

app.put('/api/pacientes/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const { peso, edad } = req.body;

  db.run(
    'UPDATE pacientes SET peso = COALESCE(?, peso), edad = COALESCE(?, edad) WHERE id = ?',
    [peso, edad, id],
    function (err) {
      if (err) return res.status(500).json({ mensaje: err.message });
      registrarAuditoria(req.headers['x-user-name'] || 'Veterinario', 'MEDICO', 'Actualizar Paciente', `Actualizó datos del paciente ID ${id}`);
      res.json({ mensaje: 'Paciente actualizado' });
    }
  );
});

// HISTORIALES CLÍNICOS
app.get('/api/historiales', (req, res) => {
  db.all('SELECT * FROM historiales ORDER BY id DESC', [], (err, rows) => {
    if (err) return res.status(500).json({ mensaje: err.message });
    res.json(rows);
  });
});

app.post('/api/historiales', (req, res) => {
  const { pacienteId, mascota, medico, diagnostico, tratamiento, notas } = req.body;
  const fecha = new Date().toISOString().split('T')[0];

  db.run(
    `INSERT INTO historiales (pacienteId, mascota, fecha, medico, diagnostico, tratamiento, notas)
     VALUES (?, ?, ?, ?, ?, ?, ?)`,
    [
      parseInt(pacienteId),
      mascota,
      fecha,
      medico || 'Dra. María Fernández',
      diagnostico || 'Historial clínico inicial en blanco',
      tratamiento || 'Pendiente de evaluación',
      notas || 'Registro inicial creado'
    ],
    function (err) {
      if (err) return res.status(500).json({ mensaje: err.message });
      registrarAuditoria(req.headers['x-user-name'] || 'Usuario', req.headers['x-user-role'] || 'MEDICO', 'Crear Historial', `Guardó consulta para ${mascota}`);
      res.status(201).json({ id: this.lastID, mascota });
    }
  );
});

app.put('/api/historiales/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const { diagnostico, tratamiento, notas } = req.body;

  db.run(
    'UPDATE historiales SET diagnostico = COALESCE(?, diagnostico), tratamiento = COALESCE(?, tratamiento), notas = COALESCE(?, notas) WHERE id = ?',
    [diagnostico, tratamiento, notas, id],
    function (err) {
      if (err) return res.status(500).json({ mensaje: err.message });
      registrarAuditoria(req.headers['x-user-name'] || 'Dra. María Fernández', 'MEDICO', 'Modificación Controlada Historial', `Modificó historial ID ${id}`);
      res.json({ mensaje: 'Historial actualizado' });
    }
  );
});

// CITAS
app.get('/api/citas', (req, res) => {
  db.all('SELECT * FROM citas', [], (err, rows) => {
    if (err) return res.status(500).json({ mensaje: err.message });
    res.json(rows);
  });
});

app.post('/api/citas', (req, res) => {
  const { paciente, propietario, fecha, hora, motivo, asignadoA } = req.body;
  db.run(
    `INSERT INTO citas (paciente, propietario, fecha, hora, motivo, estado, asignadoA)
     VALUES (?, ?, ?, ?, ?, ?, ?)`,
    [paciente, propietario, fecha, hora, motivo, 'Programada', asignadoA || 'Dra. María Fernández'],
    function (err) {
      if (err) return res.status(500).json({ mensaje: err.message });
      registrarAuditoria(req.headers['x-user-name'] || 'Pasante', 'PASANTE', 'Agendar Cita', `Programó revisión para ${paciente} el ${fecha}`);
      res.status(201).json({ id: this.lastID });
    }
  );
});

// AUDITORÍA
app.get('/api/auditoria', (req, res) => {
  db.all('SELECT * FROM auditoria_logs ORDER BY id DESC', [], (err, rows) => {
    if (err) return res.status(500).json({ mensaje: err.message });
    res.json(rows);
  });
});

app.listen(3000, () => {
  console.log('----------------------------------------------------');
  console.log('¡Servidor Veterinario SQLite funcionando con éxito!');
  console.log('Base de datos SQLite generada en: veterinaria.db');
  console.log('Abre en tu navegador: http://localhost:3000');
  console.log('----------------------------------------------------');
});