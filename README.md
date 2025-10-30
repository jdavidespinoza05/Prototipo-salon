# 💇 Sistema de Salón de Belleza - Programa de Fidelidad

Sistema completo de gestión y fidelización de clientes para salones de belleza, desarrollado con Angular, Node.js/Express y Oracle Database.

## 🚀 Inicio Rápido

### Opción 1: Script Automático (Recomendado)

```powershell
# Iniciar todo el sistema
.\start-system.ps1

# Detener todo el sistema
.\stop-system.ps1
```

### Opción 2: Manual

Ver la [Guía de Configuración Completa](SETUP_DATABASE.md) para instrucciones detalladas.

## 📋 Requisitos

- Node.js 18+
- Docker Desktop
- Git

## 🏗️ Arquitectura

```
┌─────────────────┐
│  Angular App    │  ← Frontend (Puerto 4200)
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│  Express API    │  ← Backend (Puerto 3000)
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│  Oracle XE 21c  │  ← Base de Datos (Puerto 1521)
└─────────────────┘
```

## 🔑 Credenciales de Prueba

**Administradores:**
- Email: `maria.gonzalez@salon.com` | Password: `admin123`
- Email: `carlos.rodriguez@salon.com` | Password: `admin123`

## 📦 Estructura del Proyecto

```
Prototipo-salon/
├── salon-beauty-app/
│   ├── src/                    # Frontend Angular
│   ├── backend/                # Backend API
│   │   ├── config/            # Configuración BD
│   │   ├── controllers/       # Lógica de negocio
│   │   ├── routes/            # Rutas API
│   │   └── server.js          # Servidor Express
│   └── database/              # Base de datos
│       ├── docker-compose.yml # Contenedor Oracle
│       └── init/              # Scripts SQL
├── start-system.ps1           # Script de inicio
├── stop-system.ps1            # Script de detención
├── SETUP_DATABASE.md          # Guía completa
└── README.md                  # Este archivo
```

## 🌟 Características

- ✅ Autenticación con JWT
- ✅ Gestión de clientes y puntos de fidelidad
- ✅ Sistema de recompensas
- ✅ Catálogo de servicios y productos
- ✅ Gestión de testimonios
- ✅ Dashboard administrativo
- ✅ Base de datos Oracle 21c moderna

## 🔧 Tecnologías

**Frontend:**
- Angular 19
- TypeScript
- RxJS
- Font Awesome

**Backend:**
- Node.js
- Express.js
- Oracle Database Driver (oracledb)
- JWT
- Bcrypt

**Base de Datos:**
- Oracle Database XE 21c
- Procedimientos almacenados PL/SQL
- Docker

## 📖 Documentación

- [Guía de Configuración Completa](SETUP_DATABASE.md) - Instrucciones paso a paso
- [Backend API](salon-beauty-app/backend/README.md) - Documentación de la API
- Scripts de base de datos en `salon-beauty-app/database/init/`

## 🐛 Solución de Problemas

### Error: Cannot connect to Oracle
- Espera 2-5 minutos después de iniciar Docker
- Verifica logs: `cd salon-beauty-app/database && docker-compose logs -f oracle-db`

### Error: Puerto en uso
```powershell
# Ver qué proceso usa el puerto
netstat -ano | findstr :3000

# Detener el proceso
taskkill /PID <numero> /F
```

### Login falla
- Asegúrate de que el backend esté corriendo
- Verifica la conexión a Oracle
- Revisa los logs del backend

## 📝 Cambios Recientes

### v1.1 - Integración con Base de Datos Real
- ✅ Actualizado Docker image de Oracle XE 11g → 21c
- ✅ Creado backend API con Express.js
- ✅ Implementado endpoint de autenticación con Oracle
- ✅ Configurado proxy Angular → Backend
- ✅ Actualizado servicio de autenticación para usar BD real
- ✅ Agregados scripts de inicio/detención automáticos

## 🚦 URLs del Sistema

| Servicio | URL | Descripción |
|----------|-----|-------------|
| Frontend | http://localhost:4200 | Aplicación Angular |
| Backend API | http://localhost:3000 | API REST |
| Health Check | http://localhost:3000/health | Estado del servidor |
| Oracle DB | localhost:1521/XEPDB1 | Base de datos |

## 🤝 Contribuir

Este proyecto es parte del curso de Requisitos de Software.

## 📄 Licencia

Este proyecto es para uso académico.

---

**¿Necesitas ayuda?** Consulta el archivo [SETUP_DATABASE.md](SETUP_DATABASE.md) para instrucciones detalladas.
