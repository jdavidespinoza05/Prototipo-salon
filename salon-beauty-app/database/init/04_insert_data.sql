CONNECT salon_user/salon_pass123@XEPDB1;

-- Aquí creamos los administradores iniciales del sistema
-- Todos tienen la misma contraseña de prueba: admin123
-- El hash que ves abajo es esa contraseña encriptada con BCrypt
-- IMPORTANTE: En producción deberías cambiar estas contraseñas!

INSERT INTO administradores (nombre, correo, password_hash) VALUES
    ('Administrador', 'admin@salon.com', '$2b$10$FzRCaY9PGoI.YPNVpdPzDO0m97Yfya1fqXLWOPQNMh1f/va90Oux.');

INSERT INTO administradores (nombre, correo, password_hash) VALUES
    ('María González', 'maria.gonzalez@salon.com', '$2b$10$FzRCaY9PGoI.YPNVpdPzDO0m97Yfya1fqXLWOPQNMh1f/va90Oux.');

INSERT INTO administradores (nombre, correo, password_hash) VALUES
    ('Carlos Rodríguez', 'carlos.rodriguez@salon.com', '$2b$10$FzRCaY9PGoI.YPNVpdPzDO0m97Yfya1fqXLWOPQNMh1f/va90Oux.');

COMMIT;

-- Vamos a ver qué administradores quedaron creados
SELECT id_admin, nombre, correo, activo FROM administradores;

SELECT 'Administradores creados exitosamente' AS STATUS FROM DUAL;
EXIT;
