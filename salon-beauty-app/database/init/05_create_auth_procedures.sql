-- ==================================================
-- Scripts SQL para Autenticación
-- Salón de Belleza - Sistema de Fidelidad
-- ==================================================

-- Conectar como salon_user
CONNECT salon_user/salon_pass123@XE;

-- ==================================================
-- PROCEDIMIENTO: Verificar Login de Administrador
-- ==================================================
CREATE OR REPLACE PROCEDURE sp_login_admin (
    p_correo IN VARCHAR2,
    p_password IN VARCHAR2,
    p_success OUT NUMBER,
    p_message OUT VARCHAR2,
    p_id_admin OUT NUMBER,
    p_nombre OUT VARCHAR2,
    p_activo OUT CHAR
) AS
    v_password_hash VARCHAR2(256);
    v_count NUMBER;
BEGIN
    -- Verificar que el correo existe
    SELECT COUNT(*) INTO v_count
    FROM administradores
    WHERE correo = p_correo;
    
    IF v_count = 0 THEN
        p_success := 0;
        p_message := 'Correo no registrado';
        p_id_admin := NULL;
        p_nombre := NULL;
        p_activo := NULL;
        RETURN;
    END IF;
    
    -- Obtener datos del administrador
    SELECT password_hash, id_admin, nombre, activo
    INTO v_password_hash, p_id_admin, p_nombre, p_activo
    FROM administradores
    WHERE correo = p_correo;
    
    -- Verificar que el admin está activo
    IF p_activo = 'N' THEN
        p_success := 0;
        p_message := 'Usuario inactivo. Contacta al administrador';
        p_id_admin := NULL;
        p_nombre := NULL;
        RETURN;
    END IF;
    
    -- NOTA: En producción, aquí deberías usar bcrypt para verificar la contraseña
    -- Por ahora, comparación simple para desarrollo
    -- En el middleware, verificarás con bcrypt antes de llamar este SP
    
    -- Verificar contraseña (simplificado para demo)
    IF v_password_hash = p_password THEN
        p_success := 1;
        p_message := 'Login exitoso';
    ELSE
        p_success := 0;
        p_message := 'Contraseña incorrecta';
        p_id_admin := NULL;
        p_nombre := NULL;
        p_activo := NULL;
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        p_success := 0;
        p_message := 'Error en login: ' || SQLERRM;
        p_id_admin := NULL;
        p_nombre := NULL;
        p_activo := NULL;
END;
/

-- ==================================================
-- PROCEDIMIENTO: Actualizar Último Acceso
-- ==================================================
CREATE OR REPLACE PROCEDURE sp_update_ultimo_acceso (
    p_id_admin IN NUMBER,
    p_resultado OUT VARCHAR2
) AS
BEGIN
    -- Actualizar último acceso
    UPDATE administradores
    SET ultimo_acceso = SYSDATE
    WHERE id_admin = p_id_admin;
    
    IF SQL%ROWCOUNT > 0 THEN
        COMMIT;
        p_resultado := 'SUCCESS: Último acceso actualizado';
    ELSE
        p_resultado := 'ERROR: Administrador no encontrado';
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_resultado := 'ERROR: ' || SQLERRM;
END;
/

-- ==================================================
-- PROCEDIMIENTO: Obtener Información del Admin
-- ==================================================
CREATE OR REPLACE PROCEDURE sp_get_admin_info (
    p_id_admin IN NUMBER,
    p_success OUT NUMBER,
    p_id_admin OUT NUMBER,
    p_nombre OUT VARCHAR2,
    p_correo OUT VARCHAR2,
    p_activo OUT CHAR,
    p_fecha_creacion OUT DATE,
    p_ultimo_acceso OUT DATE
) AS
BEGIN
    SELECT 
        id_admin,
        nombre,
        correo,
        activo,
        fecha_creacion,
        ultimo_acceso
    INTO
        p_id_admin,
        p_nombre,
        p_correo,
        p_activo,
        p_fecha_creacion,
        p_ultimo_acceso
    FROM administradores
    WHERE id_admin = p_id_admin;
    
    p_success := 1;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_success := 0;
        p_id_admin := NULL;
        p_nombre := NULL;
        p_correo := NULL;
        p_activo := NULL;
        p_fecha_creacion := NULL;
        p_ultimo_acceso := NULL;
    WHEN OTHERS THEN
        p_success := 0;
        p_id_admin := NULL;
        p_nombre := NULL;
        p_correo := NULL;
        p_activo := NULL;
        p_fecha_creacion := NULL;
        p_ultimo_acceso := NULL;
END;
/

-- ==================================================
-- VISTA: Administradores Activos (sin contraseña)
-- ==================================================
CREATE OR REPLACE VIEW v_administradores_activos AS
SELECT 
    id_admin,
    nombre,
    correo,
    fecha_creacion,
    ultimo_acceso,
    activo
FROM administradores
WHERE activo = 'S'
ORDER BY nombre;

-- ==================================================
-- CONFIRMAR CAMBIOS
-- ==================================================
COMMIT;

-- Verificar que los procedimientos se crearon
SELECT object_name, object_type, status
FROM user_objects
WHERE object_type IN ('PROCEDURE', 'VIEW')
  AND object_name LIKE 'SP_%' OR object_name LIKE 'V_%'
ORDER BY object_name;

SELECT 'Procedimientos de autenticación creados exitosamente' AS STATUS FROM DUAL;
EXIT;