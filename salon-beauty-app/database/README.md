# Sistema de Fidelidad - Salón de Belleza
## Base de Datos Oracle 11g Release 2

Este proyecto contiene la configuración completa de la base de datos para el sistema de fidelidad del salón de belleza.

## 📋 Requisitos Previos

- Docker instalado
- Docker Compose instalado
- Al menos 2GB de RAM disponibles para el contenedor

## 🚀 Instalación y Configuración

### 1. Levantar el contenedor de Oracle

```bash
docker-compose up -d
```

Este comando levantará el contenedor de Oracle 11g. El primer inicio puede tomar varios minutos (5-10 minutos) mientras Oracle se inicializa.

### 2. Verificar que Oracle esté corriendo

```bash
docker logs oracle-salon-belleza -f
```

Espera hasta ver el mensaje: `DATABASE IS READY TO USE!`

### 3. Conectarse a Oracle

**Credenciales del sistema:**
- **Host:** localhost
- **Puerto:** 1521
- **SID:** XE
- **Usuario SYSTEM:** system
- **Password SYSTEM:** oracle

**Credenciales de la aplicación:**
- **Usuario:** salon_user
- **Password:** salon_pass123

### 4. Ejecutar los scripts SQL (si no se ejecutaron automáticamente)

```bash
# Conectarse como SYSTEM
docker exec -it oracle-salon-belleza sqlplus system/oracle@XE

# Ejecutar el script de creación de usuario
@/docker-entrypoint-initdb.d/01_create_user.sql

# Salir y conectarse como salon_user
exit

# Conectarse como salon_user
docker exec -it oracle-salon-belleza sqlplus salon_user/salon_pass123@XE

# Ejecutar scripts en orden
@/docker-entrypoint-initdb.d/02_create_tables.sql
@/docker-entrypoint-initdb.d/03_create_triggers.sql
@/docker-entrypoint-initdb.d/04_insert_data.sql
```

## 📊 Estructura de la Base de Datos

### Tablas Principales

#### 1. **ADMINISTRADORES**
Gestiona los usuarios administrativos del sistema.
- `id_admin`: ID único del administrador
- `nombre`: Nombre completo
- `correo`: Email único
- `password_hash`: Contraseña encriptada
- `fecha_creacion`: Fecha de registro
- `activo`: Estado (S/N)
- `ultimo_acceso`: Último inicio de sesión

#### 2. **CLIENTES**
Almacena información de los clientes del programa de fidelidad.
- `id_cliente`: ID único del cliente
- `nombre`: Nombre completo
- `correo`: Email único
- `telefono`: Número de teléfono
- `codigo_qr`: Código QR único autogenerado
- `fecha_registro`: Fecha de alta en el sistema
- `saldo_puntos`: Puntos actuales disponibles
- `total_puntos_acumulados`: Total histórico de puntos
- `activo`: Estado (S/N)
- `ultima_visita`: Fecha de última transacción
- `notas`: Observaciones adicionales

#### 3. **RECOMPENSAS**
Catálogo de premios canjeables.
- `id_recompensa`: ID único
- `nombre`: Nombre de la recompensa
- `descripcion`: Detalle del premio
- `costo_puntos`: Puntos necesarios para canje
- `stock_disponible`: Unidades disponibles
- `disponible`: Estado (S/N)
- `fecha_creacion`: Fecha de creación
- `fecha_modificacion`: Última actualización
- `imagen_url`: URL de la imagen
- `categoria`: Categoría de la recompensa

#### 4. **TRANSACCIONES_PUNTOS**
Registro de movimientos de puntos.
- `id_transaccion`: ID único
- `id_cliente`: Referencia al cliente
- `tipo_transaccion`: GANADO, CANJEADO, AJUSTE, VENCIDO
- `puntos`: Cantidad de puntos
- `saldo_anterior`: Saldo antes de la transacción
- `saldo_nuevo`: Saldo después de la transacción
- `descripcion`: Detalle de la transacción
- `fecha_transaccion`: Fecha y hora
- `id_recompensa`: Referencia a recompensa (si aplica)
- `id_admin`: Administrador que procesó (si aplica)

#### 5. **CANJES_RECOMPENSAS**
Seguimiento de canjes de premios.
- `id_canje`: ID único
- `id_cliente`: Referencia al cliente
- `id_recompensa`: Recompensa canjeada
- `puntos_canjeados`: Puntos utilizados
- `fecha_canje`: Fecha del canje
- `estado`: PENDIENTE, ENTREGADO, CANCELADO
- `fecha_entrega`: Fecha de entrega
- `id_admin_entrego`: Quien entregó
- `notas`: Observaciones

#### 6. **TESTIMONIOS**
Reseñas y comentarios de clientes.
- `id_testimonio`: ID único
- `nombre_cliente`: Nombre del cliente
- `correo_cliente`: Email (opcional)
- `calificacion`: 1-5 estrellas
- `comentario`: Texto del testimonio
- `fecha_publicacion`: Fecha de envío
- `aprobado`: Estado de aprobación (S/N)
- `fecha_aprobacion`: Fecha de aprobación
- `id_admin_aprobo`: Quién aprobó
- `visible`: Mostrar en la web (S/N)

#### 7. **SERVICIOS**
Catálogo de servicios del salón.
- `id_servicio`: ID único
- `nombre`: Nombre del servicio
- `descripcion`: Detalle del servicio
- `precio`: Precio en colones
- `duracion_minutos`: Duración estimada
- `puntos_otorgados`: Puntos que genera
- `activo`: Disponible (S/N)
- `categoria`: Categoría del servicio
- `imagen_url`: URL de imagen

