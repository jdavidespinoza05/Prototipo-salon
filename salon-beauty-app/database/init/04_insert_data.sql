-- ==================================================
-- Script de Datos Iniciales 
-- Salón de Belleza - Sistema de Fidelidad
-- ==================================================

-- ==================================================
-- DATOS: ADMINISTRADORES
-- ==================================================
-- Nota: Password hasheado con BCrypt
-- Password real: admin123
-- Usar BCrypt en la aplicación real para hashear passwords
INSERT INTO administradores (nombre, correo, password_hash) VALUES 
    ('María González', 'maria.gonzalez@salon.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy');

INSERT INTO administradores (nombre, correo, password_hash) VALUES 
    ('Carlos Rodríguez', 'carlos.rodriguez@salon.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy');

COMMIT;

-- ==================================================
-- DATOS: CLIENTES
-- ==================================================
INSERT INTO clientes (nombre, correo, telefono, saldo_puntos, total_puntos_acumulados) VALUES
    ('Ana Patricia Mora', 'ana.mora@email.com', '8888-1234', 150, 450);

INSERT INTO clientes (nombre, correo, telefono, saldo_puntos, total_puntos_acumulados) VALUES
    ('Luis Fernando Castro', 'luis.castro@email.com', '8888-5678', 280, 680);

INSERT INTO clientes (nombre, correo, telefono, saldo_puntos, total_puntos_acumulados) VALUES
    ('Carmen Solís Vargas', 'carmen.solis@email.com', '8888-9012', 95, 295);

INSERT INTO clientes (nombre, correo, telefono, saldo_puntos, total_puntos_acumulados) VALUES
    ('Roberto Jiménez', 'roberto.jimenez@email.com', '8888-3456', 420, 920);

INSERT INTO clientes (nombre, correo, telefono, saldo_puntos, total_puntos_acumulados) VALUES
    ('Sofía Ramírez López', 'sofia.ramirez@email.com', '8888-7890', 75, 175);

COMMIT;

-- ==================================================
-- DATOS: SERVICIOS
-- ==================================================
INSERT INTO servicios (nombre, descripcion, precio, duracion_minutos, puntos_otorgados, categoria) VALUES
    ('Corte de Cabello Dama', 'Corte y estilo personalizado para damas', 15000, 45, 15, 'Cabello');

INSERT INTO servicios (nombre, descripcion, precio, duracion_minutos, puntos_otorgados, categoria) VALUES
    ('Corte de Cabello Caballero', 'Corte tradicional o moderno para caballeros', 10000, 30, 10, 'Cabello');

INSERT INTO servicios (nombre, descripcion, precio, duracion_minutos, puntos_otorgados, categoria) VALUES
    ('Tinte Completo', 'Aplicación de tinte de alta calidad con tratamiento', 35000, 120, 35, 'Cabello');

INSERT INTO servicios (nombre, descripcion, precio, duracion_minutos, puntos_otorgados, categoria) VALUES
    ('Manicure y Pedicure', 'Tratamiento completo para manos y pies', 18000, 60, 18, 'Uñas');

INSERT INTO servicios (nombre, descripcion, precio, duracion_minutos, puntos_otorgados, categoria) VALUES
    ('Uñas Acrílicas', 'Aplicación de uñas acrílicas con diseño', 25000, 90, 25, 'Uñas');

INSERT INTO servicios (nombre, descripcion, precio, duracion_minutos, puntos_otorgados, categoria) VALUES
    ('Diseño de Cejas', 'Depilación y diseño profesional de cejas', 8000, 20, 8, 'Cejas');

INSERT INTO servicios (nombre, descripcion, precio, duracion_minutos, puntos_otorgados, categoria) VALUES
    ('Extensiones de Pestañas', 'Aplicación de extensiones pelo a pelo', 40000, 90, 40, 'Pestañas');

INSERT INTO servicios (nombre, descripcion, precio, duracion_minutos, puntos_otorgados, categoria) VALUES
    ('Facial Hidratante', 'Tratamiento facial con productos premium', 30000, 60, 30, 'Faciales');

