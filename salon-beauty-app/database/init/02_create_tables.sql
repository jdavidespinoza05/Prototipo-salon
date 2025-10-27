CONNECT salon_user/salon_pass123@XE;

-- ==================================================
-- Script de Creación de Tablas 
-- Salón de Belleza - Sistema de Fidelidad
-- ==================================================

-- ==================================================
-- TABLA: ADMINISTRADORES
-- ==================================================
CREATE TABLE administradores (
    id_admin NUMBER(10),
    nombre VARCHAR2(100) NOT NULL,
    correo VARCHAR2(100) NOT NULL,
    password_hash VARCHAR2(256) NOT NULL,
    fecha_creacion DATE DEFAULT SYSDATE,
    activo CHAR(1) DEFAULT 'S' CHECK (activo IN ('S', 'N')),
    ultimo_acceso DATE,
    CONSTRAINT pk_admin PRIMARY KEY (id_admin),
    CONSTRAINT uk_admin_correo UNIQUE (correo)
);

-- Secuencia para administradores
CREATE SEQUENCE seq_admin
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- ==================================================
-- TABLA: CLIENTES
-- ==================================================
CREATE TABLE clientes (
    id_cliente NUMBER(10),
    nombre VARCHAR2(100) NOT NULL,
    correo VARCHAR2(100) NOT NULL,
    telefono VARCHAR2(20) NOT NULL,
    codigo_qr VARCHAR2(500),
    fecha_registro DATE DEFAULT SYSDATE,
    saldo_puntos NUMBER(10) DEFAULT 0 CHECK (saldo_puntos >= 0),
    total_puntos_acumulados NUMBER(10) DEFAULT 0,
    activo CHAR(1) DEFAULT 'S' CHECK (activo IN ('S', 'N')),
    ultima_visita DATE,
    notas VARCHAR2(500),
    CONSTRAINT pk_cliente PRIMARY KEY (id_cliente),
    CONSTRAINT uk_cliente_correo UNIQUE (correo),
    CONSTRAINT uk_cliente_qr UNIQUE (codigo_qr)
);

-- Secuencia para clientes
CREATE SEQUENCE seq_cliente
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Índices para clientes
CREATE INDEX idx_cliente_correo ON clientes(correo);
CREATE INDEX idx_cliente_codigo_qr ON clientes(codigo_qr);
CREATE INDEX idx_cliente_activo ON clientes(activo);

-- ==================================================
-- TABLA: RECOMPENSAS
-- ==================================================
CREATE TABLE recompensas (
    id_recompensa NUMBER(10),
    nombre VARCHAR2(100) NOT NULL,
    descripcion VARCHAR2(500),
    costo_puntos NUMBER(10) NOT NULL CHECK (costo_puntos > 0),
    stock_disponible NUMBER(10) DEFAULT 0 CHECK (stock_disponible >= 0),
    disponible CHAR(1) DEFAULT 'S' CHECK (disponible IN ('S', 'N')),
    fecha_creacion DATE DEFAULT SYSDATE,
    fecha_modificacion DATE,
    imagen_url VARCHAR2(500),
    categoria VARCHAR2(50),
    CONSTRAINT pk_recompensa PRIMARY KEY (id_recompensa)
);

-- Secuencia para recompensas
CREATE SEQUENCE seq_recompensa
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Índice para recompensas disponibles
CREATE INDEX idx_recompensa_disponible ON recompensas(disponible);
CREATE INDEX idx_recompensa_categoria ON recompensas(categoria);

-- ==================================================
-- TABLA: TRANSACCIONES DE PUNTOS
-- ==================================================
CREATE TABLE transacciones_puntos (
    id_transaccion NUMBER(10),
    id_cliente NUMBER(10) NOT NULL,
    tipo_transaccion VARCHAR2(20) NOT NULL CHECK (tipo_transaccion IN ('GANADO', 'CANJEADO', 'AJUSTE', 'VENCIDO')),
    puntos NUMBER(10) NOT NULL,
    saldo_anterior NUMBER(10) NOT NULL,
    saldo_nuevo NUMBER(10) NOT NULL,
    descripcion VARCHAR2(500),
    fecha_transaccion DATE DEFAULT SYSDATE,
    id_recompensa NUMBER(10),
    id_admin NUMBER(10),
    CONSTRAINT pk_transaccion PRIMARY KEY (id_transaccion),
    CONSTRAINT fk_trans_cliente FOREIGN KEY (id_cliente) 
        REFERENCES clientes(id_cliente) ON DELETE CASCADE,
    CONSTRAINT fk_trans_recompensa FOREIGN KEY (id_recompensa) 
        REFERENCES recompensas(id_recompensa),
    CONSTRAINT fk_trans_admin FOREIGN KEY (id_admin) 
        REFERENCES administradores(id_admin)
);

-- Secuencia para transacciones
CREATE SEQUENCE seq_transaccion
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Índices para transacciones
CREATE INDEX idx_trans_cliente ON transacciones_puntos(id_cliente);
CREATE INDEX idx_trans_fecha ON transacciones_puntos(fecha_transaccion);
CREATE INDEX idx_trans_tipo ON transacciones_puntos(tipo_transaccion);