#### 8. **PRODUCTOS**
Catálogo de productos en venta.
- `id_producto`: ID único
- `nombre`: Nombre del producto
- `descripcion`: Detalle
- `precio`: Precio en colones
- `stock`: Unidades disponibles
- `puntos_otorgados`: Puntos por compra
- `activo`: Disponible (S/N)
- `marca`: Marca del producto
- `categoria`: Categoría
- `imagen_url`: URL de imagen

## 🔧 Procedimientos Almacenados

### sp_agregar_puntos
Agrega puntos a un cliente y registra la transacción.

```sql
CALL sp_agregar_puntos(
    p_id_cliente => 1,
    p_puntos => 50,
    p_descripcion => 'Puntos por corte de cabello',
    p_id_admin => 1
);
```

### sp_canjear_recompensa
Procesa el canje de una recompensa.

```sql
DECLARE
    v_resultado VARCHAR2(200);
BEGIN
    sp_canjear_recompensa(
        p_id_cliente => 1,
        p_id_recompensa => 1,
        p_id_admin => 1,
        p_resultado => v_resultado
    );
    DBMS_OUTPUT.PUT_LINE(v_resultado);
END;
/
```

## 📈 Vistas Disponibles

### v_clientes_resumen
Vista con resumen completo de cada cliente incluyendo estadísticas.

```sql
SELECT * FROM v_clientes_resumen WHERE activo = 'S';
```

### v_testimonios_publicos
Testimonios aprobados y visibles para mostrar en la web.

```sql
SELECT * FROM v_testimonios_publicos ORDER BY fecha_publicacion DESC;
```

## 🔍 Consultas Útiles

### Ver todos los clientes activos con sus puntos
```sql
SELECT id_cliente, nombre, correo, saldo_puntos, total_puntos_acumulados
FROM clientes
WHERE activo = 'S'
ORDER BY saldo_puntos DESC;
```

### Ver recompensas disponibles
```sql
SELECT nombre, descripcion, costo_puntos, stock_disponible
FROM recompensas
WHERE disponible = 'S' AND stock_disponible > 0
ORDER BY costo_puntos;
```

### Historial de transacciones de un cliente
```sql
SELECT tipo_transaccion, puntos, descripcion, fecha_transaccion
FROM transacciones_puntos
WHERE id_cliente = 1
ORDER BY fecha_transaccion DESC;
```

### Top clientes con más puntos
```sql
SELECT nombre, saldo_puntos, total_puntos_acumulados
FROM clientes
WHERE activo = 'S'
ORDER BY saldo_puntos DESC
FETCH FIRST 10 ROWS ONLY;
```

### Testimonios pendientes de aprobación
```sql
SELECT id_testimonio, nombre_cliente, calificacion, comentario, fecha_publicacion
FROM testimonios
WHERE aprobado = 'N'
ORDER BY fecha_publicacion;
```

## 🔌 Configuración para Node.js (Backend)

### Instalar driver de Oracle

```bash
npm install oracledb
```

### Ejemplo de conexión

```javascript
const oracledb = require('oracledb');

async function connectDB() {
    try {
        const connection = await oracledb.getConnection({
            user: 'salon_user',
            password: 'salon_pass123',
            connectString: 'localhost:1521/XE'
        });
        console.log('Conectado a Oracle!');
        return connection;
    } catch (err) {
        console.error('Error de conexión:', err);
    }
}
```

## 🔌 Configuración para Angular

### Variables de entorno para el backend

Crea un archivo `.env` en tu backend:

```env
DB_HOST=localhost
DB_PORT=1521
DB_SID=XE
DB_USER=salon_user
DB_PASSWORD=salon_pass123
```

## 🛠️ Comandos Útiles de Docker

### Ver logs del contenedor
```bash
docker logs oracle-salon-belleza -f
```

### Detener el contenedor
```bash
docker-compose down
```

### Detener y eliminar volúmenes (⚠️ borra todos los datos)
```bash
docker-compose down -v
```

### Reiniciar el contenedor
```bash
docker-compose restart
```

### Acceder al bash del contenedor
```bash
docker exec -it oracle-salon-belleza bash
```

## 📝 Datos de Prueba

El sistema viene con datos de prueba:
- 2 administradores
- 5 clientes con puntos
- 10 servicios
- 10 productos
- 10 recompensas
- Transacciones de ejemplo
- 7 testimonios

**Credenciales de administrador de prueba:**
- Email: maria.gonzalez@salon.com
- Password: admin123

## 🔐 Seguridad

- Las contraseñas deben ser hasheadas con BCrypt en el backend
- Los passwords de ejemplo usan BCrypt con salt rounds = 10
- Cambiar las credenciales en producción
- Implementar JWT para autenticación en el backend
- Usar HTTPS en producción

## 📞 Soporte

Para problemas con la base de datos:
1. Verificar que Docker esté corriendo
2. Revisar logs del contenedor
3. Verificar que el puerto 1521 no esté ocupado
4. Asegurar suficiente memoria RAM (mínimo 2GB)

## 🎯 Próximos Pasos

1. Crear el backend con Node.js/Express
2. Configurar los servicios REST API
3. Conectar Angular con el backend
4. Implementar autenticación JWT
5. Implementar generación real de códigos QR
6. Crear sistema de notificaciones por email
