CONNECT salon_user/salon_pass123@XE;
-- ==================================================
-- Script de Triggers y Procedimientos 
-- Salón de Belleza - Sistema de Fidelidad
-- ==================================================

-- ==================================================
-- TRIGGER: Auto-incremento ID y generación QR para Clientes
-- COMBINADO en un solo trigger para evitar problemas de orden
-- ==================================================
CREATE OR REPLACE TRIGGER trg_cliente_id_qr
BEFORE INSERT ON clientes
FOR EACH ROW
DECLARE
    v_id NUMBER;
BEGIN
    -- Asignar ID si no está presente
    IF :NEW.id_cliente IS NULL THEN
        SELECT seq_cliente.NEXTVAL INTO v_id FROM DUAL;
        :NEW.id_cliente := v_id;
    ELSE
        v_id := :NEW.id_cliente;
    END IF;
    
    -- Generar código QR basado en el ID asignado
    IF :NEW.codigo_qr IS NULL THEN
        :NEW.codigo_qr := 'QR-' || LPAD(v_id, 8, '0') || '-' || TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS');
    END IF;
END;
/

-- ==================================================
-- TRIGGER: Auto-incremento ID Administradores
-- ==================================================
CREATE OR REPLACE TRIGGER trg_admin_id
BEFORE INSERT ON administradores
FOR EACH ROW
BEGIN
    IF :NEW.id_admin IS NULL THEN
        SELECT seq_admin.NEXTVAL INTO :NEW.id_admin FROM DUAL;
    END IF;
END;
/

-- ==================================================
-- TRIGGER: Auto-incremento ID Recompensas
-- ==================================================
CREATE OR REPLACE TRIGGER trg_recompensa_id
BEFORE INSERT ON recompensas
FOR EACH ROW
BEGIN
    IF :NEW.id_recompensa IS NULL THEN
        SELECT seq_recompensa.NEXTVAL INTO :NEW.id_recompensa FROM DUAL;
    END IF;
END;
/

-- ==================================================
-- TRIGGER: Actualizar fecha modificación Recompensas
-- ==================================================
CREATE OR REPLACE TRIGGER trg_recompensa_update
BEFORE UPDATE ON recompensas
FOR EACH ROW
BEGIN
    :NEW.fecha_modificacion := SYSDATE;
END;
/

-- ==================================================
-- TRIGGER: Auto-incremento ID Transacciones
-- ==================================================
CREATE OR REPLACE TRIGGER trg_transaccion_id
BEFORE INSERT ON transacciones_puntos
FOR EACH ROW
BEGIN
    IF :NEW.id_transaccion IS NULL THEN
        SELECT seq_transaccion.NEXTVAL INTO :NEW.id_transaccion FROM DUAL;
    END IF;
END;
/

-- ==================================================
-- TRIGGER: Auto-incremento ID Canjes
-- ==================================================
CREATE OR REPLACE TRIGGER trg_canje_id
BEFORE INSERT ON canjes_recompensas
FOR EACH ROW
BEGIN
    IF :NEW.id_canje IS NULL THEN
        SELECT seq_canje.NEXTVAL INTO :NEW.id_canje FROM DUAL;
    END IF;
END;
/

-- ==================================================
-- TRIGGER: Auto-incremento ID Testimonios
-- ==================================================
CREATE OR REPLACE TRIGGER trg_testimonio_id
BEFORE INSERT ON testimonios
FOR EACH ROW
BEGIN
    IF :NEW.id_testimonio IS NULL THEN
        SELECT seq_testimonio.NEXTVAL INTO :NEW.id_testimonio FROM DUAL;
    END IF;
END;
/

-- ==================================================
-- TRIGGER: Auto-incremento ID Servicios
-- ==================================================
CREATE OR REPLACE TRIGGER trg_servicio_id
BEFORE INSERT ON servicios
FOR EACH ROW
BEGIN
    IF :NEW.id_servicio IS NULL THEN
        SELECT seq_servicio.NEXTVAL INTO :NEW.id_servicio FROM DUAL;
    END IF;
END;
/

