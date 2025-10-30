# Sistema de Salón de Belleza - Dockerizado con PostgreSQL

## Inicio Rápido

Para iniciar todo el proyecto, simplemente ejecuta:

```bash
docker-compose up -d
```

Esto iniciará automáticamente:
- **PostgreSQL** en el puerto 5432
- **Backend API** en el puerto 3000
- **Frontend** en el puerto 80

## Acceso a la Aplicación

Una vez que los contenedores estén corriendo:

- **Frontend**: http://localhost
- **Backend API**: http://localhost:3000
- **Health Check**: http://localhost:3000/health

## Credenciales de Prueba

El sistema incluye 3 usuarios administradores de prueba. Todos tienen la contraseña: **admin123**

1. **Administrador Principal**
   - Correo: admin@salon.com
   - Contraseña: admin123

2. **María González**
   - Correo: maria.gonzalez@salon.com
   - Contraseña: admin123

3. **Carlos Rodríguez**
   - Correo: carlos.rodriguez@salon.com
   - Contraseña: admin123

## Comandos Útiles

### Ver estado de los contenedores
```bash
docker-compose ps
```

### Ver logs en tiempo real
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

### Detener y eliminar datos (incluyendo la base de datos)
```bash
docker-compose down -v
```

### Reconstruir las imágenes
```bash
docker-compose build --no-cache
docker-compose up -d
```

### Reiniciar un servicio específico
```bash
docker-compose restart backend
```

## Estructura del Proyecto

```
Prototipo-salon/
├── docker-compose.yml                    # Orquestación de servicios
├── README-DOCKER.md                      # Documentación detallada
└── salon-beauty-app/
    ├── Dockerfile                        # Frontend Docker
    ├── nginx.conf                        # Configuración Nginx
    ├── backend/
    │   ├── Dockerfile                    # Backend Docker
    │   ├── .dockerignore
    │   ├── .env.example
    │   └── ...
    └── database/
        └── postgres-init/                # Scripts de inicialización
            ├── 01_init.sql
            ├── 02_create_tables.sql
            └── 03_insert_data.sql
```

## Tecnologías

- **Frontend**: Angular 19 + Nginx
- **Backend**: Node.js 18 + Express
- **Base de Datos**: PostgreSQL 15
- **Contenedores**: Docker + Docker Compose

## Migración de Oracle a PostgreSQL

Este proyecto fue migrado de Oracle Database a PostgreSQL. Los cambios principales incluyen:

- ✅ Reemplazo de `oracledb` por `pg` (node-postgres)
- ✅ Adaptación de sintaxis SQL de Oracle a PostgreSQL
- ✅ Uso de parámetros `$1, $2` en lugar de `:param`
- ✅ Uso de `SERIAL` en lugar de `SEQUENCE` para IDs
- ✅ Uso de `CURRENT_TIMESTAMP` en lugar de `SYSDATE`
- ✅ Sistema de login funcionando correctamente

## Resolución de Problemas

### El backend no puede conectarse a la base de datos

Espera unos segundos más y verifica el estado:
```bash
docker-compose logs postgres
```

### Error de puerto ya en uso

Si el puerto 3000 u 80 ya está ocupado:
```bash
# Windows - Detener proceso en puerto 3000
powershell -Command "Stop-Process -Id (Get-NetTCPConnection -LocalPort 3000).OwningProcess -Force"

# Luego reinicia los contenedores
docker-compose down
docker-compose up -d
```

### La base de datos no tiene datos

Elimina los volúmenes y recrea todo:
```bash
docker-compose down -v
docker-compose up -d
```

## Variables de Entorno

Las variables de entorno están configuradas en `docker-compose.yml`:

- `NODE_ENV`: production
- `PORT`: 3000
- `DB_HOST`: postgres
- `DB_PORT`: 5432
- `DB_NAME`: salon_beauty
- `DB_USER`: salon_user
- `DB_PASSWORD`: salon_pass123
- `JWT_SECRET`: your-super-secret-jwt-key-change-this-in-production

**⚠️ IMPORTANTE**: En producción, cambia las contraseñas y el JWT_SECRET.

## Seguridad

Para usar en producción:

1. Cambia las contraseñas de la base de datos en `docker-compose.yml`
2. Cambia el `JWT_SECRET` en `docker-compose.yml`
3. Actualiza las contraseñas de los administradores en la base de datos
4. Configura HTTPS con certificados SSL
5. Configura firewalls y restricciones de red adecuadas

## Soporte

Si encuentras algún problema:

1. Revisa los logs: `docker-compose logs -f`
2. Verifica que Docker Desktop esté corriendo
3. Verifica que los puertos 80, 3000 y 5432 estén disponibles
4. Intenta reconstruir: `docker-compose build --no-cache && docker-compose up -d`
