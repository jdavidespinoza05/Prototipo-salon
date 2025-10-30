const oracledb = require('oracledb');
const dotenv = require('dotenv');

// Cargar variables de entorno
dotenv.config();

// Aquí configuramos la conexión a Oracle
// Usamos un "pool" de conexiones para no estar abriendo y cerrando todo el tiempo
// Mínimo 2 conexiones, máximo 10, y va agregando de una en una según se necesite
const dbConfig = {
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  connectString: process.env.DB_CONNECTION_STRING,
  poolMin: 2,
  poolMax: 10,
  poolIncrement: 1
};

// Debug: Verificar que las variables se cargaron
console.log('📝 Configuración de BD cargada:');
console.log(`   - Usuario: ${dbConfig.user || '❌ NO DEFINIDO'}`);
console.log(`   - Connection String: ${dbConfig.connectString || '❌ NO DEFINIDO'}`);

// Si tienes problemas de conexión, puedes probar descomentando esta línea
// Necesitas tener instalado Oracle Instant Client en tu máquina
// oracledb.initOracleClient({ libDir: 'C:\\oracle\\instantclient_21_12' });

// Crear pool de conexiones
let pool;

async function initialize() {
  try {
    // Antes de intentar conectar, nos aseguramos que tenemos todos los datos necesarios
    if (!dbConfig.user || !dbConfig.password || !dbConfig.connectString) {
      throw new Error('Configuración de BD incompleta. Verifica el archivo .env');
    }

    pool = await oracledb.createPool(dbConfig);
    console.log('✓ Pool de conexiones Oracle creado exitosamente');
  } catch (err) {
    console.error('✗ Error creando pool de conexiones:', err);
    console.error('\n💡 Posibles soluciones:');
    console.error('   1. Verifica que el archivo .env existe en la carpeta backend/');
    console.error('   2. Verifica que Oracle esté corriendo: cd database && docker-compose ps');
    console.error('   3. Espera 2-3 minutos si acabas de iniciar Oracle');
    process.exit(1);
  }
}

async function close() {
  try {
    if (pool) {
      await pool.close(10);
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
