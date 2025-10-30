-- Crear tabla de clientes/usuarios con sistema de puntos
CREATE TABLE IF NOT EXISTS clientes (
    id_cliente SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(100) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    puntos INTEGER DEFAULT 0 CHECK (puntos >= 0),
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ultimo_canje TIMESTAMP,
    activo CHAR(1) DEFAULT 'S' CHECK (activo IN ('S', 'N'))
);

-- Crear tabla de códigos QR
CREATE TABLE IF NOT EXISTS codigos_qr (
    id_qr SERIAL PRIMARY KEY,
    token_unico VARCHAR(256) NOT NULL UNIQUE,
    puntos INTEGER NOT NULL,
    descripcion VARCHAR(255),
    estado VARCHAR(20) DEFAULT 'valido' CHECK (estado IN ('valido', 'invalido', 'expirado')),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_expiracion TIMESTAMP,
    fecha_canje TIMESTAMP,
    id_cliente_canje INTEGER REFERENCES clientes(id_cliente),
    id_admin_creador INTEGER REFERENCES administradores(id_admin) NOT NULL,
    veces_usado INTEGER DEFAULT 0,
    uso_multiple BOOLEAN DEFAULT FALSE
);

-- Crear tabla de historial de canjes
CREATE TABLE IF NOT EXISTS historial_canjes (
    id_historial SERIAL PRIMARY KEY,
    id_qr INTEGER REFERENCES codigos_qr(id_qr) NOT NULL,
    id_cliente INTEGER REFERENCES clientes(id_cliente) NOT NULL,
    puntos_aplicados INTEGER NOT NULL,
    fecha_canje TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    puntos_antes INTEGER NOT NULL,
    puntos_despues INTEGER NOT NULL
);

-- Índices para mejorar rendimiento
CREATE INDEX idx_qr_token ON codigos_qr(token_unico);
CREATE INDEX idx_qr_estado ON codigos_qr(estado);
CREATE INDEX idx_cliente_correo ON clientes(correo);
CREATE INDEX idx_historial_cliente ON historial_canjes(id_cliente);
CREATE INDEX idx_historial_qr ON historial_canjes(id_qr);

-- Insertar algunos clientes de prueba
INSERT INTO clientes (nombre, correo, telefono, puntos) VALUES
    ('Ana Martínez', 'ana.martinez@example.com', '555-0101', 150),
    ('Pedro Sánchez', 'pedro.sanchez@example.com', '555-0102', 200),
    ('Laura García', 'laura.garcia@example.com', '555-0103', 50);

-- Comentarios sobre las tablas
COMMENT ON TABLE clientes IS 'Tabla de clientes del salón con sistema de puntos';
COMMENT ON TABLE codigos_qr IS 'Tabla de códigos QR generados por administradores';
COMMENT ON TABLE historial_canjes IS 'Historial de todos los canjes realizados';
COMMENT ON COLUMN codigos_qr.uso_multiple IS 'Permite que el QR se use múltiples veces si es TRUE';
COMMENT ON COLUMN codigos_qr.veces_usado IS 'Contador de veces que se ha usado el QR';
