const bcrypt = require('bcrypt');

// INSTRUCCIONES:
// 1. Cambia los datos del nuevo admin aquí abajo
// 2. Ejecuta: node crear-admin.js
// 3. Copia el comando "docker exec" que aparece al final
// 4. Pega y ejecuta ese comando en la terminal
// 5. ¡Listo! Ya puedes hacer login con ese nuevo admin

const nuevoAdmin = {
  nombre: 'Administrador',
  correo: 'admin@salon.com',
  password: 'admin123'
};

async function crearHash() {
  console.log('=== Generando hash para nuevo administrador ===\n');
  console.log(`Nombre: ${nuevoAdmin.nombre}`);
  console.log(`Correo: ${nuevoAdmin.correo}`);
  console.log(`Password: ${nuevoAdmin.password}\n`);

  const hash = await bcrypt.hash(nuevoAdmin.password, 10);
  console.log(`Hash generado: ${hash}\n`);

  console.log('=== Script SQL para insertar ===\n');
  console.log(`INSERT INTO administradores (nombre, correo, password_hash) VALUES`);
  console.log(`    ('${nuevoAdmin.nombre}', '${nuevoAdmin.correo}', '${hash}');`);
  console.log(`COMMIT;\n`);

  console.log('=== Comando Docker directo ===\n');
  console.log(`docker exec oracle-salon-belleza bash -c "echo \\"INSERT INTO salon_user.administradores (nombre, correo, password_hash) VALUES ('${nuevoAdmin.nombre}', '${nuevoAdmin.correo}', '${hash}'); COMMIT; SELECT id_admin, nombre, correo FROM salon_user.administradores WHERE correo = '${nuevoAdmin.correo}';\\" | sqlplus -s salon_user/salon_pass123@//localhost:1521/XEPDB1"`);
}

crearHash().catch(console.error);
