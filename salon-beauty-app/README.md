# 💅 Salon Beauty App - Sistema de Fidelización

Sistema web completo para gestión de salón de belleza con programa de puntos y recompensas.

---

## 📋 Descripción del Proyecto

Sistema integral que permite:
- ✅ **Frontend Angular** conectado directamente a procedimientos almacenados de Oracle
- ✅ Gestión de clientes con códigos QR únicos
- ✅ Sistema de puntos por servicios y productos
- ✅ Canje de recompensas
- ✅ Administración de servicios, productos y testimonios
- ✅ Panel administrativo completo
- ✅ Base de datos Oracle 11g en Docker con lógica de negocio en PL/SQL

---

## 🛠️ Tecnologías Utilizadas

### Frontend
- **Angular 19.2.0** - Framework web (frontend único)
- **TypeScript 5.7.2** - Lenguaje de programación
- **RxJS 7.8** - Programación reactiva
- **Zone.js 0.15** - Detección de cambios
- **HttpClient** - Comunicación con servicios REST

### Base de Datos
- **Oracle 11g Express Edition** - Base de datos relacional
- **Docker** - Contenedores para Oracle
- **wnameless/oracle-xe-11g-r2** - Imagen Docker oficial

---

## 📁 Estructura del Proyecto

```
salon-beauty-app/
├── src/                          # Código fuente Angular
│   ├── app/                      # Componentes de la aplicación
│   │   ├── components/           # Componentes reutilizables
│   │   ├── pages/                # Páginas principales
│   │   ├── services/             # Servicios Angular (API calls)
│   │   ├── models/               # Modelos de datos
│   │   ├── guards/               # Guards de rutas
│   │   └── interceptors/         # HTTP Interceptors
│   ├── assets/                   # Recursos estáticos
│   └── environments/             # Configuraciones de entorno
│
├── database/                     # Configuración de base de datos
│   ├── init/                     # Scripts SQL de inicialización
│   │   ├── 01_create_user.sql
│   │   ├── 02_create_tables.sql
│   │   ├── 03_create_triggers.sql
│   │   └── 04_insert_data.sql
│   ├── backups/                  # Backups de la base de datos
│   ├── logs/                     # Logs del sistema
│   ├── docker-compose.yml        # Configuración Docker
│   ├── .env                      # Variables de entorno (NO commitear)
│   ├── .env.example              # Plantilla de variables
│   ├── start.sh                  # Script de inicio automático
│   └── init_db.sh                # Script de gestión DB
│
├── angular.json                  # Configuración Angular
├── package.json                  # Dependencias Node.js
├── tsconfig.json                 # Configuración TypeScript
└── README.md                     # Este archivo
```

---

## 🚀 Instalación y Configuración

### Requisitos Previos

- **Node.js 22.21.0** o superior (solo para Angular CLI y herramientas de desarrollo)
- **npm 10.9.4** o superior
- **Docker Desktop** instalado y corriendo
- **Git** para control de versiones

**Nota:** Node.js se usa únicamente para las herramientas de desarrollo de Angular, NO para un backend.

### 1️⃣ Clonar el Repositorio

```bash
git clone https://github.com/tu-usuario/Prototipo-salon.git
cd Prototipo-salon/salon-beauty-app
```

### 2️⃣ Instalar Angular CLI

```bash
npm install -g @angular/cli@19.2.0
```

### 3️⃣ Instalar Dependencias del Frontend

```bash
npm install
```

### 4️⃣ Configurar Base de Datos

```bash
# Ir a la carpeta database
cd database

# Crear archivo .env desde el ejemplo
cp .env.example .env
# En Windows: copy .env.example .env

# Crear carpetas necesarias
mkdir backups logs
echo "." > backups/.gitkeep
echo "." > logs/.gitkeep
```

### 5️⃣ Iniciar Oracle Database

```bash
# Levantar contenedor Docker
docker-compose up -d

# Ver logs (esperar 5-10 minutos)
docker logs oracle-salon-belleza -f
# Presionar Ctrl+C cuando veas que Oracle está listo
```

### 6️⃣ Verificar Base de Datos

```bash
# Conectarse a Oracle
docker exec -it oracle-salon-belleza sqlplus salon_user/salon_pass123@XE

# Probar consultas
SELECT COUNT(*) FROM clientes;
-- Debería mostrar: 5

exit
```

---

## 🏗️ Arquitectura del Sistema

### Flujo de Datos

