CONNECT salon_user/salon_pass123@XEPDB1;

-- Aquí creamos la tabla donde guardamos los datos de los administradores del salón
-- Esta tabla guarda toda la info importante: nombre, correo, contraseña encriptada, etc.
-- Es lo que usamos para el login del sistema
CREATE TABLE administradores (
    id_admin NUMBER(10),
    nombre VARCHAR2(100) NOT NULL,
    correo VARCHAR2(100) NOT NULL,
    password_hash VARCHAR2(256) NOT NULL,  -- La contraseña va encriptada con bcrypt
    fecha_creacion DATE DEFAULT SYSDATE,
    activo CHAR(1) DEFAULT 'S' CHECK (activo IN ('S', 'N')),  -- 'S' = activo, 'N' = desactivado
    ultimo_acceso DATE,  -- Guardamos cuándo fue la última vez que entraron
    CONSTRAINT pk_admin PRIMARY KEY (id_admin),
    CONSTRAINT uk_admin_correo UNIQUE (correo)  -- No puede haber dos admins con el mismo correo
);

-- Esta secuencia genera automáticamente los IDs de los administradores
-- Empieza en 1 y va sumando de uno en uno
CREATE SEQUENCE seq_admin
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

COMMIT;

SELECT 'Tabla administradores creada exitosamente' AS STATUS FROM DUAL;
EXIT;
