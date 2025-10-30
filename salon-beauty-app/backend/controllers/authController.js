const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const db = require('../config/db');

// Función principal del login
// Aquí revisamos si el usuario existe, si su contraseña es correcta,
// y si todo está bien le damos un token JWT para que pueda navegar por el sistema
async function login(req, res) {
  const { correo, password } = req.body;

  // Primero verificamos que nos hayan mandado tanto el correo como la contraseña
  if (!correo || !password) {
    return res.status(400).json({
      success: false,
      message: 'Correo y contraseña son requeridos'
    });
  }

  try {
    // Obtenemos el pool de conexiones
    const pool = db.getPool();

    // Buscamos en la base de datos si existe un admin con ese correo
    const userResult = await pool.query(
      `SELECT id_admin, nombre, correo, password_hash, activo, rol, fecha_creacion, ultimo_acceso
       FROM administradores
       WHERE correo = $1`,
      [correo]
    );

    // Si no encontramos a nadie con ese correo, ya sabemos que algo está mal
    if (userResult.rows.length === 0) {
      return res.status(401).json({
        success: false,
        message: 'Correo o contraseña incorrectos'
      });
    }

    // Extraemos los datos que nos devolvió la consulta
    const userData = userResult.rows[0];
    const id_admin = userData.id_admin;
    const nombre = userData.nombre;
    const email = userData.correo;
    const password_hash = userData.password_hash;
    const activo = userData.activo;
    const rol = userData.rol || 'usuario';
    const fecha_creacion = userData.fecha_creacion;
    const ultimo_acceso = userData.ultimo_acceso;

    // Revisamos que el usuario no esté desactivado
    if (activo !== 'S') {
      return res.status(401).json({
        success: false,
        message: 'Usuario inactivo. Contacta al administrador'
      });
    }

    // Ahora viene la parte importante: comparar la contraseña que ingresaron
    // con el hash que tenemos guardado. Bcrypt se encarga de toda la magia aquí
    const passwordMatch = await bcrypt.compare(password, password_hash);

    // Si la contraseña no coincide, rechazamos el login
    if (!passwordMatch) {
      return res.status(401).json({
        success: false,
        message: 'Correo o contraseña incorrectos'
      });
    }

    // Si llegamos hasta aquí es porque todo está bien
    // Armamos un objeto con toda la info del admin
    const admin = {
      id_admin: id_admin,
      nombre: nombre,
      correo: email,
      activo: activo,
      rol: rol,
      fecha_creacion: fecha_creacion,
      ultimo_acceso: ultimo_acceso
    };

    // Creamos el token JWT que el usuario va a usar para las próximas peticiones
    // El token expira en 8 horas, después de eso tendrá que volver a hacer login
    const token = jwt.sign(
      {
        id_admin: admin.id_admin,
        correo: admin.correo,
        nombre: admin.nombre,
        rol: admin.rol
      },
      process.env.JWT_SECRET,
      { expiresIn: '8h' }
    );

    // Actualizamos en la BD la fecha de último acceso
    await pool.query(
      `UPDATE administradores
       SET ultimo_acceso = CURRENT_TIMESTAMP
       WHERE id_admin = $1`,
      [admin.id_admin]
    );

    // Y finalmente mandamos todo de vuelta: los datos del admin y su token
    res.json({
      success: true,
      message: 'Login exitoso',
      admin: admin,
      token: token
    });

  } catch (error) {
    console.error('Error en login:', error);
    res.status(500).json({
      success: false,
      message: 'Error en el servidor',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
}

// Esta función revisa si un token JWT es válido
// La usamos para proteger rutas que solo los usuarios logueados pueden ver
async function verifyToken(req, res) {
  const token = req.headers.authorization?.split(' ')[1];

  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'Token no proporcionado'
    });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    res.json({
      success: true,
      data: decoded
    });
  } catch (error) {
    res.status(401).json({
      success: false,
      message: 'Token inválido o expirado'
    });
  }
}