INSERT INTO servicios (nombre, descripcion, precio, duracion_minutos, puntos_otorgados, categoria) VALUES
    ('Masaje Relajante', 'Masaje de espalda y cuello', 25000, 45, 25, 'Masajes');

INSERT INTO servicios (nombre, descripcion, precio, duracion_minutos, puntos_otorgados, categoria) VALUES
    ('Maquillaje Social', 'Maquillaje profesional para eventos', 20000, 45, 20, 'Maquillaje');

COMMIT;

-- ==================================================
-- DATOS: PRODUCTOS
-- ==================================================
INSERT INTO productos (nombre, descripcion, precio, stock, puntos_otorgados, marca, categoria) VALUES
    ('Shampoo Hidratante 500ml', 'Shampoo profesional para cabello seco', 12000, 25, 12, 'Kerastase', 'Cabello');

INSERT INTO productos (nombre, descripcion, precio, stock, puntos_otorgados, marca, categoria) VALUES
    ('Acondicionador Reparador 500ml', 'Tratamiento profundo reparador', 14000, 20, 14, 'Kerastase', 'Cabello');

INSERT INTO productos (nombre, descripcion, precio, stock, puntos_otorgados, marca, categoria) VALUES
    ('Sérum Anti-Frizz', 'Control de frizz y brillo instantáneo', 18000, 15, 18, 'Moroccanoil', 'Cabello');

INSERT INTO productos (nombre, descripcion, precio, stock, puntos_otorgados, marca, categoria) VALUES
    ('Esmalte Gel UV', 'Esmalte de larga duración en 20 colores', 8000, 50, 8, 'OPI', 'Uñas');

INSERT INTO productos (nombre, descripcion, precio, stock, puntos_otorgados, marca, categoria) VALUES
    ('Base para Uñas Fortalecedora', 'Tratamiento fortalecedor de uñas', 9000, 30, 9, 'Essie', 'Uñas');

INSERT INTO productos (nombre, descripcion, precio, stock, puntos_otorgados, marca, categoria) VALUES
    ('Crema Facial Anti-Edad', 'Crema con ácido hialurónico y colágeno', 25000, 12, 25, 'La Roche-Posay', 'Cuidado Facial');

INSERT INTO productos (nombre, descripcion, precio, stock, puntos_otorgados, marca, categoria) VALUES
    ('Mascarilla Facial Detox', 'Mascarilla de arcilla purificante', 15000, 18, 15, 'Garnier', 'Cuidado Facial');

INSERT INTO productos (nombre, descripcion, precio, stock, puntos_otorgados, marca, categoria) VALUES
    ('Aceite de Argán Puro', 'Aceite natural para cabello y piel', 16000, 20, 16, 'Moroccanoil', 'Tratamientos');

INSERT INTO productos (nombre, descripcion, precio, stock, puntos_otorgados, marca, categoria) VALUES
    ('Kit de Cepillos Profesionales', 'Set de 10 brochas para maquillaje', 22000, 10, 22, 'MAC', 'Maquillaje');

INSERT INTO productos (nombre, descripcion, precio, stock, puntos_otorgados, marca, categoria) VALUES
    ('Labial Mate Larga Duración', 'Labial en 15 tonos diferentes', 10000, 45, 10, 'Maybelline', 'Maquillaje');

COMMIT;

-- ==================================================
-- DATOS: RECOMPENSAS
-- ==================================================
INSERT INTO recompensas (nombre, descripcion, costo_puntos, stock_disponible, categoria) VALUES
    ('Corte Gratis', 'Un corte de cabello completamente gratis', 100, 50, 'Servicios');

INSERT INTO recompensas (nombre, descripcion, costo_puntos, stock_disponible, categoria) VALUES
    ('Manicure Gratis', 'Manicure completo sin costo', 150, 30, 'Servicios');

INSERT INTO recompensas (nombre, descripcion, costo_puntos, stock_disponible, categoria) VALUES
    ('Descuento 50% en Tinte', 'Media tarifa en servicio de tinte completo', 200, 25, 'Descuentos');

INSERT INTO recompensas (nombre, descripcion, costo_puntos, stock_disponible, categoria) VALUES
    ('Kit de Cuidado Capilar', 'Shampoo y acondicionador premium', 250, 15, 'Productos');

