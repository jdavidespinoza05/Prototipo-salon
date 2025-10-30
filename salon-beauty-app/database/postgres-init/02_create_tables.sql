-- Tabla de administradores y usuarios
-- Guarda toda la información importante: nombre, correo, contraseña encriptada, rol, etc.
-- Esta tabla se usa para el login del sistema
CREATE TABLE administradores (
    id_admin SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(256) NOT NULL,
    rol VARCHAR(20) DEFAULT 'usuario' CHECK (rol IN ('admin', 'usuario')),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo CHAR(1) DEFAULT 'S' CHECK (activo IN ('S', 'N')),
    ultimo_acceso TIMESTAMP
);

-- Índice para búsquedas rápidas por correo
CREATE INDEX idx_admin_correo ON administradores(correo);

-- Índice para filtrar por administradores activos
CREATE INDEX idx_admin_activo ON administradores(activo);

-- Índice para filtrar por rol
CREATE INDEX idx_admin_rol ON administradores(rol);
