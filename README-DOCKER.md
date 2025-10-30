# Sistema de Salón de Belleza - Dockerizado

Este proyecto está completamente dockerizado y usa PostgreSQL como base de datos.

## Requisitos Previos

- Docker Desktop instalado
- Docker Compose instalado

## Inicio Rápido

Para iniciar todo el proyecto (base de datos, backend y frontend), ejecuta:

```bash
docker-compose up -d
```

Este comando iniciará:
- PostgreSQL en el puerto 5432
- Backend API en el puerto 3000
- Frontend en el puerto 80

## Acceso a la Aplicación

Una vez que los contenedores estén corriendo, puedes acceder a:

- **Frontend**: http://localhost
- **Backend API**: http://localhost:3000
- **PostgreSQL**: localhost:5432

## Credenciales de Login

Usuarios predeterminados:

1. **Admin Principal**
   - Correo: admin@salon.com
   - Contraseña: admin123

2. **María González**
   - Correo: maria.gonzalez@salon.com
   - Contraseña: admin123

3. **Carlos Rodríguez**
   - Correo: carlos.rodriguez@salon.com
   - Contraseña: admin123

## Comandos Útiles

### Ver el estado de los contenedores
```bash
docker-compose ps
```

### Ver logs de todos los servicios
```bash
docker-compose logs -f
```

### Ver logs de un servicio específico
```bash
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f postgres
```

### Detener todos los contenedores
```bash
docker-compose down
```

### Detener y eliminar volúmenes (CUIDADO: elimina los datos de la BD)
```bash
docker-compose down -v
```

### Reconstruir las imágenes
```bash
docker-compose build --no-cache
```

### Reiniciar un servicio específico
```bash
docker-compose restart backend
```

## Estructura del Proyecto

```
Prototipo-salon/
├── docker-compose.yml              # Orquestación de todos los servicios
└── salon-beauty-app/
    ├── Dockerfile                  # Dockerfile del frontend
    ├── nginx.conf                  # Configuración de Nginx
    ├── backend/
    │   ├── Dockerfile              # Dockerfile del backend
    │   ├── .env.example            # Variables de entorno de ejemplo
    │   └── ...
    └── database/
        └── postgres-init/          # Scripts de inicialización de PostgreSQL
            ├── 01_init.sql
            ├── 02_create_tables.sql
            └── 03_insert_data.sql
```

## Resolución de Problemas

### El backend no puede conectarse a la base de datos

Verifica que PostgreSQL esté completamente iniciado:
```bash
docker-compose logs postgres
```

### La base de datos no se inicializa correctamente

Elimina los volúmenes y vuelve a crear:
```bash
docker-compose down -v
docker-compose up -d
```

### Errores de compilación en el frontend

Reconstruye la imagen sin caché:
```bash
docker-compose build --no-cache frontend
docker-compose up -d
```

## Desarrollo

Si necesitas hacer cambios en el código:

1. Edita los archivos localmente
2. Reconstruye el servicio:
   ```bash
   docker-compose build backend
   # o
   docker-compose build frontend
   ```
3. Reinicia el servicio:
   ```bash
   docker-compose up -d
   ```

## Migración desde Oracle a PostgreSQL

Este proyecto fue migrado de Oracle Database a PostgreSQL. Los cambios principales incluyen:

- Reemplazo de `oracledb` por `pg` (node-postgres)
- Cambio de sintaxis SQL de Oracle a PostgreSQL
- Uso de `$1, $2, ...` en lugar de `:param` para parámetros
- Uso de `SERIAL` en lugar de `SEQUENCE` para IDs autoincrementales
- Uso de `CURRENT_TIMESTAMP` en lugar de `SYSDATE`

## Variables de Entorno

Las variables de entorno se configuran en el `docker-compose.yml`. Si necesitas cambiarlas:

1. Edita el archivo `docker-compose.yml`
2. Recrea los contenedores:
   ```bash
   docker-compose down
   docker-compose up -d
   ```

## Seguridad

**IMPORTANTE**: En producción, cambia:
- Las contraseñas de la base de datos
- El JWT_SECRET
- Las contraseñas de los administradores
