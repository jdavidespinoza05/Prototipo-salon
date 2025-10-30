# Sistema de Registro de Usuarios - Instrucciones

## Implementación Completa

Se ha implementado exitosamente el sistema de registro (sign up) para crear nuevas cuentas de administrador.

## Funcionalidades Implementadas

### Backend (Node.js + Express)

#### Endpoint de Registro: `POST /api/auth/register`

**Ubicación**: `salon-beauty-app/backend/controllers/authController.js:189`

**Validaciones:**
- ✅ Todos los campos son obligatorios (nombre, correo, password)
- ✅ Formato de correo válido
- ✅ Contraseña mínimo 6 caracteres
- ✅ Nombre mínimo 3 caracteres
- ✅ Correo único (no permite duplicados)

**Proceso:**
1. Valida los datos de entrada
2. Verifica que el correo no exista en la BD
3. Encripta la contraseña con bcrypt (10 salt rounds)
4. Inserta el nuevo administrador en PostgreSQL
5. Genera un token JWT automáticamente
6. Devuelve los datos del usuario y el token

**Respuesta Exitosa (201):**
```json
{
  "success": true,
  "message": "Registro exitoso",
  "admin": {
    "id_admin": 4,
    "nombre": "Juan Pérez",
    "correo": "juan.perez@example.com",
    "activo": "S",
    "fecha_creacion": "2025-10-30T17:30:32.337Z",
    "ultimo_acceso": null
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Errores Posibles:**
- 400: Campos faltantes o inválidos
- 409: Correo ya registrado
- 500: Error del servidor

### Frontend (Angular)

#### Componente de Registro
**Ubicación**: `salon-beauty-app/src/app/pages/register/`

**Características:**
- ✅ Formulario reactivo con validación en tiempo real
- ✅ Validación de contraseñas coincidentes
- ✅ Mensajes de error amigables
- ✅ Indicador de carga durante el registro
- ✅ Mensaje de éxito
- ✅ Redirección automática al dashboard después de registro exitoso
- ✅ Link para volver al login
- ✅ Diseño consistente con el login

#### Navegación
- **Ruta**: http://localhost/register
- **Link desde login**: "¿No tienes una cuenta? Regístrate"
- **Link desde registro**: "¿Ya tienes una cuenta? Inicia sesión"

### Base de Datos (PostgreSQL)

La tabla `administradores` ya existía y es compatible con el registro:
- `id_admin`: SERIAL (auto-incremental)
- `nombre`: VARCHAR(100)
- `correo`: VARCHAR(100) UNIQUE
- `password_hash`: VARCHAR(256)
- `fecha_creacion`: TIMESTAMP (default CURRENT_TIMESTAMP)
- `activo`: CHAR(1) (default 'S')
- `ultimo_acceso`: TIMESTAMP

## Pruebas Realizadas

### 1. Registro Exitoso
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "nombre": "Juan Pérez",
    "correo": "juan.perez@example.com",
    "password": "password123"
  }'
```

**Resultado**: ✅ Usuario creado con ID 4

### 2. Verificación en Base de Datos
```bash
docker exec salon-postgres psql -U salon_user -d salon_beauty \
  -c "SELECT id_admin, nombre, correo, activo FROM administradores;"
```

**Resultado**: ✅ 4 usuarios en total (3 iniciales + 1 nuevo)

### 3. Login con Usuario Nuevo
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "correo": "juan.perez@example.com",
    "password": "password123"
  }'
```

**Resultado**: ✅ Login exitoso con token JWT

### 4. Validación de Correo Duplicado
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "nombre": "Juan Pérez",
    "correo": "juan.perez@example.com",
    "password": "password123"
  }'
```

**Resultado**: ✅ Error 409 - "El correo ya está registrado"

### 5. Validación de Contraseña Corta
**Frontend**: Muestra error "Mínimo 6 caracteres"
**Backend**: Retorna 400 - "La contraseña debe tener al menos 6 caracteres"

### 6. Frontend
**Acceso**: http://localhost/register
**Resultado**: ✅ Página carga correctamente

## Cómo Usar el Sistema de Registro

