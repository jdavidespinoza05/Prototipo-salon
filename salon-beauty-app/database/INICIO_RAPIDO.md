# 🚀 Inicio Rápido

## Instalación en 3 pasos

### 1️⃣ Requisitos previos
- Docker instalado y corriendo
- Docker Compose instalado
- Al menos 2GB de RAM libres

### 2️⃣ Instalación automática

```bash
# Clonar o extraer el proyecto
cd salon-belleza-db

# Ejecutar script de instalación
./start.sh
```

El script automáticamente:
- ✅ Verificará Docker
- ✅ Levantará los contenedores
- ✅ Esperará a que Oracle esté listo
- ✅ Inicializará la base de datos
- ✅ Insertará datos de ejemplo

### 3️⃣ ¡Listo!

Tu base de datos está corriendo en:
```
Host: localhost
Puerto: 1521
SID: XE
Usuario: salon_user
Password: salon_pass123
```

## 📋 Comandos rápidos

```bash
# Ver logs de Oracle
docker logs oracle-salon-belleza -f

# Conectarse a SQLPlus
docker exec -it oracle-salon-belleza sqlplus salon_user/salon_pass123@XE

# Gestionar base de datos (menú interactivo)
./init_db.sh

# Detener contenedores
docker-compose down

# Reiniciar contenedores
docker-compose restart
```

## 📚 ¿Qué sigue?

1. Lee el [README.md](README.md) completo
2. Revisa el [Diagrama ER](database/DIAGRAMA_ER.md)
3. Consulta la [Guía de Conexión](database/GUIA_CONEXION.md)
4. Explora las [Consultas Útiles](database/queries_utiles.sql)

## 🆘 ¿Problemas?

### Oracle no inicia
```bash
# Ver logs detallados
docker logs oracle-salon-belleza

# Verificar recursos de Docker
docker stats
```

### Puerto 1521 ocupado
```bash
# Ver qué está usando el puerto
lsof -i :1521

# Cambiar el puerto en docker-compose.yml
ports:
  - "1522:1521"  # Usar 1522 en lugar de 1521
```

### Reiniciar desde cero
```bash
# Detener y eliminar todo (¡CUIDADO! Borra todos los datos)
docker-compose down -v
./start.sh
```

## 💡 Datos de prueba incluidos

- 2 administradores
- 5 clientes con puntos
- 10 servicios
- 10 productos  
- 10 recompensas
- 7 testimonios

**Usuario admin de prueba:**
- Email: maria.gonzalez@salon.com
- Password: admin123

---

¿Preguntas? Revisa la documentación completa en README.md
