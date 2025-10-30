# Sistema de Códigos QR - Instrucciones Completas

## 🎯 Sistema Implementado

Se ha implementado un sistema completo de generación y validación de códigos QR con control de puntos.

## 📊 Base de Datos

### Tablas Creadas

#### 1. `clientes`
Almacena los usuarios del sistema de puntos:
- `id_cliente`: ID único
- `nombre`: Nombre del cliente
- `correo`: Email único
- `telefono`: Teléfono (opcional)
- `puntos`: Puntos acumulados (default: 0)
- `fecha_registro`: Fecha de registro
- `ultimo_canje`: Última vez que canjeó
- `activo`: Estado ('S'/'N')

**Clientes de prueba insertados:**
- Ana Martínez (ana.martinez@example.com) - 150 puntos
- Pedro Sánchez (pedro.sanchez@example.com) - 200 puntos
- Laura García (laura.garcia@example.com) - 50 puntos

#### 2. `codigos_qr`
Almacena los códigos QR generados:
- `id_qr`: ID único
- `token_unico`: Token UUID único
- `puntos`: Puntos que otorga el QR
- `descripcion`: Descripción opcional
- `estado`: 'valido', 'invalido', 'expirado'
- `fecha_creacion`: Cuándo se creó
- `fecha_expiracion`: Cuándo expira (opcional)
- `fecha_canje`: Cuándo se canjeó
- `id_cliente_canje`: Quién lo canjeó
- `id_admin_creador`: Quién lo creó
- `veces_usado`: Contador de usos
- `uso_multiple`: Si permite múltiples usos

#### 3. `historial_canjes`
Registro de todos los canjes realizados:
- `id_historial`: ID único
- `id_qr`: QR canjeado
- `id_cliente`: Cliente que canjeó
- `puntos_aplicados`: Puntos dados/quitados
- `fecha_canje`: Cuándo se canjeó
- `puntos_antes`: Puntos antes del canje
- `puntos_despues`: Puntos después del canje

## 🔧 Backend API

### Endpoints Implementados

#### Rutas Protegidas (Requieren Autenticación de Admin)

**1. POST `/api/qr/generate`**
Genera un nuevo código QR

**Request Body:**
```json
{
  "puntos": 100,
  "descripcion": "Promoción especial",
  "uso_multiple": false,
  "dias_expiracion": 30
}
```

**Response:**
```json
{
  "success": true,
  "message": "Código QR generado exitosamente",
  "qr": {
    "id_qr": 1,
    "token_unico": "uuid-here",
    "puntos": 100,
    "descripcion": "Promoción especial",
    "estado": "valido",
    "fecha_creacion": "2025-10-30...",
    "canjeUrl": "http://localhost/canjear/uuid-here",
    "qrCodeImage": "data:image/png;base64,..."
  }
}
```

**2. GET `/api/qr/list`**
Lista todos los códigos QR

**Query Params:**
- `estado`: Filtrar por estado (opcional)
- `limit`: Límite de resultados (default: 50)
- `offset`: Offset para paginación (default: 0)

**3. GET `/api/qr/:id_qr`**
Obtiene detalles de un QR específico

**4. POST `/api/qr/regenerate/:id_qr`**
Regenera un QR (invalida el anterior y crea uno nuevo)

**5. GET `/api/qr/history/redemptions`**
Obtiene el historial de canjes

**6. GET `/api/qr/stats/summary`**
Obtiene estadísticas generales

**Response:**
```json
{
  "success": true,
  "stats": {
    "total_qrs": 10,
    "qrs_validos": 7,
    "qrs_invalidos": 2,
    "qrs_expirados": 1,
    "total_canjes": 25,
    "puntos_canjeados": 2500
  }
}
```

#### Rutas Públicas (No Requieren Autenticación)

**7. POST `/api/qr/redeem/:token`**
Canjea un código QR (Esta ruta es PÚBLICA para usuarios)

**Request Body:**
```json
{
  "correo_cliente": "cliente@example.com"
}
```

**Response Exitosa:**
```json
{
  "success": true,
  "message": "✅ ¡Código QR canjeado exitosamente!",
  "canje": {
    "puntos_aplicados": 100,
    "puntos_anteriores": 50,
    "puntos_nuevos": 150,
    "cliente": {
      "nombre": "Juan Pérez",
      "correo": "cliente@example.com"
    }
  }
}
```

**Response Error (QR ya usado):**
```json
{
  "success": false,
  "message": "❌ Este código QR ya fue canjeado o es inválido",
  "fecha_canje": "2025-10-30..."
}
```

## 🔐 Autenticación

El middleware `authMiddleware.js` verifica los tokens JWT:
- Extrae el token del header `Authorization: Bearer <token>`
- Verifica que sea válido
- Agrega `req.user` con la info del admin
- Protege las rutas de administración

## 📦 Dependencias Agregadas

En `backend/package.json`:
- `qrcode: ^1.5.3` - Genera imágenes QR
- `uuid: ^9.0.1` - Genera tokens únicos

## 🎨 Frontend (Angular)

### Modelos Creados

**`src/app/models/qr.model.ts`**
Contiene todas las interfaces TypeScript:
- `QRCode`
- `GenerateQRRequest`
- `GenerateQRResponse`
- `RedeemQRRequest`
- `RedeemQRResponse`
- `QRListResponse`
- `QRStatsResponse`
- `Cliente`

### Servicios Creados