-- ==================================================
-- TRIGGER: Auto-incremento ID Productos
-- ==================================================
CREATE OR REPLACE TRIGGER trg_producto_id
BEFORE INSERT ON productos
FOR EACH ROW
BEGIN
    IF :NEW.id_producto IS NULL THEN
        SELECT seq_producto.NEXTVAL INTO :NEW.id_producto FROM DUAL;
    END IF;
END;
/

-- ==================================================
-- PROCEDIMIENTO: Agregar Puntos a Cliente (MEJORADO)
-- Nota: La aplicación debe controlar las transacciones externamente
-- Este SP NO hace COMMIT automático
-- ==================================================
CREATE OR REPLACE PROCEDURE sp_agregar_puntos (
    p_id_cliente IN NUMBER,
    p_puntos IN NUMBER,
    p_descripcion IN VARCHAR2,
    p_id_admin IN NUMBER DEFAULT NULL,
    p_resultado OUT VARCHAR2
) AS
    v_saldo_anterior NUMBER;
    v_saldo_nuevo NUMBER;
    v_cliente_existe NUMBER;
BEGIN
    -- Verificar que el cliente existe
    BEGIN
        SELECT COUNT(*) INTO v_cliente_existe
        FROM clientes
        WHERE id_cliente = p_id_cliente AND activo = 'S';
        
        IF v_cliente_existe = 0 THEN
            p_resultado := 'ERROR: Cliente no encontrado o inactivo';
            RETURN;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_resultado := 'ERROR: Cliente no encontrado';
            RETURN;
    END;
    
    -- Obtener saldo actual
    SELECT saldo_puntos INTO v_saldo_anterior
    FROM clientes
    WHERE id_cliente = p_id_cliente;
    
    -- Calcular nuevo saldo
    v_saldo_nuevo := v_saldo_anterior + p_puntos;
    
    -- Validar que el resultado sea positivo
    IF v_saldo_nuevo < 0 THEN
        p_resultado := 'ERROR: El saldo resultante sería negativo';
        RETURN;
    END IF;
    
    -- Actualizar cliente
    UPDATE clientes
    SET saldo_puntos = v_saldo_nuevo,
        total_puntos_acumulados = total_puntos_acumulados + CASE WHEN p_puntos > 0 THEN p_puntos ELSE 0 END,
        ultima_visita = SYSDATE
    WHERE id_cliente = p_id_cliente;
    
    -- Registrar transacción
    INSERT INTO transacciones_puntos (
        id_cliente, tipo_transaccion, puntos,
        saldo_anterior, saldo_nuevo, descripcion, id_admin
    ) VALUES (
        p_id_cliente, 
        CASE WHEN p_puntos > 0 THEN 'GANADO' ELSE 'AJUSTE' END, 
        ABS(p_puntos),
        v_saldo_anterior, 
        v_saldo_nuevo, 
        p_descripcion, 
        p_id_admin
    );
    
    -- La aplicación debe hacer COMMIT
    p_resultado := 'SUCCESS: Puntos agregados correctamente';
    
EXCEPTION
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;
/

-- ==================================================
-- PROCEDIMIENTO: Canjear Recompensa (MEJORADO)
-- Nota: La aplicación debe controlar las transacciones externamente
-- Este SP NO hace COMMIT automático
-- ==================================================
CREATE OR REPLACE PROCEDURE sp_canjear_recompensa (
    p_id_cliente IN NUMBER,
    p_id_recompensa IN NUMBER,
    p_id_admin IN NUMBER DEFAULT NULL,
    p_resultado OUT VARCHAR2
) AS
    v_costo_puntos NUMBER;
    v_saldo_actual NUMBER;
    v_stock NUMBER;
    v_saldo_anterior NUMBER;
    v_saldo_nuevo NUMBER;
    v_disponible CHAR(1);
    v_cliente_existe NUMBER;
    v_recompensa_existe NUMBER;
