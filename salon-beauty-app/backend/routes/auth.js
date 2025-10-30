const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

// POST /api/auth/login - Login de administrador
router.post('/login', authController.login);

// POST /api/auth/verify-token - Verificar token JWT
router.post('/verify-token', authController.verifyToken);

// POST /api/auth/update-access - Actualizar último acceso
router.post('/update-access', authController.updateLastAccess);

module.exports = router;
