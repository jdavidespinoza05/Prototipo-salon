CONNECT salon_user/salon_pass123@XEPDB1;

-- Actualizamos todos los administradores con el hash correcto para la contraseña: admin123
UPDATE administradores
SET password_hash = '$2b$10$9xHRRwBCU3Y4gpmdPvsw3OBHjchv46Mc4sEUFCe1fXQBX6vasknjK';

COMMIT;

-- Verificamos que se actualizaron correctamente
SELECT id_admin, nombre, correo, SUBSTR(password_hash, 1, 20) || '...' AS hash_preview
FROM administradores;

SELECT 'Password hash actualizado para todos los administradores' AS STATUS FROM DUAL;
EXIT;
