const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const authRoutes = require('./routes/auth');
const db = require('./config/db');

// Cargamos las variables de entorno del archivo .env
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Nos conectamos a la base de datos apenas arranca el servidor
// Si no se puede conectar, mejor apagamos todo en vez de seguir con errores
db.initialize().catch(err => {
  console.error('Error fatal al inicializar BD:', err);
  process.exit(1);
});

// Configuramos los middlewares básicos que necesita Express
app.use(cors());  // Para que el frontend pueda hablarle al backend sin problemas
app.use(express.json());  // Para poder recibir JSON en las peticiones
app.use(express.urlencoded({ extended: true }));  // Para poder recibir formularios

// Este middleware nos va mostrando en la consola cada petición que llega
// Útil para debuggear y ver qué está pasando
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Aquí montamos las rutas de autenticación (login, verify, etc.)
app.use('/api/auth', authRoutes);

// Una ruta simple para verificar que el servidor está vivo
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV
  });
});

// Si alguien intenta entrar a una ruta que no existe, les respondemos con un 404
app.use((req, res) => {
  res.status(404).json({
    error: 'Ruta no encontrada',
    path: req.path
  });
});

// Si algo explota en cualquier parte del servidor, lo atrapamos aquí
// En desarrollo mostramos el error completo, en producción solo un mensaje genérico
app.use((err, req, res, next) => {
  console.error('Error global:', err);
  res.status(500).json({
    error: 'Error interno del servidor',
    message: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

// Prendemos el servidor y lo ponemos a escuchar en el puerto configurado
app.listen(PORT, () => {
  console.log(`✓ Servidor ejecutándose en http://localhost:${PORT}`);
  console.log(`✓ Ambiente: ${process.env.NODE_ENV}`);
  console.log(`✓ Conectando a Oracle: ${process.env.DB_CONNECTION_STRING}`);
});

// Estas dos funciones se encargan de cerrar todo ordenadamente cuando apagamos el servidor
// Así nos aseguramos de cerrar la conexión a la BD antes de salir
process.on('SIGTERM', async () => {
  console.log('SIGTERM recibido, cerrando servidor...');
  await db.close();
  process.exit(0);
});

process.on('SIGINT', async () => {
  console.log('SIGINT recibido, cerrando servidor...');
  await db.close();
  process.exit(0);
});
