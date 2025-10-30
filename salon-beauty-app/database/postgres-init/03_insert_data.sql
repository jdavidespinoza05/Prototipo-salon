-- Insertar administrador principal con rol 'admin'
-- Contraseña: admin123
-- IMPORTANTE: En producción deberías cambiar esta contraseña!

INSERT INTO administradores (nombre, correo, password_hash, rol) VALUES
    ('Administrador', 'admin@salon.com', '$2b$10$FzRCaY9PGoI.YPNVpdPzDO0m97Yfya1fqXLWOPQNMh1f/va90Oux.', 'admin');

-- Insertar usuarios normales de prueba
-- Contraseña: admin123

INSERT INTO administradores (nombre, correo, password_hash, rol) VALUES
    ('María González', 'maria.gonzalez@salon.com', '$2b$10$FzRCaY9PGoI.YPNVpdPzDO0m97Yfya1fqXLWOPQNMh1f/va90Oux.', 'usuario');

INSERT INTO administradores (nombre, correo, password_hash, rol) VALUES
    ('Carlos Rodríguez', 'carlos.rodriguez@salon.com', '$2b$10$FzRCaY9PGoI.YPNVpdPzDO0m97Yfya1fqXLWOPQNMh1f/va90Oux.', 'usuario');

-- Mostrar los administradores y usuarios creados
SELECT id_admin, nombre, correo, rol, activo FROM administradores;
