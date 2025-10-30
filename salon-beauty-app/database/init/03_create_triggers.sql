CONNECT salon_user/salon_pass123@XEPDB1;

-- Este trigger se activa cada vez que agregamos un nuevo administrador
-- Si no le ponemos un ID manualmente, él solito toma el siguiente número de la secuencia
-- Así nos evitamos tener que estar poniendo los IDs a mano cada vez
CREATE OR REPLACE TRIGGER trg_admin_id
BEFORE INSERT ON administradores
FOR EACH ROW
BEGIN
    IF :NEW.id_admin IS NULL THEN
        SELECT seq_admin.NEXTVAL INTO :NEW.id_admin FROM DUAL;
    END IF;
END;
/

COMMIT;

SELECT 'Trigger creado exitosamente' AS STATUS FROM DUAL;
EXIT;