```
┌─────────────────────────────────────────────────────────────┐
│                    NAVEGADOR (Cliente)                      │
│                                                             │
│  ┌───────────────────────────────────────────────────┐    │
│  │          Angular 19 (Frontend SPA)                │    │
│  │  - Componentes                                    │    │
│  │  - Servicios (HttpClient)                         │    │
│  │  - Guards & Interceptors                          │    │
│  └───────────────┬───────────────────────────────────┘    │
│                  │                                          │
└──────────────────┼──────────────────────────────────────────┘
                   │ HTTP/REST
                   ▼
┌──────────────────────────────────────────────────────────────┐
│         Middleware/API Gateway (Opcional)                    │
│  - ORDS (Oracle REST Data Services)                          │
│  - o Express.js mínimo como proxy                            │
└───────────────┬──────────────────────────────────────────────┘
                │
                ▼
┌──────────────────────────────────────────────────────────────┐
│               Oracle Database 11g XE                         │
│  ┌────────────────────────────────────────────────┐         │
│  │  Procedimientos Almacenados (PL/SQL)           │         │
│  │  - sp_agregar_puntos                           │         │
│  │  - sp_canjear_recompensa                       │         │
│  │  - Triggers automáticos                        │         │
│  │  - Lógica de negocio                           │         │
│  └────────────────────────────────────────────────┘         │
│  ┌────────────────────────────────────────────────┐         │
│  │  Tablas                                        │         │
│  │  - clientes, servicios, productos              │         │
│  │  - recompensas, transacciones_puntos           │         │
│  └────────────────────────────────────────────────┘         │
└──────────────────────────────────────────────────────────────┘
```

### Opciones de Conexión

**Opción 1: ORDS (Oracle REST Data Services)** - Recomendado
- Oracle expone procedimientos como endpoints REST
- Sin código backend adicional
- Configuración directa en Oracle

**Opción 2: Middleware Mínimo (Express.js)**
- Capa delgada que traduce HTTP → llamadas Oracle
- Útil para autenticación JWT
- Control adicional de seguridad

---

## 💻 Desarrollo

### Iniciar Servidor de Desarrollo (Angular)

```bash
# Desde la raíz del proyecto (salon-beauty-app/)
npm start

# O también:
ng serve
```

Navegar a: **http://localhost:4200/**

La aplicación se recargará automáticamente al modificar archivos.

### Iniciar Servidor de Desarrollo (Con puerto específico)

```bash
ng serve --port 4201
```

### Abrir automáticamente en navegador

```bash
ng serve --open
```

---

## 🗄️ Base de Datos

### Estructura de Tablas

- **administradores** - Usuarios administrativos
- **clientes** - Clientes con sistema de puntos
- **servicios** - Catálogo de servicios
- **productos** - Productos disponibles
- **recompensas** - Recompensas canjeables
- **transacciones_puntos** - Historial de puntos
- **canjes_recompensas** - Historial de canjes
- **testimonios** - Reseñas de clientes

### Datos de Ejemplo

Al inicializar la base de datos se crean:
- ✅ 2 administradores
- ✅ 5 clientes con puntos
- ✅ 10 servicios
- ✅ 10 productos
- ✅ 10 recompensas
- ✅ 7 testimonios

### Credenciales de Acceso

**Conexión a Oracle:**
- **Host:** localhost
- **Puerto:** 1521
- **SID:** XE
- **Usuario:** salon_user
- **Contraseña:** salon_pass123

**Usuario SYSTEM (admin):**
- **Usuario:** system
- **Contraseña:** oracle

### Comandos Útiles de Base de Datos

```bash
# Conectarse a Oracle
docker exec -it oracle-salon-belleza sqlplus salon_user/salon_pass123@XE

# Ver estado del contenedor
docker ps

# Ver logs
docker logs oracle-salon-belleza -f

# Detener base de datos
docker-compose down

# Reiniciar base de datos
docker-compose restart

# Eliminar todo (CUIDADO: borra datos)
docker-compose down -v
```

---

## 🏗️ Scaffolding de Código

### Generar Componente

```bash
ng generate component components/nombre-componente
```

### Generar Servicio

```bash
ng generate service services/nombre-servicio
```

### Generar Módulo

```bash
ng generate module modules/nombre-modulo --routing
```

### Ver ayuda de generadores

```bash
ng generate --help
```

---

## 🔨 Build

### Build de Desarrollo

```bash
ng build
```

### Build de Producción

```bash
ng build --configuration production
```

Los archivos compilados se guardan en: `dist/`

---

## 🧪 Testing

### Ejecutar Tests Unitarios

```bash
ng test
```

