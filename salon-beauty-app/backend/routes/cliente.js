const express = require('express');
const router = express.Router();
const clienteController = require('../controllers/clienteController');
const { verifyJWT } = require('../middleware/authMiddleware');

// Rutas para usuarios normales (requieren autenticación pero no admin)

// GET /api/cliente/mis-puntos - Ver mis puntos
router.get('/mis-puntos', verifyJWT, clienteController.getMisPuntos);

// GET /api/cliente/mis-canjes - Ver mi historial de canjes
router.get('/mis-canjes', verifyJWT, clienteController.getMisCanjes);

module.exports = router;