INSERT INTO recompensas (nombre, descripcion, costo_puntos, stock_disponible, categoria) VALUES
    ('Facial Express Gratis', 'Tratamiento facial exprés de 30 minutos', 180, 20, 'Servicios');

INSERT INTO recompensas (nombre, descripcion, costo_puntos, stock_disponible, categoria) VALUES
    ('Descuento 30% en Productos', 'Descuento en cualquier producto de la tienda', 120, 40, 'Descuentos');

INSERT INTO recompensas (nombre, descripcion, costo_puntos, stock_disponible, categoria) VALUES
    ('Extensiones de Pestañas Gratis', 'Aplicación completa sin costo', 350, 10, 'Servicios');

INSERT INTO recompensas (nombre, descripcion, costo_puntos, stock_disponible, categoria) VALUES
    ('Vale de ₡10,000', 'Vale canjeable por servicios o productos', 300, 20, 'Vales');

INSERT INTO recompensas (nombre, descripcion, costo_puntos, stock_disponible, categoria) VALUES
    ('Pedicure Spa Gratis', 'Pedicure con tratamiento spa', 160, 25, 'Servicios');

INSERT INTO recompensas (nombre, descripcion, costo_puntos, stock_disponible, categoria) VALUES
    ('Pack Belleza Premium', 'Set de productos premium valorado en ₡30,000', 400, 8, 'Productos');

COMMIT;

-- ==================================================
-- DATOS: TRANSACCIONES DE PUNTOS
-- Usando SUBSELECTS para obtener IDs correctos
-- ==================================================

-- Transacciones para Ana Patricia Mora
INSERT INTO transacciones_puntos (id_cliente, tipo_transaccion, puntos, saldo_anterior, saldo_nuevo, descripcion)
SELECT id_cliente, 'GANADO', 50, 0, 50, 'Puntos por corte de cabello'
FROM clientes WHERE correo = 'ana.mora@email.com';

INSERT INTO transacciones_puntos (id_cliente, tipo_transaccion, puntos, saldo_anterior, saldo_nuevo, descripcion)
SELECT id_cliente, 'GANADO', 200, 50, 250, 'Puntos por tinte completo'
FROM clientes WHERE correo = 'ana.mora@email.com';

INSERT INTO transacciones_puntos (id_cliente, tipo_transaccion, puntos, saldo_anterior, saldo_nuevo, descripcion, id_recompensa)
SELECT c.id_cliente, 'CANJEADO', 100, 250, 150, 'Canje: Corte Gratis', r.id_recompensa
FROM clientes c, recompensas r 
WHERE c.correo = 'ana.mora@email.com' AND r.nombre = 'Corte Gratis';

-- Transacciones para Luis Fernando Castro
INSERT INTO transacciones_puntos (id_cliente, tipo_transaccion, puntos, saldo_anterior, saldo_nuevo, descripcion)
SELECT id_cliente, 'GANADO', 80, 0, 80, 'Puntos por manicure y pedicure'
FROM clientes WHERE correo = 'luis.castro@email.com';

INSERT INTO transacciones_puntos (id_cliente, tipo_transaccion, puntos, saldo_anterior, saldo_nuevo, descripcion)
SELECT id_cliente, 'GANADO', 200, 80, 280, 'Puntos por compra de productos'
FROM clientes WHERE correo = 'luis.castro@email.com';

-- Transacciones para Carmen Solís
INSERT INTO transacciones_puntos (id_cliente, tipo_transaccion, puntos, saldo_anterior, saldo_nuevo, descripcion)
SELECT id_cliente, 'GANADO', 95, 0, 95, 'Puntos por servicios varios'
FROM clientes WHERE correo = 'carmen.solis@email.com';

-- Transacciones para Roberto Jiménez
INSERT INTO transacciones_puntos (id_cliente, tipo_transaccion, puntos, saldo_anterior, saldo_nuevo, descripcion)
SELECT id_cliente, 'GANADO', 120, 0, 120, 'Puntos por extensiones de pestañas'
FROM clientes WHERE correo = 'roberto.jimenez@email.com';

