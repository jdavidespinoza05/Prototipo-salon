-- ==================================================
-- Consultas Útiles y Queries de Ejemplo
-- Salón de Belleza - Sistema de Fidelidad
-- ==================================================

-- ==================================================
-- CONSULTAS PARA ADMINISTRACIÓN DE CLIENTES
-- ==================================================

-- 1. Ver todos los clientes activos ordenados por puntos
SELECT 
    id_cliente,
    nombre,
    correo,
    telefono,
    codigo_qr,
    saldo_puntos,
    total_puntos_acumulados,
    TO_CHAR(fecha_registro, 'DD/MM/YYYY') as fecha_registro,
    TO_CHAR(ultima_visita, 'DD/MM/YYYY') as ultima_visita
FROM clientes
WHERE activo = 'S'
ORDER BY saldo_puntos DESC;

-- 2. Buscar cliente por nombre, correo o teléfono
SELECT * FROM clientes
WHERE UPPER(nombre) LIKE UPPER('%patricia%')
   OR UPPER(correo) LIKE UPPER('%patricia%')
   OR telefono LIKE '%8888%';

-- 3. Clientes con más de X puntos
SELECT nombre, correo, saldo_puntos
FROM clientes
WHERE saldo_puntos >= 200 AND activo = 'S'
ORDER BY saldo_puntos DESC;

-- 4. Clientes inactivos en los últimos 30 días
SELECT nombre, correo, telefono, ultima_visita,
       TRUNC(SYSDATE - ultima_visita) as dias_inactivo
FROM clientes
WHERE ultima_visita < SYSDATE - 30
  AND activo = 'S'
ORDER BY ultima_visita;

-- 5. Estadísticas generales de clientes
SELECT 
    COUNT(*) as total_clientes,
    COUNT(CASE WHEN activo = 'S' THEN 1 END) as clientes_activos,
    COUNT(CASE WHEN activo = 'N' THEN 1 END) as clientes_inactivos,
    SUM(saldo_puntos) as total_puntos_sistema,
    AVG(saldo_puntos) as promedio_puntos,
    MAX(saldo_puntos) as max_puntos,
    MIN(saldo_puntos) as min_puntos
FROM clientes;

-- ==================================================
-- CONSULTAS PARA TRANSACCIONES Y MOVIMIENTOS
-- ==================================================

-- 6. Historial completo de un cliente
SELECT 
    t.fecha_transaccion,
    t.tipo_transaccion,
    t.puntos,
    t.saldo_anterior,
    t.saldo_nuevo,
    t.descripcion,
    r.nombre as recompensa
FROM transacciones_puntos t
LEFT JOIN recompensas r ON t.id_recompensa = r.id_recompensa
WHERE t.id_cliente = 1
ORDER BY t.fecha_transaccion DESC;

-- 7. Transacciones del día
SELECT 
    c.nombre as cliente,
    t.tipo_transaccion,
    t.puntos,
    t.descripcion,
    TO_CHAR(t.fecha_transaccion, 'HH24:MI:SS') as hora
FROM transacciones_puntos t
JOIN clientes c ON t.id_cliente = c.id_cliente
WHERE TRUNC(t.fecha_transaccion) = TRUNC(SYSDATE)
ORDER BY t.fecha_transaccion DESC;

-- 8. Transacciones por tipo (resumen)
SELECT 
    tipo_transaccion,
    COUNT(*) as cantidad,
    SUM(puntos) as total_puntos,
    AVG(puntos) as promedio_puntos
FROM transacciones_puntos
WHERE TRUNC(fecha_transaccion) >= TRUNC(SYSDATE) - 30
GROUP BY tipo_transaccion
ORDER BY cantidad DESC;

-- 9. Top 10 clientes que más gastan puntos
SELECT 
    c.nombre,
    c.correo,
    COUNT(t.id_transaccion) as num_canjes,
    SUM(t.puntos) as total_puntos_canjeados
FROM clientes c
JOIN transacciones_puntos t ON c.id_cliente = t.id_cliente
WHERE t.tipo_transaccion = 'CANJEADO'
GROUP BY c.id_cliente, c.nombre, c.correo
ORDER BY total_puntos_canjeados DESC
FETCH FIRST 10 ROWS ONLY;

-- ==================================================
-- CONSULTAS PARA RECOMPENSAS
-- ==================================================

-- 10. Recompensas disponibles con stock
SELECT 
    id_recompensa,
    nombre,
    descripcion,
    costo_puntos,
    stock_disponible,
    categoria
FROM recompensas
WHERE disponible = 'S' AND stock_disponible > 0
ORDER BY costo_puntos;

-- 11. Recompensas más canjeadas
SELECT 
    r.nombre,
    r.costo_puntos,
    COUNT(c.id_canje) as veces_canjeada,
    SUM(c.puntos_canjeados) as total_puntos_usados