### Desde el Frontend (Recomendado)

1. **Abre tu navegador** en http://localhost

2. **Accede al registro**:
   - Desde la página de login, haz clic en "Regístrate"
   - O navega directamente a http://localhost/register

3. **Completa el formulario**:
   - Nombre completo (mínimo 3 caracteres)
   - Correo electrónico válido
   - Contraseña (mínimo 6 caracteres)
   - Confirmar contraseña

4. **Haz clic en "Crear Cuenta"**

5. **Resultado**:
   - Si es exitoso: Verás un mensaje verde y serás redirigido al dashboard en 2 segundos
   - Si hay error: Verás un mensaje rojo con el problema específico

### Desde el Backend (API)

```bash
# Usando PowerShell
$body = @{
    nombre = "Nuevo Usuario"
    correo = "usuario@example.com"
    password = "password123"
} | ConvertTo-Json

Invoke-RestMethod -Uri 'http://localhost:3000/api/auth/register' `
  -Method Post `
  -Body $body `
  -ContentType 'application/json'
```

```bash
# Usando curl (Git Bash o WSL)
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "nombre": "Nuevo Usuario",
    "correo": "usuario@example.com",
    "password": "password123"
  }'
```

## Usuarios de Prueba Existentes

| Nombre | Correo | Contraseña | ID |
|--------|--------|------------|-----|
| Administrador | admin@salon.com | admin123 | 1 |
| María González | maria.gonzalez@salon.com | admin123 | 2 |
| Carlos Rodríguez | carlos.rodriguez@salon.com | admin123 | 3 |
| Juan Pérez | juan.perez@example.com | password123 | 4 |

## Archivos Modificados/Creados

### Backend
- ✅ `backend/controllers/authController.js` - Función `register()` agregada
- ✅ `backend/routes/auth.js` - Ruta `/register` agregada

### Frontend
- ✅ `src/app/pages/register/register.component.ts` - Componente creado
- ✅ `src/app/pages/register/register.component.html` - Template creado
- ✅ `src/app/pages/register/register.component.css` - Estilos creados
- ✅ `src/app/pages/register/register.component.spec.ts` - Tests creados
- ✅ `src/app/models/admin.model.ts` - Interfaces `RegisterData` y `RegisterResponse` agregadas
- ✅ `src/app/services/client.service.ts` - Método `register()` agregado
- ✅ `src/app/app.routes.ts` - Ruta `/register` agregada
- ✅ `src/app/pages/login/login.component.html` - Link a registro agregado
- ✅ `src/app/pages/login/login.component.css` - Estilos para link agregados
- ✅ `src/app/pages/login/login.component.ts` - Import RouterModule agregado

## Seguridad

✅ **Contraseñas encriptadas**: Usa bcrypt con 10 salt rounds
✅ **JWT tokens**: Tokens seguros con expiración de 8 horas
✅ **Validación de entrada**: Validación tanto en frontend como backend
✅ **Prevención de duplicados**: Correo único en base de datos
✅ **Sanitización**: Nombres trimmed, correos en lowercase
✅ **Mensajes de error genéricos**: No expone información sensible

## Próximos Pasos (Opcional)

- [ ] Implementar recuperación de contraseña
- [ ] Agregar verificación de correo electrónico
- [ ] Implementar roles de usuario (admin, empleado, etc.)
- [ ] Agregar foto de perfil
- [ ] Implementar cambio de contraseña
- [ ] Agregar autenticación de dos factores (2FA)

## Comandos Útiles

```bash
# Ver logs del backend
docker-compose logs -f backend

# Ver usuarios en la base de datos
docker exec salon-postgres psql -U salon_user -d salon_beauty \
  -c "SELECT * FROM administradores;"

# Reiniciar servicios
docker-compose restart backend frontend

# Reconstruir todo
docker-compose down -v
docker-compose up -d
```

## Soporte

Si encuentras algún problema:
1. Verifica que todos los contenedores estén corriendo: `docker-compose ps`
2. Revisa los logs: `docker-compose logs -f`
3. Verifica la base de datos: `docker exec salon-postgres psql -U salon_user -d salon_beauty`
