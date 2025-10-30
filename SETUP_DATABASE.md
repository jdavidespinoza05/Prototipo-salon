# Guía de Configuración - Sistema de Salón de Belleza

Esta guía te ayudará a configurar y ejecutar el sistema completo: Base de datos Oracle, Backend API y Frontend Angular.

## Arquitectura del Sistema

```
┌─────────────────┐
│  Angular App    │  Puerto 4200
│  (Frontend)     │
└────────┬────────┘
         │ /api/* → proxy
         ↓
┌─────────────────┐
│  Express API    │  Puerto 3000
│  (Backend)      │
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│  Oracle XE 21c  │  Puerto 1521
│  (Base de Datos)│
└─────────────────┘
```

## Requisitos Previos

Antes de comenzar, asegúrate de tener instalado:

- ✅ **Node.js 18+** - [Descargar](https://nodejs.org/)
- ✅ **Docker Desktop** - [Descargar](https://www.docker.com/products/docker-desktop/)
- ✅ **Git** - [Descargar](https://git-scm.com/)

## Paso 1: Configurar la Base de Datos Oracle

### 1.1 Iniciar Docker Desktop

Abre Docker Desktop y asegúrate de que esté corriendo.

### 1.2 Navegar a la carpeta de la base de datos

```bash
cd salon-beauty-app/database
```

### 1.3 Iniciar el contenedor de Oracle

```bash
docker-compose up -d
```

**IMPORTANTE**: Oracle tarda entre 2-5 minutos en inicializarse completamente la primera vez.

### 1.4 Verificar que Oracle está listo

Puedes ver los logs para verificar el progreso:

```bash
docker-compose logs -f oracle-db
```

Cuando veas el mensaje `DATABASE IS READY TO USE!`, presiona `Ctrl+C` para salir de los logs.

### 1.5 Verificar la conexión

Puedes usar SQL Developer, DBeaver o cualquier cliente SQL con estas credenciales:

```
Host: localhost
Port: 1521
Service Name: XEPDB1
Usuario: salon_user
Contraseña: salon_pass123
```

### 1.6 Verificar las tablas y procedimientos

Ejecuta estas consultas para verificar que todo se creó correctamente:

```sql
-- Ver todas las tablas
SELECT table_name FROM user_tables ORDER BY table_name;

-- Ver todos los procedimientos almacenados
SELECT object_name, object_type, status
FROM user_objects
WHERE object_type = 'PROCEDURE'
ORDER BY object_name;

-- Ver datos de prueba en administradores
SELECT id_admin, nombre, correo, activo FROM administradores;
```

Deberías ver:
- 8 tablas (administradores, clientes, servicios, productos, recompensas, etc.)
- 3 procedimientos (sp_login_admin, sp_update_ultimo_acceso, sp_get_admin_info)
- 2 administradores de prueba

## Paso 2: Configurar e Iniciar el Backend

### 2.1 Instalar dependencias del backend

```bash
cd ../backend
npm install
```

### 2.2 Verificar el archivo .env

El archivo `.env` ya está configurado con los valores correctos:

```env
DB_USER=salon_user
DB_PASSWORD=salon_pass123
DB_CONNECTION_STRING=localhost:1521/XEPDB1
PORT=3000
JWT_SECRET=salon_belleza_secret_key_2024_cambiar_en_produccion
NODE_ENV=development
```

### 2.3 Iniciar el servidor backend

```bash
npm start
```

Deberías ver algo como:

```
✓ Pool de conexiones Oracle creado exitosamente
✓ Servidor ejecutándose en http://localhost:3000
✓ Ambiente: development
✓ Conectando a Oracle: localhost:1521/XEPDB1
```

Si ves errores de conexión, espera un poco más a que Oracle termine de inicializarse.

### 2.4 Probar el endpoint de health check

Abre tu navegador y ve a: `http://localhost:3000/health`

Deberías ver:
```json
{
  "status": "ok",
  "timestamp": "2024-01-15T10:30:00.000Z",
  "environment": "development"
}
```

## Paso 3: Iniciar el Frontend Angular

### 3.1 Instalar dependencias de Angular

En una **nueva terminal**, navega a la carpeta del proyecto Angular:

```bash
cd salon-beauty-app
npm install
```

### 3.2 Iniciar el servidor de desarrollo

```bash
npm start
```

### 3.3 Abrir la aplicación

El servidor de Angular se ejecutará en `http://localhost:4200`

Abre tu navegador y ve a: `http://localhost:4200`

## Paso 4: Probar el Sistema

### 4.1 Ir a la página de login

La aplicación debería redirigirte automáticamente a `/login`.

### 4.2 Iniciar sesión con credenciales de prueba

Usa una de estas credenciales:

**Administrador 1:**
- Email: `maria.gonzalez@salon.com`
- Password: `admin123`

**Administrador 2:**
- Email: `carlos.rodriguez@salon.com`
- Password: `admin123`

### 4.3 Verificar que funciona

Si todo está configurado correctamente:
1. El login debería ser exitoso
2. Serás redirigido al dashboard
3. Deberías ver tu nombre en la interfaz

## Resumen de Puertos

| Servicio | Puerto | URL |
|----------|--------|-----|
| Angular Frontend | 4200 | http://localhost:4200 |
| Express Backend | 3000 | http://localhost:3000 |
| Oracle Database | 1521 | localhost:1521/XEPDB1 |

## Comandos Útiles

### Base de Datos

```bash
# Iniciar Oracle
cd database && docker-compose up -d

# Ver logs de Oracle
docker-compose logs -f oracle-db

# Detener Oracle
docker-compose down

# Detener y eliminar datos (⚠️ cuidado, esto borra todo)
docker-compose down -v
```

### Backend

```bash
cd backend

# Modo desarrollo (con auto-reload)
npm run dev

# Modo producción
npm start
```

### Frontend

```bash
cd salon-beauty-app

# Desarrollo
npm start

# Build para producción
npm run build
```

## Solución de Problemas Comunes

### ❌ Error: Cannot connect to Oracle

**Solución**: Oracle aún no está listo. Espera 2-5 minutos más y reinicia el backend.

```bash
# Ver logs de Oracle para verificar el estado
cd database
docker-compose logs -f oracle-db
```

### ❌ Error: Puerto 1521/3000/4200 ya en uso

**Solución**: Otro proceso está usando ese puerto.

```bash
# Windows - Ver qué proceso usa el puerto
netstat -ano | findstr :3000

# Detener el proceso (reemplaza PID con el número que viste)
taskkill /PID <numero> /F
```

### ❌ Error: CORS en el navegador

**Solución**: Asegúrate de que el backend esté corriendo antes que el frontend.

1. Detén Angular (`Ctrl+C`)
2. Inicia primero el backend
3. Luego inicia Angular

### ❌ Login falla con credenciales correctas

**Solución**: Verifica que la tabla de administradores tenga datos:

```sql
-- Conectarse a Oracle y ejecutar:
SELECT * FROM administradores;
```

Si no hay datos, ejecuta el script de datos iniciales:

```bash
cd database/init
# Ejecutar 04_insert_data.sql desde tu cliente SQL
```

## Cambios Realizados

Esta configuración incluye las siguientes mejoras:

### Base de Datos
- ✅ Actualizado de Oracle XE 11g R2 a **Oracle XE 21c** (versión moderna)
- ✅ Imagen Docker: `gvenzl/oracle-xe:21-slim` (optimizada y mantenida)
- ✅ Configuración simplificada con variables de entorno

### Backend (NUEVO)
- ✅ API REST con Express.js
- ✅ Conexión a Oracle con `oracledb`
- ✅ Endpoint de autenticación que usa el procedimiento almacenado `sp_login_admin`
- ✅ Generación de tokens JWT para sesiones
- ✅ Pool de conexiones optimizado

### Frontend
- ✅ Proxy configurado para redirigir `/api` al backend
- ✅ Servicio de autenticación actualizado para usar el backend real
- ✅ `DEV_MODE = false` (ya no usa mock, usa la BD real)

## Estructura del Proyecto

```
Prototipo-salon/
├── salon-beauty-app/           # Proyecto Angular
│   ├── src/                    # Código fuente Angular
│   │   ├── app/
│   │   │   ├── pages/login/   # Componente de login
│   │   │   └── services/      # Servicio de autenticación
│   │   └── ...
│   ├── backend/               # API Backend (NUEVO)
│   │   ├── config/            # Configuración de BD
│   │   ├── controllers/       # Controladores
│   │   ├── routes/            # Rutas API
│   │   ├── .env               # Variables de entorno
│   │   ├── package.json
│   │   └── server.js          # Servidor Express
│   ├── database/              # Configuración de BD
│   │   ├── docker-compose.yml # Contenedor Oracle (ACTUALIZADO)
│   │   └── init/              # Scripts SQL
│   ├── proxy.conf.json        # Proxy Angular → Backend
│   └── package.json
└── SETUP_DATABASE.md          # Esta guía
```

## Próximos Pasos

Una vez que todo funcione correctamente, puedes:

1. 📊 Explorar los datos de prueba (clientes, servicios, productos)
2. 🎨 Personalizar la interfaz del dashboard
3. 🔐 Implementar más endpoints en el backend
4. 📱 Agregar más funcionalidades (CRUD de clientes, canjes, etc.)

## Soporte

Si encuentras problemas no listados aquí, verifica:
- Los logs de Oracle: `docker-compose logs -f oracle-db`
- Los logs del backend: En la terminal donde ejecutaste `npm start`
- La consola del navegador (F12) para errores de Angular

---

¡Listo! Ahora tienes un sistema completo con base de datos Oracle, backend API y frontend Angular funcionando en conjunto.
