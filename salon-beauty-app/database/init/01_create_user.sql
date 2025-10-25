-- ==================================================
-- Script de Configuración Inicial
-- Salón de Belleza - Sistema de Fidelidad
-- ==================================================

-- Conectar como SYSTEM para crear el usuario
-- NOTA: Ejecutar este script como usuario SYSTEM

-- Crear usuario para la aplicación
CREATE USER salon_user IDENTIFIED BY salon_pass123
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP
  QUOTA UNLIMITED ON USERS;

-- Otorgar privilegios necesarios
GRANT CONNECT, RESOURCE TO salon_user;
GRANT CREATE SESSION TO salon_user;
GRANT CREATE TABLE TO salon_user;
GRANT CREATE VIEW TO salon_user;
GRANT CREATE SEQUENCE TO salon_user;
GRANT CREATE TRIGGER TO salon_user;

-- Privilegios adicionales
GRANT SELECT ANY TABLE TO salon_user;
GRANT INSERT ANY TABLE TO salon_user;
GRANT UPDATE ANY TABLE TO salon_user;
GRANT DELETE ANY TABLE TO salon_user;

-- Confirmar cambios
COMMIT;

-- Mensaje de confirmación
SELECT 'Usuario salon_user creado exitosamente' AS STATUS FROM DUAL;