-- ==================================================
-- TABLA: CANJES DE RECOMPENSAS
-- ==================================================
CREATE TABLE canjes_recompensas (
    id_canje NUMBER(10),
    id_cliente NUMBER(10) NOT NULL,
    id_recompensa NUMBER(10) NOT NULL,
    puntos_canjeados NUMBER(10) NOT NULL,
    fecha_canje DATE DEFAULT SYSDATE,
    estado VARCHAR2(20) DEFAULT 'PENDIENTE' CHECK (estado IN ('PENDIENTE', 'ENTREGADO', 'CANCELADO')),
    fecha_entrega DATE,
    id_admin_entrego NUMBER(10),
    notas VARCHAR2(500),
    CONSTRAINT pk_canje PRIMARY KEY (id_canje),
    CONSTRAINT fk_canje_cliente FOREIGN KEY (id_cliente) 
        REFERENCES clientes(id_cliente),
    CONSTRAINT fk_canje_recompensa FOREIGN KEY (id_recompensa) 
        REFERENCES recompensas(id_recompensa),
    CONSTRAINT fk_canje_admin FOREIGN KEY (id_admin_entrego) 
        REFERENCES administradores(id_admin)
);

-- Secuencia para canjes
CREATE SEQUENCE seq_canje
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Índices para canjes
CREATE INDEX idx_canje_cliente ON canjes_recompensas(id_cliente);
CREATE INDEX idx_canje_estado ON canjes_recompensas(estado);
CREATE INDEX idx_canje_fecha ON canjes_recompensas(fecha_canje);

-- ==================================================
-- TABLA: TESTIMONIOS
-- ==================================================
CREATE TABLE testimonios (
    id_testimonio NUMBER(10),
    nombre_cliente VARCHAR2(100) NOT NULL,
    correo_cliente VARCHAR2(100),
    calificacion NUMBER(1) CHECK (calificacion BETWEEN 1 AND 5),
    comentario VARCHAR2(1000) NOT NULL,
    fecha_publicacion DATE DEFAULT SYSDATE,
    aprobado CHAR(1) DEFAULT 'N' CHECK (aprobado IN ('S', 'N')),
    fecha_aprobacion DATE,
    id_admin_aprobo NUMBER(10),
    visible CHAR(1) DEFAULT 'S' CHECK (visible IN ('S', 'N')),
    CONSTRAINT pk_testimonio PRIMARY KEY (id_testimonio),
    CONSTRAINT fk_test_admin FOREIGN KEY (id_admin_aprobo) 
        REFERENCES administradores(id_admin)
);

-- Secuencia para testimonios
CREATE SEQUENCE seq_testimonio
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Índices para testimonios
CREATE INDEX idx_test_aprobado ON testimonios(aprobado);
CREATE INDEX idx_test_visible ON testimonios(visible);
CREATE INDEX idx_test_fecha ON testimonios(fecha_publicacion);

-- ==================================================
-- TABLA: SERVICIOS
-- ==================================================
CREATE TABLE servicios (
    id_servicio NUMBER(10),
    nombre VARCHAR2(100) NOT NULL,
    descripcion VARCHAR2(500),
    precio NUMBER(10,2) NOT NULL CHECK (precio >= 0),
    duracion_minutos NUMBER(5),
    puntos_otorgados NUMBER(5) DEFAULT 0,
    activo CHAR(1) DEFAULT 'S' CHECK (activo IN ('S', 'N')),
    categoria VARCHAR2(50),
    imagen_url VARCHAR2(500),
    CONSTRAINT pk_servicio PRIMARY KEY (id_servicio)
);

-- Secuencia para servicios
CREATE SEQUENCE seq_servicio
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE INDEX idx_servicio_activo ON servicios(activo);
CREATE INDEX idx_servicio_categoria ON servicios(categoria);

-- ==================================================
-- TABLA: PRODUCTOS
-- ==================================================
CREATE TABLE productos (
    id_producto NUMBER(10),
    nombre VARCHAR2(100) NOT NULL,
    descripcion VARCHAR2(500),
    precio NUMBER(10,2) NOT NULL CHECK (precio >= 0),
    stock NUMBER(10) DEFAULT 0 CHECK (stock >= 0),
    puntos_otorgados NUMBER(5) DEFAULT 0,
    activo CHAR(1) DEFAULT 'S' CHECK (activo IN ('S', 'N')),
    marca VARCHAR2(50),
    categoria VARCHAR2(50),
    imagen_url VARCHAR2(500),
    CONSTRAINT pk_producto PRIMARY KEY (id_producto)
);

-- Secuencia para productos
CREATE SEQUENCE seq_producto
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE INDEX idx_producto_activo ON productos(activo);
CREATE INDEX idx_producto_categoria ON productos(categoria);

-- ==================================================
-- CONFIRMAR CAMBIOS
-- ==================================================
COMMIT;

-- Mensaje de confirmación
SELECT 'Tablas creadas exitosamente con todas las columnas' AS STATUS FROM DUAL;