**`src/app/services/qr.service.ts`**
Servicio Angular con métodos para:
- `generateQR()` - Generar QR
- `listQRCodes()` - Listar QRs
- `getQRDetails()` - Ver detalles
- `regenerateQR()` - Regenerar QR
- `redeemQR()` - Canjear QR
- `getRedemptionHistory()` - Ver historial
- `getQRStats()` - Ver estadísticas
- `downloadQRImage()` - Descargar imagen

## 🧪 Pruebas con cURL

### 1. Generar un QR (requiere autenticación)

```bash
# Primero hacer login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"correo": "admin@salon.com", "password": "admin123"}'

# Usar el token recibido
TOKEN="tu-token-aqui"

# Generar QR
curl -X POST http://localhost:3000/api/qr/generate \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "puntos": 100,
    "descripcion": "Bono de bienvenida",
    "uso_multiple": false,
    "dias_expiracion": 30
  }'
```

### 2. Listar QRs

```bash
curl -X GET "http://localhost:3000/api/qr/list?estado=valido" \
  -H "Authorization: Bearer $TOKEN"
```

### 3. Canjear un QR (NO requiere autenticación)

```bash
curl -X POST http://localhost:3000/api/qr/redeem/<token-del-qr> \
  -H "Content-Type: application/json" \
  -d '{"correo_cliente": "cliente@example.com"}'
```

### 4. Ver estadísticas

```bash
curl -X GET http://localhost:3000/api/qr/stats/summary \
  -H "Authorization: Bearer $TOKEN"
```

## 🔄 Flujo del Sistema

### Para ADMIN:

1. **Login** en el sistema (obtiene JWT token)
2. **Generar QR**:
   - Define puntos a otorgar
   - Opcionalmente: descripción, uso múltiple, expiración
   - Sistema genera token único y QR
3. **Ver panel de QRs**:
   - Lista todos los QRs
   - Ver estado: ✅ Válido / ❌ Inválido / ⏰ Expirado
   - Ver cuántas veces se usó
   - Ver quién lo canjeó
4. **Regenerar QR**:
   - Invalida el QR actual
   - Genera uno nuevo con los mismos parámetros
5. **Ver estadísticas y historial**

### Para USUARIO/CLIENTE:

1. **Escanea QR** o visita el link `http://localhost/canjear/<token>`
2. **Ingresa su correo**
3. **Sistema valida**:
   - ¿Existe el token?
   - ¿Está válido?
   - ¿No ha expirado?
4. **Si es válido**:
   - ✅ Suma/descuenta puntos
   - ✅ Invalida el QR (si no es de uso múltiple)
   - ✅ Registra en historial
   - ✅ Muestra mensaje de éxito
5. **Si NO es válido**:
   - ❌ Muestra error "QR ya canjeado"
   - ❌ Muestra fecha de canje si aplica

## 🎯 Características Especiales

### QR de Uso Múltiple
Si `uso_multiple = true`:
- El QR NO se invalida después del primer uso
- Se puede usar múltiples veces
- El contador `veces_usado` se incrementa
- Útil para promociones recurrentes

### QR con Expiración
Si se define `dias_expiracion`:
- El QR expira después de N días
- Al intentar canjear un QR expirado, se marca como 'expirado'
- No se pueden canjear QRs expirados

### Clientes Automáticos
Si un correo no existe:
- Se crea automáticamente un nuevo cliente
- Inicia con 0 puntos
- Se le aplican los puntos del QR

### Historial Completo
Cada canje registra:
- QR usado
- Cliente que canjeó
- Puntos aplicados
- Puntos antes y después
- Fecha y hora exacta

## 📝 Variables de Entorno

Agregar en `docker-compose.yml` o `.env`:

```env
FRONTEND_URL=http://localhost
JWT_SECRET=your-secret-key
```

## 🚀 Siguientes Pasos para Completar el Frontend

Faltarían crear estos componentes en Angular:

1. **Panel de Admin QR** (`/dashboard/qr` o `/admin/qr`)
   - Lista de QRs con filtros
   - Botón "Generar nuevo QR"
   - Modal con formulario de generación
   - Visualización del QR generado
   - Botón de descarga
   - Botón de regenerar

2. **Página de Canje** (`/canjear/:token`)
   - Formulario público con campo de correo
   - Validación del token
   - Mensajes de éxito/error
   - Visualización de puntos ganados

3. **Actualizar Dashboard**
   - Agregar estadísticas de QR
   - Widget con resumen

4. **Actualizar Navbar**
   - Link a gestión de QR (solo para admin)

## 🔍 Estado Actual

✅ Backend completo
✅ Base de datos configurada
✅ API endpoints funcionando
✅ Modelos y servicios de Angular creados
⏳ Componentes visuales del frontend (pendiente)

## 🐛 Debugging

Ver logs del backend:
```bash
docker-compose logs -f backend
```

Ver datos en la BD:
```bash
# Ver QRs
docker exec salon-postgres psql -U salon_user -d salon_beauty \
  -c "SELECT * FROM codigos_qr;"

# Ver clientes
docker exec salon-postgres psql -U salon_user -d salon_beauty \
  -c "SELECT * FROM clientes;"

# Ver historial
docker exec salon-postgres psql -U salon_user -d salon_beauty \
  -c "SELECT * FROM historial_canjes;"
```

## 🎨 Próximos Pasos Recomendados

1. Crear los componentes visuales en Angular
2. Agregar sección de QR en el dashboard
3. Crear página pública de canje
4. Probar flujo completo end-to-end
5. Agregar notificaciones/toasts para mejor UX
6. Considerar agregar analytics más detallados