INSERT INTO transacciones_puntos (id_cliente, tipo_transaccion, puntos, saldo_anterior, saldo_nuevo, descripcion)
SELECT id_cliente, 'GANADO', 300, 120, 420, 'Puntos acumulados mes de enero'
FROM clientes WHERE correo = 'roberto.jimenez@email.com';

-- Transacciones para Sofía Ramírez
INSERT INTO transacciones_puntos (id_cliente, tipo_transaccion, puntos, saldo_anterior, saldo_nuevo, descripcion)
SELECT id_cliente, 'GANADO', 75, 0, 75, 'Puntos por diseño de cejas'
FROM clientes WHERE correo = 'sofia.ramirez@email.com';

COMMIT;

-- ==================================================
-- DATOS: TESTIMONIOS
-- ==================================================
INSERT INTO testimonios (nombre_cliente, correo_cliente, calificacion, comentario, aprobado, visible) VALUES
    ('Ana Patricia Mora', 'ana.mora@email.com', 5, 
     '¡Excelente servicio! El personal es muy profesional y amable. Mi cabello quedó hermoso.', 
     'S', 'S');

INSERT INTO testimonios (nombre_cliente, correo_cliente, calificacion, comentario, aprobado, visible) VALUES
    ('Luis Fernando Castro', 'luis.castro@email.com', 5, 
     'Llevo años viniendo al salón y siempre salgo satisfecho. Totalmente recomendado.', 
     'S', 'S');

INSERT INTO testimonios (nombre_cliente, correo_cliente, calificacion, comentario, aprobado, visible) VALUES
    ('Carmen Solís', 'carmen.solis@email.com', 4, 
     'Muy buen ambiente y profesionalismo. Los productos que usan son de excelente calidad.', 
     'S', 'S');

INSERT INTO testimonios (nombre_cliente, correo_cliente, calificacion, comentario, aprobado, visible) VALUES
    ('Roberto Jiménez', 'roberto.jimenez@email.com', 5, 
     'El mejor salón de la zona. Las chicas son expertas en su trabajo. 100% recomendado.', 
     'S', 'S');

INSERT INTO testimonios (nombre_cliente, correo_cliente, calificacion, comentario, aprobado, visible) VALUES
    ('Sofía Ramírez', 'sofia.ramirez@email.com', 5, 
     'Me encanta el sistema de puntos, he canjeado varias recompensas. Excelente servicio.', 
     'S', 'S');

INSERT INTO testimonios (nombre_cliente, correo_cliente, calificacion, comentario, aprobado, visible) VALUES
    ('María José Vega', 'mj.vega@email.com', 4, 
     'Primera vez que vengo y quedé encantada. Definitivamente volveré.', 
     'N', 'S');

INSERT INTO testimonios (nombre_cliente, correo_cliente, calificacion, comentario, aprobado, visible) VALUES
    ('Pedro González', 'pedro.g@email.com', 5, 
     'Ambiente agradable, buena música y café mientras esperas. Muy recomendable.', 
     'S', 'S');

COMMIT;

-- ==================================================
-- VERIFICACIÓN DE DATOS INSERTADOS
-- ==================================================
SELECT 'Administradores: ' || COUNT(*) as resultado FROM administradores 
UNION ALL
SELECT 'Clientes: ' || COUNT(*) FROM clientes 
UNION ALL
SELECT 'Servicios: ' || COUNT(*) FROM servicios 
UNION ALL
SELECT 'Productos: ' || COUNT(*) FROM productos 
UNION ALL
SELECT 'Recompensas: ' || COUNT(*) FROM recompensas 
UNION ALL
SELECT 'Transacciones: ' || COUNT(*) FROM transacciones_puntos 
UNION ALL
SELECT 'Testimonios: ' || COUNT(*) FROM testimonios;

-- Verificar integridad de clientes
SELECT 
    nombre,
    correo,
    codigo_qr,
    saldo_puntos
FROM clientes
ORDER BY id_cliente;

SELECT 'Datos iniciales insertados exitosamente (CORREGIDOS)' AS STATUS FROM DUAL;