BEGIN
    -- Verificar que el cliente existe
    SELECT COUNT(*) INTO v_cliente_existe
    FROM clientes
    WHERE id_cliente = p_id_cliente AND activo = 'S';
    
    IF v_cliente_existe = 0 THEN
        p_resultado := 'ERROR: Cliente no encontrado o inactivo';
        RETURN;
    END IF;
    
    -- Verificar que la recompensa existe
    BEGIN
        SELECT costo_puntos, stock_disponible, disponible
        INTO v_costo_puntos, v_stock, v_disponible
        FROM recompensas
        WHERE id_recompensa = p_id_recompensa;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_resultado := 'ERROR: Recompensa no encontrada';
            RETURN;
    END;
    
    -- Verificar disponibilidad
    IF v_disponible = 'N' THEN
        p_resultado := 'ERROR: Recompensa no disponible';
        RETURN;
    END IF;
    
    -- Verificar stock
    IF v_stock <= 0 THEN
        p_resultado := 'ERROR: Recompensa sin stock disponible';
        RETURN;
    END IF;
    
    -- Obtener saldo actual del cliente
    SELECT saldo_puntos INTO v_saldo_actual
    FROM clientes
    WHERE id_cliente = p_id_cliente;
    
    -- Verificar puntos suficientes
    IF v_saldo_actual < v_costo_puntos THEN
        p_resultado := 'ERROR: Puntos insuficientes. Necesitas ' || v_costo_puntos || ' puntos, tienes ' || v_saldo_actual;
        RETURN;
    END IF;
    
    v_saldo_anterior := v_saldo_actual;
    v_saldo_nuevo := v_saldo_actual - v_costo_puntos;
    
    -- Actualizar saldo del cliente
    UPDATE clientes
    SET saldo_puntos = v_saldo_nuevo,
        ultima_visita = SYSDATE
    WHERE id_cliente = p_id_cliente;
    
    -- Reducir stock de recompensa
    UPDATE recompensas
    SET stock_disponible = stock_disponible - 1,
        fecha_modificacion = SYSDATE
    WHERE id_recompensa = p_id_recompensa;
    
    -- Registrar transacción
    INSERT INTO transacciones_puntos (
        id_cliente, tipo_transaccion, puntos,
        saldo_anterior, saldo_nuevo, descripcion,
        id_recompensa, id_admin
    ) VALUES (
        p_id_cliente, 'CANJEADO', v_costo_puntos,
        v_saldo_anterior, v_saldo_nuevo,
        'Canje de recompensa ID: ' || p_id_recompensa,
        p_id_recompensa, p_id_admin
    );
    
    -- Registrar canje
    INSERT INTO canjes_recompensas (
        id_cliente, id_recompensa, puntos_canjeados, estado
    ) VALUES (
        p_id_cliente, p_id_recompensa, v_costo_puntos, 'PENDIENTE'
    );
    
    -- La aplicación debe hacer COMMIT
    p_resultado := 'SUCCESS: Recompensa canjeada exitosamente';
    
EXCEPTION
    WHEN OTHERS THEN
        p_resultado := 'ERROR: ' || SQLERRM;
END;
/

-- ==================================================
-- VISTA: Resumen de Clientes
-- ==================================================
CREATE OR REPLACE VIEW v_clientes_resumen AS
SELECT 
    c.id_cliente,
    c.nombre,
    c.correo,
    c.telefono,
    c.codigo_qr,
    c.fecha_registro,
    c.saldo_puntos,
    c.total_puntos_acumulados,
    c.ultima_visita,
    c.activo,
    COUNT(DISTINCT t.id_transaccion) as total_transacciones,
    COUNT(DISTINCT cn.id_canje) as total_canjes
FROM clientes c
LEFT JOIN transacciones_puntos t ON c.id_cliente = t.id_cliente
LEFT JOIN canjes_recompensas cn ON c.id_cliente = cn.id_cliente
GROUP BY 
    c.id_cliente, c.nombre, c.correo, c.telefono, c.codigo_qr,
    c.fecha_registro, c.saldo_puntos, c.total_puntos_acumulados,
    c.ultima_visita, c.activo;

-- ==================================================
-- VISTA: Testimonios Aprobados
-- ==================================================
CREATE OR REPLACE VIEW v_testimonios_publicos AS
SELECT 
    id_testimonio,
    nombre_cliente,
    calificacion,
    comentario,
    fecha_publicacion
FROM testimonios
WHERE aprobado = 'S' AND visible = 'S'
ORDER BY fecha_publicacion DESC;

-- ==================================================
-- CONFIRMAR CAMBIOS
-- ==================================================
COMMIT;

-- Mensaje de confirmación
SELECT 'Triggers y procedimientos creados exitosamente (CORREGIDOS)' AS STATUS FROM DUAL;