// Función para actualizar manualmente la fecha de último acceso de un admin
async function updateLastAccess(req, res) {
  const { adminId } = req.body;

  if (!adminId) {
    return res.status(400).json({
      success: false,
      message: 'ID de administrador es requerido'
    });
  }

  try {
    const pool = db.getPool();

    const result = await pool.query(
      `UPDATE administradores
       SET ultimo_acceso = CURRENT_TIMESTAMP
       WHERE id_admin = $1
       RETURNING id_admin`,
      [adminId]
    );

    if (result.rows.length > 0) {
      res.json({
        success: true,
        message: 'Último acceso actualizado'
      });
    } else {
      res.status(400).json({
        success: false,
        message: 'Administrador no encontrado'
      });
    }

  } catch (error) {
    console.error('Error actualizando último acceso:', error);
    res.status(500).json({
      success: false,
      message: 'Error en el servidor'
    });
  }
}

// Función de registro de nuevos administradores
// Valida los datos, encripta la contraseña y crea el usuario en la BD
async function register(req, res) {
  const { nombre, correo, password } = req.body;

  // Validar que todos los campos estén presentes
  if (!nombre || !correo || !password) {
    return res.status(400).json({
      success: false,
      message: 'Nombre, correo y contraseña son requeridos'
    });
  }

  // Validar formato de correo
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(correo)) {
    return res.status(400).json({
      success: false,
      message: 'El formato del correo no es válido'
    });
  }

  // Validar longitud de la contraseña
  if (password.length < 6) {
    return res.status(400).json({
      success: false,
      message: 'La contraseña debe tener al menos 6 caracteres'
    });
  }

  // Validar longitud del nombre
  if (nombre.trim().length < 3) {
    return res.status(400).json({
      success: false,
      message: 'El nombre debe tener al menos 3 caracteres'
    });
  }

  try {
    const pool = db.getPool();

    // Verificar si el correo ya existe
    const existingUser = await pool.query(
      'SELECT id_admin FROM administradores WHERE correo = $1',
      [correo]
    );

    if (existingUser.rows.length > 0) {
      return res.status(409).json({
        success: false,
        message: 'El correo ya está registrado'
      });
    }

    // Encriptar la contraseña usando bcrypt
    const saltRounds = 10;
    const password_hash = await bcrypt.hash(password, saltRounds);

    // Insertar el nuevo administrador en la base de datos con rol 'usuario' por defecto
    const result = await pool.query(
      `INSERT INTO administradores (nombre, correo, password_hash, activo, rol)
       VALUES ($1, $2, $3, 'S', 'usuario')
       RETURNING id_admin, nombre, correo, rol, fecha_creacion, activo`,
      [nombre.trim(), correo.toLowerCase(), password_hash]
    );

    const newAdmin = result.rows[0];

    // Crear token JWT para el nuevo usuario
    const token = jwt.sign(
      {
        id_admin: newAdmin.id_admin,
        correo: newAdmin.correo,
        nombre: newAdmin.nombre,
        rol: newAdmin.rol
      },
      process.env.JWT_SECRET,
      { expiresIn: '8h' }
    );

    // Devolver los datos del nuevo administrador y su token
    res.status(201).json({
      success: true,
      message: 'Registro exitoso',
      admin: {
        id_admin: newAdmin.id_admin,
        nombre: newAdmin.nombre,
        correo: newAdmin.correo,
        activo: newAdmin.activo,
        rol: newAdmin.rol,
        fecha_creacion: newAdmin.fecha_creacion,
        ultimo_acceso: null
      },
      token: token
    });

  } catch (error) {
    console.error('Error en registro:', error);
    res.status(500).json({
      success: false,
      message: 'Error en el servidor',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
}

module.exports = {
  login,
  register,
  verifyToken,
  updateLastAccess
};
