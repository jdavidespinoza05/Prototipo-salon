
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

SELECT * FROM clientes
WHERE UPPER(nombre) LIKE UPPER('%patricia%')
   OR UPPER(correo) LIKE UPPER('%patricia%')
   OR telefono LIKE '%8888%';

SELECT nombre, correo, saldo_puntos
FROM clientes
WHERE saldo_puntos >= 200 AND activo = 'S'
ORDER BY saldo_puntos DESC;

SELECT nombre, correo, telefono, ultima_visita,
       TRUNC(SYSDATE - ultima_visita) as dias_inactivo
FROM clientes
WHERE ultima_visita < SYSDATE - 30
  AND activo = 'S'
ORDER BY ultima_visita;

SELECT 
    COUNT(*) as total_clientes,
    COUNT(CASE WHEN activo = 'S' THEN 1 END) as clientes_activos,
    COUNT(CASE WHEN activo = 'N' THEN 1 END) as clientes_inactivos,
    SUM(saldo_puntos) as total_puntos_sistema,
    AVG(saldo_puntos) as promedio_puntos,
    MAX(saldo_puntos) as max_puntos,
    MIN(saldo_puntos) as min_puntos
FROM clientes;


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

SELECT 
    tipo_transaccion,
    COUNT(*) as cantidad,
    SUM(puntos) as total_puntos,
    AVG(puntos) as promedio_puntos
FROM transacciones_puntos
WHERE TRUNC(fecha_transaccion) >= TRUNC(SYSDATE) - 30
GROUP BY tipo_transaccion
ORDER BY cantidad DESC;


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