FROM recompensas r
JOIN canjes_recompensas c ON r.id_recompensa = c.id_recompensa
GROUP BY r.id_recompensa, r.nombre, r.costo_puntos
ORDER BY veces_canjeada DESC;

-- 12. Recompensas con bajo stock (alerta)
SELECT nombre, stock_disponible, costo_puntos
FROM recompensas
WHERE stock_disponible <= 5 AND disponible = 'S'
ORDER BY stock_disponible;

-- 13. Clientes que pueden canjear cada recompensa
SELECT 
    r.nombre as recompensa,
    r.costo_puntos,
    COUNT(c.id_cliente) as clientes_elegibles
FROM recompensas r
CROSS JOIN clientes c
WHERE c.saldo_puntos >= r.costo_puntos
  AND c.activo = 'S'
  AND r.disponible = 'S'
  AND r.stock_disponible > 0
GROUP BY r.id_recompensa, r.nombre, r.costo_puntos
ORDER BY clientes_elegibles DESC;

-- ==================================================
-- CONSULTAS PARA CANJES
-- ==================================================

-- 14. Canjes pendientes de entrega
SELECT 
    cn.id_canje,
    c.nombre as cliente,
    c.telefono,
    r.nombre as recompensa,
    cn.puntos_canjeados,
    TO_CHAR(cn.fecha_canje, 'DD/MM/YYYY HH24:MI') as fecha_canje,
    TRUNC(SYSDATE - cn.fecha_canje) as dias_pendiente
FROM canjes_recompensas cn
JOIN clientes c ON cn.id_cliente = c.id_cliente
JOIN recompensas r ON cn.id_recompensa = r.id_recompensa
WHERE cn.estado = 'PENDIENTE'
ORDER BY cn.fecha_canje;

-- 15. Historial de canjes de un cliente
SELECT 
    r.nombre as recompensa,
    cn.puntos_canjeados,
    cn.estado,
    TO_CHAR(cn.fecha_canje, 'DD/MM/YYYY') as fecha_canje,
    TO_CHAR(cn.fecha_entrega, 'DD/MM/YYYY') as fecha_entrega
FROM canjes_recompensas cn
JOIN recompensas r ON cn.id_recompensa = r.id_recompensa
WHERE cn.id_cliente = 1
ORDER BY cn.fecha_canje DESC;

-- 16. Canjes del mes actual
SELECT 
    TO_CHAR(cn.fecha_canje, 'DD') as dia,
    COUNT(*) as cantidad_canjes,
    SUM(cn.puntos_canjeados) as puntos_totales
FROM canjes_recompensas cn
WHERE EXTRACT(MONTH FROM cn.fecha_canje) = EXTRACT(MONTH FROM SYSDATE)
  AND EXTRACT(YEAR FROM cn.fecha_canje) = EXTRACT(YEAR FROM SYSDATE)
GROUP BY TO_CHAR(cn.fecha_canje, 'DD')
ORDER BY dia;

-- ==================================================
-- CONSULTAS PARA TESTIMONIOS
-- ==================================================

-- 17. Testimonios públicos (para mostrar en la web)
SELECT 
    nombre_cliente,
    calificacion,
    comentario,
    TO_CHAR(fecha_publicacion, 'DD/MM/YYYY') as fecha
FROM v_testimonios_publicos
FETCH FIRST 10 ROWS ONLY;

-- 18. Testimonios pendientes de aprobación
SELECT 
    id_testimonio,
    nombre_cliente,
    correo_cliente,
    calificacion,
    comentario,
    TO_CHAR(fecha_publicacion, 'DD/MM/YYYY HH24:MI') as fecha
FROM testimonios
WHERE aprobado = 'N'
ORDER BY fecha_publicacion;

-- 19. Estadísticas de testimonios
SELECT 
    COUNT(*) as total_testimonios,
    COUNT(CASE WHEN aprobado = 'S' THEN 1 END) as aprobados,
    COUNT(CASE WHEN aprobado = 'N' THEN 1 END) as pendientes,
    ROUND(AVG(calificacion), 2) as calificacion_promedio,
    COUNT(CASE WHEN calificacion = 5 THEN 1 END) as cinco_estrellas,
    COUNT(CASE WHEN calificacion = 4 THEN 1 END) as cuatro_estrellas,
    COUNT(CASE WHEN calificacion = 3 THEN 1 END) as tres_estrellas
FROM testimonios
WHERE visible = 'S';

-- ==================================================
-- CONSULTAS PARA SERVICIOS Y PRODUCTOS
-- ==================================================

-- 20. Servicios activos por categoría
SELECT 
    categoria,
    COUNT(*) as cantidad_servicios,
    AVG(precio) as precio_promedio,
    SUM(puntos_otorgados) as puntos_totales
FROM servicios
WHERE activo = 'S'
GROUP BY categoria
ORDER BY cantidad_servicios DESC;

-- 21. Productos con bajo stock
SELECT 
    nombre,
    marca,
    categoria,
    stock,
    precio