Utiliza [Karma](https://karma-runner.github.io) como test runner.

### Ejecutar Tests E2E

Angular CLI no incluye framework E2E por defecto. Puedes elegir uno:
- **Cypress** (Recomendado)
- **Protractor** (Deprecado)
- **Playwright**

---

## 📦 Scripts Disponibles

```bash
npm start          # Iniciar servidor de desarrollo
npm run build      # Compilar para producción
npm test           # Ejecutar tests
npm run watch      # Build con recarga automática
```

---

## 🐳 Docker

### Comandos Docker Útiles

```bash
# Ver contenedores corriendo
docker ps

# Ver todos los contenedores
docker ps -a

# Ver logs del contenedor
docker logs oracle-salon-belleza -f

# Ejecutar comando en contenedor
docker exec -it oracle-salon-belleza bash

# Ver uso de recursos
docker stats oracle-salon-belleza

# Detener todos los contenedores
docker-compose down

# Reconstruir contenedores
docker-compose up -d --build
```

---

## 🔧 Troubleshooting

### Puerto 4200 Ocupado

```bash
# Windows PowerShell
Get-Process -Id (Get-NetTCPConnection -LocalPort 4200).OwningProcess | Stop-Process -Force

# O usar otro puerto:
ng serve --port 4201
```

### Puerto 1521 Ocupado (Oracle)

```bash
# Cambiar puerto en docker-compose.yml
ports:
  - "1522:1521"  # Usar 1522 externamente
```

### Oracle No Inicia

```bash
# Ver logs detallados
docker logs oracle-salon-belleza --tail 100

# Reiniciar completamente
docker-compose down -v
docker-compose up -d
```

### Error: "Module not found"

```bash
# Reinstalar dependencias
rm -rf node_modules package-lock.json
npm install
```

### Error: Ejecutar scripts deshabilitado (Windows)

```powershell
# Habilitar ejecución de scripts (PowerShell como Admin)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# O usar CMD en lugar de PowerShell
```

---

## 🔐 Seguridad

### Variables de Entorno

**⚠️ IMPORTANTE:** El archivo `.env` contiene credenciales y **NO debe commitearse**.

```bash
# Verificar que .env está en .gitignore
cat .gitignore | grep .env
```

### Contraseñas

En producción:
- ✅ Cambiar contraseñas por defecto
- ✅ Usar variables de entorno
- ✅ Implementar autenticación JWT
- ✅ Hashear contraseñas con bcrypt

---

## 📚 Recursos Adicionales

### Documentación Oficial

- [Angular](https://angular.dev)
- [Angular CLI](https://angular.dev/tools/cli)
- [TypeScript](https://www.typescriptlang.org)
- [Oracle Database](https://docs.oracle.com/en/database/)
- [Oracle ORDS](https://www.oracle.com/database/technologies/appdev/rest.html)
- [Docker](https://docs.docker.com)
- [PL/SQL](https://docs.oracle.com/en/database/oracle/oracle-database/21/lnpls/)

### Tutoriales Útiles

- [Angular Tour of Heroes](https://angular.dev/tutorials/tour-of-heroes)
- [Oracle ORDS Getting Started](https://www.oracle.com/webfolder/technetwork/tutorials/obe/db/ords/r30/Getting_Started_with_ORDS_3.0/Getting_Started_with_ORDS_3.0.html)
- [PL/SQL Best Practices](https://oracle-base.com/articles/misc/plsql-best-practices)

---

## 🗺️ Roadmap

### ✅ Completado
- [x] Configuración inicial de Angular 19
- [x] Base de datos Oracle 11g en Docker
- [x] Scripts SQL con triggers y procedimientos almacenados
- [x] Datos de ejemplo cargados
- [x] Lógica de negocio en PL/SQL (triggers, procedimientos)

### 🚧 En Desarrollo
- [ ] Componentes Angular del frontend
- [ ] Servicios Angular para llamar procedimientos Oracle
- [ ] Autenticación y autorización
- [ ] Módulo de clientes
- [ ] Módulo de servicios y productos
- [ ] Sistema de puntos y recompensas
- [ ] Conexión Angular → Oracle vía HTTP/REST (API Gateway o middleware ligero)

### 📋 Planeado
- [ ] Dashboard administrativo
- [ ] Generación de reportes
- [ ] Notificaciones por correo
- [ ] Integración con pagos
- [ ] PWA (Progressive Web App)
- [ ] App móvil (futuro)

---

## 👥 Contribución

### Cómo Contribuir

1. Fork del repositorio
2. Crear rama: `git checkout -b feature/nueva-funcionalidad`
3. Commit: `git commit -m 'Agregar nueva funcionalidad'`
4. Push: `git push origin feature/nueva-funcionalidad`
5. Crear Pull Request

### Estándares de Código

- Seguir [Angular Style Guide](https://angular.dev/style-guide)
- Código en inglés (comentarios en español si necesario)
- Tests unitarios para nuevas funcionalidades
- Documentar funciones complejas

---

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver archivo [LICENSE](LICENSE) para detalles.

---

## 👨‍💻 Autores

- Andrey J - *Desarrollo inicial* - [GitHub](https://github.com/Andreysillo)
- David E - *Desarrollo inicial* - [GitHub](https://github.com/jdavidespinoza05)

---

## 🙏 Agradecimientos

- Angular Team por el excelente framework
- Oracle por la base de datos
- Comunidad open source

---

## 📞 Contacto

- **Email:** tu-email@ejemplo.com
- **GitHub:** [@tu-usuario](https://github.com/tu-usuario)
- **LinkedIn:** [Tu Nombre](https://linkedin.com/in/tu-perfil)

---

## 📊 Estado del Proyecto

![Estado](https://img.shields.io/badge/estado-en%20desarrollo-yellow)
![Angular](https://img.shields.io/badge/Angular-19.2.0-red)
![Node](https://img.shields.io/badge/Node.js-22.21.0-green)
![Oracle](https://img.shields.io/badge/Oracle-11g%20XE-red)
![Docker](https://img.shields.io/badge/Docker-latest-blue)

---

**¡Gracias por usar Salon Beauty App!** 💅✨