# Backend - Salón de Belleza API

Backend desarrollado con Node.js, Express y Oracle Database para el sistema de fidelidad del salón de belleza.

## Requisitos Previos

- Node.js 18+ instalado
- Docker y Docker Compose instalados
- Oracle Instant Client (opcional, solo si usas modo thick)

## Instalación

### 1. Instalar dependencias

```bash
cd backend
npm install
```

### 2. Configurar variables de entorno

El archivo `.env` ya está configurado con los valores por defecto:

```env
DB_USER=salon_user
DB_PASSWORD=salon_pass123
DB_CONNECTION_STRING=localhost:1521/XEPDB1
PORT=3000
JWT_SECRET=salon_belleza_secret_key_2024_cambiar_en_produccion
NODE_ENV=development
```

**IMPORTANTE**: En producción, cambia el `JWT_SECRET` por uno seguro y único.

### 3. Iniciar la base de datos Oracle

Desde la carpeta `database/`:

```bash
cd ../database
docker-compose up -d
```

Espera unos 2-3 minutos para que Oracle se inicie completamente. Puedes verificar los logs con:

```bash
docker-compose logs -f oracle-db
```

### 4. Verificar que las tablas y procedimientos se crearon

Conéctate a Oracle con SQL*Plus o SQL Developer:

```bash
# Credenciales
Host: localhost
Port: 1521
Service Name: XEPDB1
Usuario: salon_user
Contraseña: salon_pass123
```

Verifica que existan las tablas:
```sql
SELECT table_name FROM user_tables;
```

Verifica que existan los procedimientos:
```sql
SELECT object_name FROM user_objects WHERE object_type = 'PROCEDURE';
```

### 5. Iniciar el servidor backend

```bash
cd ../backend
npm start
```

Para desarrollo con auto-reload:
```bash
npm run dev
```

El servidor se ejecutará en `http://localhost:3000`

## Endpoints Disponibles

### Health Check
- **GET** `/health` - Verificar estado del servidor

### Autenticación
- **POST** `/api/auth/login` - Login de administrador
  ```json
  {
    "correo": "maria.gonzalez@salon.com",
    "password": "admin123"
  }
  ```

- **POST** `/api/auth/verify-token` - Verificar token JWT
  ```
  Headers: Authorization: Bearer <token>
  ```

- **POST** `/api/auth/update-access` - Actualizar último acceso
  ```json
  {
    "adminId": 1
  }
  ```

## Credenciales de Prueba

Los datos iniciales incluyen dos administradores:

1. **María González**
   - Email: `maria.gonzalez@salon.com`
   - Password: `admin123`

2. **Carlos Rodríguez**
   - Email: `carlos.rodriguez@salon.com`
   - Password: `admin123`

## Solución de Problemas

### Error: ORA-12541: TNS:no listener

La base de datos Oracle no está lista. Espera unos minutos y reinicia el backend.

### Error: NJS-045: cannot load the oracledb add-on

Si usas Windows, es posible que necesites instalar Oracle Instant Client:
1. Descarga Oracle Instant Client desde: https://www.oracle.com/database/technologies/instant-client/downloads.html
2. Extrae los archivos en una carpeta (ej: `C:\oracle\instantclient_21_12`)
3. Descomenta la línea en `config/db.js`:
   ```javascript
   oracledb.initOracleClient({ libDir: 'C:\\oracle\\instantclient_21_12' });
   ```

### Error de conexión

Verifica que:
1. El contenedor de Oracle esté corriendo: `docker ps`
2. El puerto 1521 esté disponible
3. Las credenciales en `.env` sean correctas

## Estructura del Proyecto

```
backend/
├── config/
│   └── db.js                 # Configuración de Oracle DB
├── controllers/
│   └── authController.js     # Controlador de autenticación
├── routes/
│   └── auth.js              # Rutas de autenticación
├── .env                     # Variables de entorno
├── .gitignore               # Archivos ignorados por git
├── package.json             # Dependencias del proyecto
├── README.md                # Este archivo
└── server.js                # Punto de entrada del servidor
```

## Próximos Pasos

Para conectar el frontend Angular:

1. El proxy ya está configurado en `proxy.conf.json` para redirigir `/api` a `http://localhost:3000`
2. Inicia el backend primero: `npm start`
3. Luego inicia Angular desde la carpeta raíz: `npm start`
4. Angular se ejecutará en `http://localhost:4200`

## Licencia

Este proyecto es parte del sistema de fidelidad del Salón de Belleza.