FROM productos
WHERE stock <= 10 AND activo = 'S'
ORDER BY stock;

-- 22. Servicios más rentables (puntos vs precio)
SELECT 
    nombre,
    precio,
    puntos_otorgados,
    ROUND(precio / puntos_otorgados, 2) as costo_por_punto,
    duracion_minutos
FROM servicios
WHERE activo = 'S' AND puntos_otorgados > 0
ORDER BY costo_por_punto DESC;

-- ==================================================
-- REPORTES Y ANÁLISIS
-- ==================================================

-- 23. Reporte mensual de actividad
SELECT 
    TO_CHAR(fecha_transaccion, 'YYYY-MM') as mes,
    tipo_transaccion,
    COUNT(*) as cantidad,
    SUM(puntos) as total_puntos
FROM transacciones_puntos
WHERE fecha_transaccion >= ADD_MONTHS(SYSDATE, -6)
GROUP BY TO_CHAR(fecha_transaccion, 'YYYY-MM'), tipo_transaccion
ORDER BY mes DESC, tipo_transaccion;

-- 24. Clientes nuevos por mes
SELECT 
    TO_CHAR(fecha_registro, 'YYYY-MM') as mes,
    COUNT(*) as nuevos_clientes
FROM clientes
WHERE fecha_registro >= ADD_MONTHS(SYSDATE, -12)
GROUP BY TO_CHAR(fecha_registro, 'YYYY-MM')
ORDER BY mes DESC;

-- 25. Top 5 clientes más leales (por total acumulado)
SELECT 
    nombre,
    correo,
    telefono,
    total_puntos_acumulados,
    saldo_puntos,
    TO_CHAR(fecha_registro, 'DD/MM/YYYY') as miembro_desde,
    TRUNC(SYSDATE - fecha_registro) as dias_como_cliente
FROM clientes
WHERE activo = 'S'
ORDER BY total_puntos_acumulados DESC
FETCH FIRST 5 ROWS ONLY;

-- ==================================================
-- CONSULTAS PARA DASHBOARD
-- ==================================================

-- 26. Dashboard general (resumen ejecutivo)
SELECT 
    (SELECT COUNT(*) FROM clientes WHERE activo = 'S') as clientes_activos,
    (SELECT SUM(saldo_puntos) FROM clientes WHERE activo = 'S') as puntos_en_sistema,
    (SELECT COUNT(*) FROM canjes_recompensas WHERE estado = 'PENDIENTE') as canjes_pendientes,
    (SELECT COUNT(*) FROM testimonios WHERE aprobado = 'N') as testimonios_pendientes,
    (SELECT COUNT(*) FROM transacciones_puntos WHERE TRUNC(fecha_transaccion) = TRUNC(SYSDATE)) as transacciones_hoy,
    (SELECT ROUND(AVG(calificacion), 2) FROM testimonios WHERE aprobado = 'S') as calificacion_promedio
FROM DUAL;

-- ==================================================
-- MANTENIMIENTO Y AUDITORÍA
-- ==================================================

-- 27. Verificar integridad de saldos
SELECT 
    c.id_cliente,
    c.nombre,
    c.saldo_puntos as saldo_registrado,
    NVL((
        SELECT 
            SUM(CASE 
                WHEN tipo_transaccion = 'GANADO' THEN puntos
                WHEN tipo_transaccion = 'CANJEADO' THEN -puntos
                WHEN tipo_transaccion = 'AJUSTE' THEN puntos
                WHEN tipo_transaccion = 'VENCIDO' THEN -puntos
            END)
        FROM transacciones_puntos
        WHERE id_cliente = c.id_cliente
    ), 0) as saldo_calculado,
    c.saldo_puntos - NVL((
        SELECT 
            SUM(CASE 
                WHEN tipo_transaccion = 'GANADO' THEN puntos
                WHEN tipo_transaccion = 'CANJEADO' THEN -puntos
                WHEN tipo_transaccion = 'AJUSTE' THEN puntos
                WHEN tipo_transaccion = 'VENCIDO' THEN -puntos
            END)
        FROM transacciones_puntos
        WHERE id_cliente = c.id_cliente
    ), 0) as diferencia
FROM clientes c
WHERE activo = 'S';

-- 28. Actividad de administradores
SELECT 
    a.nombre,
    a.correo,
    COUNT(t.id_transaccion) as transacciones_procesadas,
    TO_CHAR(a.ultimo_acceso, 'DD/MM/YYYY HH24:MI') as ultimo_acceso
FROM administradores a
LEFT JOIN transacciones_puntos t ON a.id_admin = t.id_admin
WHERE a.activo = 'S'
GROUP BY a.id_admin, a.nombre, a.correo, a.ultimo_acceso
ORDER BY transacciones_procesadas DESC;

-- ==================================================
-- FIN DE CONSULTAS ÚTILES
-- ==================================================
