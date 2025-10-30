const oracledb = require('oracledb');
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

  let connection;

  try {
    // Sacamos una conexión del pool (como pedir prestado un carrito del súper)
    connection = await db.getPool().getConnection();

    // Buscamos en la base de datos si existe un admin con ese correo
    const userResult = await connection.execute(
      `SELECT id_admin, nombre, correo, password_hash, activo
       FROM administradores
       WHERE correo = :correo`,
      { correo: correo }
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
    const id_admin = userData[0];
    const nombre = userData[1];
    const email = userData[2];
    const password_hash = userData[3];
    const activo = userData[4];

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
    // Traemos info adicional del admin (cuándo se registró y cuándo entró por última vez)
    const adminFullData = await connection.execute(
      `SELECT fecha_creacion, ultimo_acceso
       FROM administradores
       WHERE id_admin = :id_admin`,
      { id_admin: id_admin }
    );

    // Armamos un objeto con toda la info del admin
    const admin = {
      id_admin: id_admin,
      nombre: nombre,
      correo: email,
      activo: activo,
      fecha_creacion: adminFullData.rows[0][0],
      ultimo_acceso: adminFullData.rows[0][1]
    };

    // Creamos el token JWT que el usuario va a usar para las próximas peticiones
    // El token expira en 8 horas, después de eso tendrá que volver a hacer login
    const token = jwt.sign(
      {
        id_admin: admin.id_admin,
        correo: admin.correo,
        nombre: admin.nombre
      },
      process.env.JWT_SECRET,
      { expiresIn: '8h' }
    );

    // Actualizamos en la BD la fecha de último acceso
    await connection.execute(
      `UPDATE administradores
       SET ultimo_acceso = SYSDATE
       WHERE id_admin = :id_admin`,
      { id_admin: admin.id_admin },
      { autoCommit: true }
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
  } finally {
    // Siempre devolvemos la conexión al pool, pase lo que pase
    if (connection) {
      try {
        await connection.close();
      } catch (err) {
        console.error('Error cerrando conexión:', err);
      }
    }
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
// Aunque normalmente esto se hace automáticamente en el login
async function updateLastAccess(req, res) {
  const { adminId } = req.body;

  if (!adminId) {
    return res.status(400).json({
      success: false,
      message: 'ID de administrador es requerido'
    });
  }

  let connection;

  try {
    connection = await db.getPool().getConnection();

    const result = await connection.execute(
      `BEGIN
        sp_update_ultimo_acceso(
          p_id_admin => :adminId,
          p_resultado => :resultado
        );
      END;`,
      {
        adminId: adminId,
        resultado: { dir: oracledb.BIND_OUT, type: oracledb.STRING, maxSize: 500 }
      }
    );

    const { resultado } = result.outBinds;

    if (resultado.startsWith('SUCCESS')) {
      res.json({
        success: true,
        message: 'Último acceso actualizado'
      });
    } else {
      res.status(400).json({
        success: false,
        message: resultado
      });
    }

  } catch (error) {
    console.error('Error actualizando último acceso:', error);
    res.status(500).json({
      success: false,
      message: 'Error en el servidor'
    });
  } finally {
    if (connection) {
      try {
        await connection.close();
      } catch (err) {
        console.error('Error cerrando conexión:', err);
      }
    }
  }
}

module.exports = {
  login,
  verifyToken,
  updateLastAccess
};
