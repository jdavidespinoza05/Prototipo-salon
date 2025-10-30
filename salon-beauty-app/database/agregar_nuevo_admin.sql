CONNECT salon_user/salon_pass123@XEPDB1;

-- Este script agrega un nuevo administrador a la base de datos
-- Usuario: Juan Pérez
-- Correo: juan.perez@salon.com
-- Contraseña: password123


PROMPT [ANTES] Total de administradores:
SELECT COUNT(*) as TOTAL FROM administradores;


INSERT INTO administradores (nombre, correo, password_hash) VALUES
    ('Juan Pérez', 'juan.perez@salon.com', '$2b$10$AHZ13jf9eioJtQ5KDW3ryO4wm/Wmhil5364vp0zcFWvvV50/lURtC');

COMMIT;

PROMPT
PROMPT [DESPUÉS] 
PROMPT

SELECT
    id_admin as "ID",
    nombre as "NOMBRE",
    correo as "CORREO",
    activo as "ACTIVO",
    TO_CHAR(fecha_creacion, 'DD/MM/YYYY HH24:MI') as "FECHA CREACION"
FROM administradores
WHERE correo = 'juan.perez@salon.com';

PROMPT
PROMPT [DESPUÉS] Total de administradores:
SELECT COUNT(*) as TOTAL FROM administradores;

PROMPT
PROMPT [DESPUÉS] Todos los administradores:
SELECT id_admin, nombre, correo FROM administradores ORDER BY id_admin;



EXIT;
