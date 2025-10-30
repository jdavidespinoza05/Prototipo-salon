const { Pool } = require('pg');
const dotenv = require('dotenv');

// Cargar variables de entorno
dotenv.config();

// Configuración del pool de conexiones de PostgreSQL
const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'salon_beauty',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
  max: 10,  // Máximo de conexiones en el pool
  min: 2,   // Mínimo de conexiones en el pool
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
};

// Debug: Verificar que las variables se cargaron
console.log('📝 Configuración de BD cargada:');
console.log(`   - Host: ${dbConfig.host || '❌ NO DEFINIDO'}`);
console.log(`   - Port: ${dbConfig.port || '❌ NO DEFINIDO'}`);
console.log(`   - Database: ${dbConfig.database || '❌ NO DEFINIDO'}`);
console.log(`   - User: ${dbConfig.user || '❌ NO DEFINIDO'}`);

// Crear pool de conexiones
let pool;

async function initialize() {
  try {
    // Verificar configuración
    if (!dbConfig.host || !dbConfig.user || !dbConfig.password || !dbConfig.database) {
      throw new Error('Configuración de BD incompleta. Verifica el archivo .env');
    }

    pool = new Pool(dbConfig);

    // Probar la conexión
    const client = await pool.connect();
    console.log('✓ Pool de conexiones PostgreSQL creado exitosamente');
    client.release();
  } catch (err) {
    console.error('✗ Error creando pool de conexiones:', err);
    console.error('\n💡 Posibles soluciones:');
    console.error('   1. Verifica que el archivo .env existe en la carpeta backend/');
    console.error('   2. Verifica que PostgreSQL esté corriendo: docker-compose ps');
    console.error('   3. Espera unos segundos si acabas de iniciar PostgreSQL');
    throw err;
  }
}

async function close() {
  try {
    if (pool) {
      await pool.end();
      console.log('✓ Pool de conexiones cerrado');
    }
  } catch (err) {
    console.error('✗ Error cerrando pool:', err);
  }
}

function getPool() {
  return pool;
}

module.exports = {
  initialize,
  close,
  getPool
};
