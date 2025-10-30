const express = require('express');
const router = express.Router();
const qrController = require('../controllers/qrController');
const { verifyJWT, requireAdmin } = require('../middleware/authMiddleware');

// Rutas protegidas SOLO PARA ADMINS

// POST /api/qr/generate - Generar nuevo código QR (solo admin)
router.post('/generate', verifyJWT, requireAdmin, qrController.generateQR);

// GET /api/qr/list - Listar todos los códigos QR (solo admin)
router.get('/list', verifyJWT, requireAdmin, qrController.listQRCodes);

// GET /api/qr/:id_qr - Obtener detalles de un QR específico (solo admin)
router.get('/:id_qr', verifyJWT, requireAdmin, qrController.getQRDetails);

// POST /api/qr/regenerate/:id_qr - Regenerar un código QR (solo admin)
router.post('/regenerate/:id_qr', verifyJWT, requireAdmin, qrController.regenerateQR);

// GET /api/qr/history/redemptions - Obtener historial de canjes (solo admin)
router.get('/history/redemptions', verifyJWT, requireAdmin, qrController.getRedemptionHistory);

// GET /api/qr/stats/summary - Obtener estadísticas (solo admin)
router.get('/stats/summary', verifyJWT, requireAdmin, qrController.getQRStats);

// Rutas públicas (no requieren autenticación)

// POST /api/qr/redeem/:token - Canjear un código QR (ruta pública)
router.post('/redeem/:token', qrController.redeemQR);

module.exports = router;
