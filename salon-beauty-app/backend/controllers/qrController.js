const QRCode = require('qrcode');
const { v4: uuidv4 } = require('uuid');
const db = require('../config/db');

/**
 * Genera un nuevo código QR
 * Solo los administradores pueden generar QR codes
 */
async function generateQR(req, res) {
  const { puntos, descripcion, uso_multiple, dias_expiracion } = req.body;
  const id_admin = req.user?.id_admin; // Del middleware de autenticación

  // Validaciones
  if (!puntos || typeof puntos !== 'number') {
    return res.status(400).json({
      success: false,
      message: 'Los puntos son requeridos y deben ser un número'
    });
  }

  if (!id_admin) {
    return res.status(401).json({
      success: false,
      message: 'Usuario no autenticado'
    });
  }

  try {
    const pool = db.getPool();

    // Generar token único usando UUID
    const token_unico = uuidv4();

    // Calcular fecha de expiración si se especifica
    let fecha_expiracion = null;
    if (dias_expiracion && dias_expiracion > 0) {
      fecha_expiracion = new Date();
      fecha_expiracion.setDate(fecha_expiracion.getDate() + dias_expiracion);
    }

    // Insertar en la base de datos
    const result = await pool.query(
      `INSERT INTO codigos_qr
       (token_unico, puntos, descripcion, uso_multiple, fecha_expiracion, id_admin_creador)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING *`,
      [token_unico, puntos, descripcion || null, uso_multiple || false, fecha_expiracion, id_admin]
    );

    const qrData = result.rows[0];

    // Generar la URL de canje
    const canjeUrl = `${process.env.FRONTEND_URL || 'http://localhost'}/canjear/${token_unico}`;

    // Generar el código QR como base64
    const qrCodeImage = await QRCode.toDataURL(canjeUrl, {
      errorCorrectionLevel: 'H',
      type: 'image/png',
      width: 300,
      margin: 2
    });

    res.status(201).json({
      success: true,
      message: 'Código QR generado exitosamente',
      qr: {
        id_qr: qrData.id_qr,
        token_unico: qrData.token_unico,
        puntos: qrData.puntos,
        descripcion: qrData.descripcion,
        estado: qrData.estado,
        uso_multiple: qrData.uso_multiple,
        fecha_creacion: qrData.fecha_creacion,
        fecha_expiracion: qrData.fecha_expiracion,
        canjeUrl: canjeUrl,
        qrCodeImage: qrCodeImage
      }
    });

  } catch (error) {
    console.error('Error generando QR:', error);
    res.status(500).json({
      success: false,
      message: 'Error al generar el código QR',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
}

/**
 * Lista todos los códigos QR generados
 * Con filtros opcionales por estado
 */
async function listQRCodes(req, res) {
  const { estado, limit = 50, offset = 0 } = req.query;

  try {
    const pool = db.getPool();

    let query = `
      SELECT
        qr.*,
        a.nombre as admin_nombre,
        c.nombre as cliente_nombre,
        c.correo as cliente_correo
      FROM codigos_qr qr
      LEFT JOIN administradores a ON qr.id_admin_creador = a.id_admin
      LEFT JOIN clientes c ON qr.id_cliente_canje = c.id_cliente
    `;

    const params = [];

    if (estado) {
      query += ` WHERE qr.estado = $1`;
      params.push(estado);
    }

    query += ` ORDER BY qr.fecha_creacion DESC LIMIT $${params.length + 1} OFFSET $${params.length + 2}`;
    params.push(limit, offset);

    const result = await pool.query(query, params);

    res.json({
      success: true,
      qrcodes: result.rows,
      total: result.rows.length
    });

  } catch (error) {
    console.error('Error listando QR codes:', error);
    res.status(500).json({
      success: false,
      message: 'Error al listar los códigos QR',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
}

/**
 * Obtiene los detalles de un QR específico
 */
async function getQRDetails(req, res) {
  const { id_qr } = req.params;

  try {
    const pool = db.getPool();

    const result = await pool.query(
      `SELECT
        qr.*,
        a.nombre as admin_nombre,
        c.nombre as cliente_nombre,
        c.correo as cliente_correo
       FROM codigos_qr qr
       LEFT JOIN administradores a ON qr.id_admin_creador = a.id_admin
       LEFT JOIN clientes c ON qr.id_cliente_canje = c.id_cliente
       WHERE qr.id_qr = $1`,
      [id_qr]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Código QR no encontrado'
      });
    }

    const qrData = result.rows[0];
    const canjeUrl = `${process.env.FRONTEND_URL || 'http://localhost'}/canjear/${qrData.token_unico}`;

    // Regenerar imagen del QR
    const qrCodeImage = await QRCode.toDataURL(canjeUrl, {
      errorCorrectionLevel: 'H',
      type: 'image/png',
      width: 300,
      margin: 2
    });

    res.json({
      success: true,
      qr: {
        ...qrData,
        canjeUrl: canjeUrl,
        qrCodeImage: qrCodeImage
      }
    });

  } catch (error) {
    console.error('Error obteniendo detalles del QR:', error);
    res.status(500).json({
      success: false,
      message: 'Error al obtener los detalles del QR',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
}

/**
 * Regenera un código QR (invalida el anterior y crea uno nuevo)
 */
async function regenerateQR(req, res) {
  const { id_qr } = req.params;
  const id_admin = req.user?.id_admin;

  if (!id_admin) {
    return res.status(401).json({
      success: false,
      message: 'Usuario no autenticado'
    });
  }

  try {
    const pool = db.getPool();

    // Obtener datos del QR actual
    const qrActual = await pool.query(
      'SELECT * FROM codigos_qr WHERE id_qr = $1',
      [id_qr]
    );

    if (qrActual.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Código QR no encontrado'
      });
    }

    const qrData = qrActual.rows[0];

    // Invalidar el QR actual
    await pool.query(
      'UPDATE codigos_qr SET estado = $1 WHERE id_qr = $2',
      ['invalido', id_qr]
    );

    // Generar nuevo token
    const nuevo_token = uuidv4();

    // Calcular nueva fecha de expiración si el anterior tenía
    let nueva_fecha_expiracion = null;
    if (qrData.fecha_expiracion) {
      const diasRestantes = Math.ceil(
        (new Date(qrData.fecha_expiracion) - new Date()) / (1000 * 60 * 60 * 24)
      );
      if (diasRestantes > 0) {
        nueva_fecha_expiracion = new Date();
        nueva_fecha_expiracion.setDate(nueva_fecha_expiracion.getDate() + diasRestantes);
      }
    }

    // Crear nuevo QR con los mismos parámetros
    const nuevoQR = await pool.query(
      `INSERT INTO codigos_qr
       (token_unico, puntos, descripcion, uso_multiple, fecha_expiracion, id_admin_creador)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING *`,
      [nuevo_token, qrData.puntos, qrData.descripcion, qrData.uso_multiple, nueva_fecha_expiracion, id_admin]
    );

    const nuevoQRData = nuevoQR.rows[0];
    const canjeUrl = `${process.env.FRONTEND_URL || 'http://localhost'}/canjear/${nuevo_token}`;

    // Generar imagen del nuevo QR
    const qrCodeImage = await QRCode.toDataURL(canjeUrl, {
      errorCorrectionLevel: 'H',
      type: 'image/png',
      width: 300,
      margin: 2
    });

    res.json({
      success: true,
      message: 'Código QR regenerado exitosamente',
      qr: {
        ...nuevoQRData,
        canjeUrl: canjeUrl,
        qrCodeImage: qrCodeImage
      }
    });

  } catch (error) {
    console.error('Error regenerando QR:', error);
    res.status(500).json({
      success: false,
      message: 'Error al regenerar el código QR',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
}

/**
 * Valida y canjea un código QR
 * Esta función es accesible públicamente (sin autenticación de admin)
 */
async function redeemQR(req, res) {
  const { token } = req.params;
  const { correo_cliente } = req.body;

  if (!correo_cliente) {
    return res.status(400).json({
      success: false,
      message: 'El correo del cliente es requerido'
    });
  }

  try {
    const pool = db.getPool();

    // Buscar el QR por token
    const qrResult = await pool.query(
      'SELECT * FROM codigos_qr WHERE token_unico = $1',
      [token]
    );

    if (qrResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: '❌ Código QR no encontrado'
      });
    }

    const qrData = qrResult.rows[0];

    // Verificar si está expirado
    if (qrData.fecha_expiracion && new Date(qrData.fecha_expiracion) < new Date()) {
      await pool.query(
        'UPDATE codigos_qr SET estado = $1 WHERE id_qr = $2',
        ['expirado', qrData.id_qr]
      );
      return res.status(400).json({
        success: false,
        message: '❌ Este código QR ha expirado'
      });
    }

    // Verificar si es válido (o si permite uso múltiple)
    if (qrData.estado !== 'valido') {
      return res.status(400).json({
        success: false,
        message: '❌ Este código QR ya fue canjeado o es inválido',
        fecha_canje: qrData.fecha_canje
      });
    }

    // Buscar el cliente
    let clienteResult = await pool.query(
      'SELECT * FROM clientes WHERE correo = $1',
      [correo_cliente.toLowerCase()]
    );

    // Si el cliente no existe, verificar si tiene cuenta en administradores
    if (clienteResult.rows.length === 0) {
      const adminResult = await pool.query(
        'SELECT nombre FROM administradores WHERE correo = $1',
        [correo_cliente.toLowerCase()]
      );

      if (adminResult.rows.length > 0) {
        // El usuario tiene cuenta pero no puntos aún, crear registro de cliente
        const nuevoCliente = await pool.query(
          'INSERT INTO clientes (nombre, correo, puntos) VALUES ($1, $2, $3) RETURNING *',
          [adminResult.rows[0].nombre, correo_cliente.toLowerCase(), 0]
        );
        clienteResult.rows[0] = nuevoCliente.rows[0];
      } else {
        // El usuario no tiene cuenta, debe registrarse
        return res.status(400).json({
          success: false,
          requireRegistration: true,
          message: 'Debes crear una cuenta para canjear este código QR',
          token: token
        });
      }
    }

    const cliente = clienteResult.rows[0];

    const puntos_antes = cliente.puntos;
    const puntos_despues = puntos_antes + qrData.puntos;

    // Actualizar puntos del cliente
    await pool.query(
      'UPDATE clientes SET puntos = $1, ultimo_canje = CURRENT_TIMESTAMP WHERE id_cliente = $2',
      [puntos_despues, cliente.id_cliente]
    );

    // Actualizar el QR (invalidar si no es de uso múltiple)
    if (!qrData.uso_multiple) {
      await pool.query(
        `UPDATE codigos_qr
         SET estado = 'invalido',
             fecha_canje = CURRENT_TIMESTAMP,
             id_cliente_canje = $1,
             veces_usado = veces_usado + 1
         WHERE id_qr = $2`,
        [cliente.id_cliente, qrData.id_qr]
      );
    } else {
      await pool.query(
        'UPDATE codigos_qr SET veces_usado = veces_usado + 1 WHERE id_qr = $1',
        [qrData.id_qr]
      );
    }

    // Registrar en historial
    await pool.query(
      `INSERT INTO historial_canjes
       (id_qr, id_cliente, puntos_aplicados, puntos_antes, puntos_despues)
       VALUES ($1, $2, $3, $4, $5)`,
      [qrData.id_qr, cliente.id_cliente, qrData.puntos, puntos_antes, puntos_despues]
    );

    res.json({
      success: true,
      message: '✅ ¡Código QR canjeado exitosamente!',
      canje: {
        puntos_aplicados: qrData.puntos,
        puntos_anteriores: puntos_antes,
        puntos_nuevos: puntos_despues,
        cliente: {
          nombre: cliente.nombre,
          correo: cliente.correo
        }
      }
    });

  } catch (error) {
    console.error('Error canjeando QR:', error);
    res.status(500).json({
      success: false,
      message: 'Error al canjear el código QR',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
}

/**
 * Obtiene el historial de canjes
 */
async function getRedemptionHistory(req, res) {
  const { limit = 50, offset = 0 } = req.query;

  try {
    const pool = db.getPool();

    const result = await pool.query(
      `SELECT
        h.*,
        c.nombre as cliente_nombre,
        c.correo as cliente_correo,
        qr.descripcion as qr_descripcion
       FROM historial_canjes h
       JOIN clientes c ON h.id_cliente = c.id_cliente
       JOIN codigos_qr qr ON h.id_qr = qr.id_qr
       ORDER BY h.fecha_canje DESC
       LIMIT $1 OFFSET $2`,
      [limit, offset]
    );

    res.json({
      success: true,
      historial: result.rows,
      total: result.rows.length
    });

  } catch (error) {
    console.error('Error obteniendo historial:', error);
    res.status(500).json({
      success: false,
      message: 'Error al obtener el historial de canjes',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
}

/**
 * Obtiene estadísticas de los QR codes
 */
async function getQRStats(req, res) {
  try {
    const pool = db.getPool();

    const stats = await pool.query(`
      SELECT
        COUNT(*) as total_qrs,
        SUM(CASE WHEN estado = 'valido' THEN 1 ELSE 0 END) as qrs_validos,
        SUM(CASE WHEN estado = 'invalido' THEN 1 ELSE 0 END) as qrs_invalidos,
        SUM(CASE WHEN estado = 'expirado' THEN 1 ELSE 0 END) as qrs_expirados,
        SUM(veces_usado) as total_canjes,
        SUM(CASE WHEN veces_usado > 0 THEN puntos ELSE 0 END) as puntos_canjeados
      FROM codigos_qr
    `);

    res.json({
      success: true,
      stats: stats.rows[0]
    });

  } catch (error) {
    console.error('Error obteniendo estadísticas:', error);
    res.status(500).json({
      success: false,
      message: 'Error al obtener las estadísticas',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
}

module.exports = {
  generateQR,
  listQRCodes,
  getQRDetails,
  regenerateQR,
  redeemQR,
  getRedemptionHistory,
  getQRStats
};
