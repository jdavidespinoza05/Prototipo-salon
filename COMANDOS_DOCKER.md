
### Ver todos los administradores
```bash
docker exec oracle-salon-belleza bash -c "echo 'SELECT id_admin, nombre, correo, activo FROM salon_user.administradores ORDER BY id_admin;' | sqlplus -s salon_user/salon_pass123@//localhost:1521/XEPDB1"
```

### Contar total de administradores
```bash
docker exec oracle-salon-belleza bash -c "echo 'SELECT COUNT(*) as TOTAL FROM salon_user.administradores;' | sqlplus -s salon_user/salon_pass123@//localhost:1521/XEPDB1"
```

### Ver último acceso de cada admin
```bash
docker exec oracle-salon-belleza bash -c "echo 'SELECT nombre, correo, TO_CHAR(ultimo_acceso, '\''DD/MM/YYYY HH24:MI:SS'\'') as ultimo_acceso FROM salon_user.administradores ORDER BY ultimo_acceso DESC NULLS LAST;' | sqlplus -s salon_user/salon_pass123@//localhost:1521/XEPDB1"
```

### Ver administradores con formato bonito
```bash
docker exec oracle-salon-belleza bash -c "echo 'SET LINESIZE 150; COL nombre FORMAT A30; COL correo FORMAT A35; SELECT id_admin, nombre, correo, activo, TO_CHAR(fecha_creacion, '\''DD/MM/YYYY'\'') as fecha FROM salon_user.administradores;' | sqlplus -s salon_user/salon_pass123@//localhost:1521/XEPDB1"
```

---

## agregar admins

### Agregar admin con contraseña "admin123"
```bash
docker exec oracle-salon-belleza bash -c "echo \"INSERT INTO salon_user.administradores (nombre, correo, password_hash) VALUES ('Profesor Demo', 'profesor@salon.com', '\$2b\$10\$FzRCaY9PGoI.YPNVpdPzDO0m97Yfya1fqXLWOPQNMh1f/va90Oux.'); COMMIT; SELECT id_admin, nombre, correo FROM salon_user.administradores WHERE correo = 'profesor@salon.com';\" | sqlplus -s salon_user/salon_pass123@//localhost:1521/XEPDB1"
```

### Agregar "Juan Pérez" con contraseña "password123"
```bash
docker exec oracle-salon-belleza bash -c "echo \"INSERT INTO salon_user.administradores (nombre, correo, password_hash) VALUES ('Juan Pérez', 'juan.perez@salon.com', '\$2b\$10\$AHZ13jf9eioJtQ5KDW3ryO4wm/Wmhil5364vp0zcFWvvV50/lURtC'); COMMIT; SELECT id_admin, nombre, correo FROM salon_user.administradores WHERE correo = 'juan.perez@salon.com';\" | sqlplus -s salon_user/salon_pass123@//localhost:1521/XEPDB1"
```

