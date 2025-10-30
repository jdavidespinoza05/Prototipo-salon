const jwt = require('jsonwebtoken');

/**
 * Middleware para verificar el token JWT
 * Protege las rutas que requieren autenticación
 */
function verifyJWT(req, res, next) {
  // Obtener el token del header Authorization
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    return res.status(401).json({
      success: false,
      message: 'Token no proporcionado'
    });
  }

  // El formato esperado es: "Bearer <token>"
  const token = authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'Formato de token inválido'
    });
  }

  try {
    // Verificar y decodificar el token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // Agregar la información del usuario al request
    req.user = {
      id_admin: decoded.id_admin,
      correo: decoded.correo,
      nombre: decoded.nombre,
      rol: decoded.rol || 'usuario'
    };

    // Continuar con el siguiente middleware o ruta
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        message: 'Token expirado'
      });
    }

    return res.status(401).json({
      success: false,
      message: 'Token inválido'
    });
  }
}

/**
 * Middleware opcional - no falla si no hay token
 * Útil para rutas que pueden funcionar con o sin autenticación
 */
function optionalAuth(req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    req.user = null;
    return next();
  }

  const token = authHeader.split(' ')[1];

  if (!token) {
    req.user = null;
    return next();
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = {
      id_admin: decoded.id_admin,
      correo: decoded.correo,
      nombre: decoded.nombre
    };
  } catch (error) {
    req.user = null;
  }

  next();
}

/**
 * Middleware para verificar que el usuario tenga rol de admin
 * Debe usarse después de verifyJWT
 */
function requireAdmin(req, res, next) {
  if (!req.user) {
    return res.status(401).json({
      success: false,
      message: 'No autenticado'
    });
  }

  if (req.user.rol !== 'admin') {
    return res.status(403).json({
      success: false,
      message: 'Acceso denegado. Solo administradores pueden acceder a este recurso'
    });
  }

  next();
}

module.exports = {
  verifyJWT,
  optionalAuth,
  requireAdmin
};
