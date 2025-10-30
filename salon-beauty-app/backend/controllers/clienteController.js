const db = require('../config/db');

/**
 * Obtiene los puntos y datos del cliente actual
 * Busca por el correo del usuario logueado
 */
async function getMisPuntos(req, res) {
  try {
    const pool = db.getPool();
    const correo = req.user.correo;

    const result = await pool.query(
      `SELECT id_cliente, nombre, correo, puntos, fecha_registro
       FROM clientes
       WHERE correo = $1`,
      [correo]
    );

    if (result.rows.length === 0) {
      return res.json({
        success: true,
        cliente: null,
        message: 'No tienes puntos canjeados aún'
      });
    }

    res.json({
      success: true,
      cliente: result.rows[0]
    });

  } catch (error) {
    console.error('Error obteniendo puntos:', error);
    res.status(500).json({
      success: false,
      message: 'Error en el servidor'
    });
  }
}

/**
 * Obtiene el historial de canjes del cliente actual
 */
async function getMisCanjes(req, res) {
  try {
    const pool = db.getPool();
    const correo = req.user.correo;

    // Primero obtenemos el id del cliente
    const clienteResult = await pool.query(
      'SELECT id_cliente FROM clientes WHERE correo = $1',
      [correo]
    );

    if (clienteResult.rows.length === 0) {
      return res.json({
        success: true,
        canjes: [],
        message: 'No tienes canjes registrados'
      });
    }

    const id_cliente = clienteResult.rows[0].id_cliente;

    // Obtenemos el historial
    const result = await pool.query(
      `SELECT
        h.id_canje,
        h.fecha_canje,
        h.puntos_aplicados,
        h.puntos_anteriores,
        h.puntos_nuevos,
        q.descripcion as qr_descripcion
       FROM historial_canjes h
       LEFT JOIN codigos_qr q ON h.id_qr = q.id_qr
       WHERE h.id_cliente = $1
       ORDER BY h.fecha_canje DESC
       LIMIT 50`,
      [id_cliente]
    );

    res.json({
      success: true,
      canjes: result.rows
    });

  } catch (error) {
    console.error('Error obteniendo historial:', error);
    res.status(500).json({
      success: false,
      message: 'Error en el servidor'
    });
  }
}

module.exports = {
  getMisPuntos,
  getMisCanjes
};
