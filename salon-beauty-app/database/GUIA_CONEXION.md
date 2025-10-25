# Guía de Conexión a Oracle 11g
## Diferentes Herramientas y Clientes

## 📌 Información de Conexión

### Credenciales de Sistema
```
Host: localhost
Puerto: 1521
SID: XE
Usuario SYSTEM: system
Password SYSTEM: oracle
```

### Credenciales de Aplicación
```
Host: localhost
Puerto: 1521
SID: XE
Usuario: salon_user
Password: salon_pass123
```

---

## 🔌 SQL Developer (Oracle)

### Descarga
https://www.oracle.com/database/sqldeveloper/technologies/download/

### Configuración de Conexión

1. Abrir SQL Developer
2. Click en el botón "+" (Nueva Conexión)
3. Configurar:
   ```
   Connection Name: Salon_Belleza
   Usuario: salon_user
   Password: salon_pass123
   
   Connection Type: Basic
   Hostname: localhost
   Port: 1521
   SID: XE
   ```
4. Click en "Test" para probar
5. Click en "Connect"

### String de Conexión Alternativo
```
salon_user/salon_pass123@localhost:1521/XE
```

---

## 🔌 DBeaver (Universal)

### Descarga
https://dbeaver.io/download/

### Configuración de Conexión

1. Abrir DBeaver
2. Nueva Conexión → Oracle
3. Configurar:
   ```
   Host: localhost
   Port: 1521
   Database: XE
   Connection Type: SID
   
   Username: salon_user
   Password: salon_user123
   ```
4. En Driver properties, asegurar:
   ```
   useOldAliasMetadataBehavior: true
   ```
5. Test Connection
6. Finish

---

## 🔌 DataGrip (JetBrains)

### Descarga
https://www.jetbrains.com/datagrip/

### Configuración de Conexión

1. Abrir DataGrip
2. Database → "+" → Data Source → Oracle
3. Configurar:
   ```
   Host: localhost
   Port: 1521
   Database: XE
   User: salon_user
   Password: salon_pass123
   URL: jdbc:oracle:thin:@localhost:1521:XE
   ```
4. Download missing drivers (si es necesario)
5. Test Connection
6. OK

---

## 🔌 Node.js con oracledb

### Instalación
```bash
npm install oracledb
```

### Configuración Básica

```javascript
const oracledb = require('oracledb');

// Configuración de conexión
const dbConfig = {
    user: 'salon_user',
    password: 'salon_pass123',
    connectString: 'localhost:1521/XE'
};

// Función de conexión
async function initialize() {
    try {
        // Crear pool de conexiones
        await oracledb.createPool({
            user: dbConfig.user,
            password: dbConfig.password,
            connectString: dbConfig.connectString,
            poolMin: 2,
            poolMax: 10,
            poolIncrement: 2,
            poolTimeout: 60
        });
        console.log('Pool de conexiones creado exitosamente');
    } catch (err) {
        console.error('Error al crear pool:', err);
        throw err;
    }
}

// Función para ejecutar queries
async function executeQuery(sql, params = []) {
    let connection;
    try {
        connection = await oracledb.getConnection();
        const result = await connection.execute(sql, params);
        return result;
    } catch (err) {
        console.error('Error ejecutando query:', err);
        throw err;
    } finally {
        if (connection) {
            try {
                await connection.close();
            } catch (err) {
                console.error('Error cerrando conexión:', err);
            }
        }
    }
}

// Ejemplo de uso
async function getClientes() {
    const sql = `SELECT * FROM clientes WHERE activo = :activo`;
    const params = { activo: 'S' };
    
    const result = await executeQuery(sql, params);
    return result.rows;
}

module.exports = {
    initialize,
    executeQuery,
    getClientes
};
```

### Ejemplo de Servicio REST con Express

```javascript
const express = require('express');
const oracledb = require('oracledb');

const app = express();
app.use(express.json());

// Configuración de conexión
const dbConfig = {
    user: 'salon_user',
    password: 'salon_pass123',
    connectString: 'localhost:1521/XE'
};

// Inicializar pool
async function initialize() {
    await oracledb.createPool(dbConfig);
}

// Endpoint: Obtener todos los clientes
app.get('/api/clientes', async (req, res) => {
    let connection;
    try {
        connection = await oracledb.getConnection();
        const result = await connection.execute(
            `SELECT id_cliente, nombre, correo, telefono, saldo_puntos 
             FROM clientes WHERE activo = 'S'`
        );
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error al obtener clientes' });
    } finally {
        if (connection) await connection.close();
    }
});

// Endpoint: Agregar puntos a cliente
app.post('/api/clientes/:id/puntos', async (req, res) => {
    let connection;
    const { puntos, descripcion } = req.body;
    const clienteId = req.params.id;
    
    try {
        connection = await oracledb.getConnection();
        await connection.execute(
            `BEGIN
                sp_agregar_puntos(
                    p_id_cliente => :id,
                    p_puntos => :puntos,
                    p_descripcion => :desc
                );
             END;`,
            {
                id: clienteId,
                puntos: puntos,
                desc: descripcion
            },
            { autoCommit: true }
        );
        res.json({ success: true, message: 'Puntos agregados' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error al agregar puntos' });
    } finally {
        if (connection) await connection.close();
    }
});

// Iniciar servidor
initialize()
    .then(() => {
        app.listen(3000, () => {
            console.log('Servidor corriendo en puerto 3000');
        });
    })
    .catch(err => {
        console.error('Error al inicializar:', err);
        process.exit(1);
    });
```

---

## 🔌 Python con cx_Oracle

### Instalación
```bash
pip install cx_Oracle
```

### Configuración Básica

```python
import cx_Oracle

# Configuración de conexión
dsn = cx_Oracle.makedsn('localhost', 1521, service_name='XE')
connection = cx_Oracle.connect(
    user='salon_user',
    password='salon_pass123',
    dsn=dsn
)

# Ejemplo de consulta
def get_clientes():
    cursor = connection.cursor()
    cursor.execute("SELECT * FROM clientes WHERE activo = 'S'")
    
    clientes = []
    for row in cursor:
        clientes.append({
            'id': row[0],
            'nombre': row[1],
            'correo': row[2],
            'telefono': row[3],
            'saldo_puntos': row[6]
        })
    
    cursor.close()
    return clientes

# Ejemplo de procedimiento almacenado
def agregar_puntos(id_cliente, puntos, descripcion):
    cursor = connection.cursor()
    cursor.callproc('sp_agregar_puntos', [
        id_cliente,
        puntos,
        descripcion,
        None  # p_id_admin (opcional)
    ])
    connection.commit()
    cursor.close()

# Cerrar conexión al finalizar
connection.close()
```

---

## 🔌 Java con JDBC

### Dependencia Maven
```xml
<dependency>
    <groupId>com.oracle.database.jdbc</groupId>
    <artifactId>ojdbc8</artifactId>
    <version>21.5.0.0</version>
</dependency>
```

### Configuración Básica

```java
import java.sql.*;

public class OracleConnection {
    private static final String URL = "jdbc:oracle:thin:@localhost:1521:XE";
    private static final String USER = "salon_user";
    private static final String PASSWORD = "salon_pass123";
    
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
    
    // Ejemplo de consulta
    public static void getClientes() {
        String sql = "SELECT * FROM clientes WHERE activo = 'S'";
        
        try (Connection conn = getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                System.out.println(
                    "ID: " + rs.getInt("id_cliente") +
                    ", Nombre: " + rs.getString("nombre") +
                    ", Puntos: " + rs.getInt("saldo_puntos")
                );
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
```

---

## 🔌 Angular Service (para tu proyecto)

### cliente.service.ts

```typescript
import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface Cliente {
  idCliente: number;
  nombre: string;
  correo: string;
  telefono: string;
  codigoQr: string;
  fechaRegistro: Date;
  saldoPuntos: number;
  totalPuntosAcumulados: number;
  activo: string;
}

@Injectable({
  providedIn: 'root'
})
export class ClienteService {
  private apiUrl = 'http://localhost:3000/api'; // URL de tu backend

  constructor(private http: HttpClient) { }

  getClientes(): Observable<Cliente[]> {
    return this.http.get<Cliente[]>(`${this.apiUrl}/clientes`);
  }

  getCliente(id: number): Observable<Cliente> {
    return this.http.get<Cliente>(`${this.apiUrl}/clientes/${id}`);
  }

  agregarPuntos(id: number, puntos: number, descripcion: string): Observable<any> {
    return this.http.post(`${this.apiUrl}/clientes/${id}/puntos`, {
      puntos,
      descripcion
    });
  }

  buscarCliente(termino: string): Observable<Cliente[]> {
    return this.http.get<Cliente[]>(`${this.apiUrl}/clientes/buscar/${termino}`);
  }
}
```

---

## 🔌 SQLPlus (Línea de Comandos)

### Desde el contenedor Docker

```bash
# Conectarse al contenedor
docker exec -it oracle-salon-belleza bash

# Conectarse como SYSTEM
sqlplus system/oracle@XE

# Conectarse como salon_user
sqlplus salon_user/salon_pass123@XE

# Ejecutar script
sqlplus salon_user/salon_pass123@XE @/path/to/script.sql
```

### Desde el host (si tienes Oracle Client instalado)

```bash
sqlplus salon_user/salon_pass123@localhost:1521/XE
```

### Comandos útiles en SQLPlus

```sql
-- Ver tablas del usuario
SELECT table_name FROM user_tables;

-- Describir estructura de tabla
DESC clientes;

-- Ver todas las vistas
SELECT view_name FROM user_views;

-- Ver procedimientos y funciones
SELECT object_name, object_type FROM user_objects 
WHERE object_type IN ('PROCEDURE', 'FUNCTION');

-- Activar salida de DBMS_OUTPUT
SET SERVEROUTPUT ON;

-- Formato de columnas para mejor visualización
COLUMN nombre FORMAT A30
COLUMN correo FORMAT A30

-- Ejecutar script
@queries_utiles.sql

-- Salir
EXIT;
```

---

## 🛠️ Variables de Entorno (Recomendado)

### .env para Node.js

```env
# Database Configuration
DB_HOST=localhost
DB_PORT=1521
DB_SID=XE
DB_USER=salon_user
DB_PASSWORD=salon_pass123

# Pool Configuration
DB_POOL_MIN=2
DB_POOL_MAX=10
DB_POOL_INCREMENT=2

# Application
PORT=3000
NODE_ENV=development
```

### environment.ts para Angular

```typescript
export const environment = {
  production: false,
  apiUrl: 'http://localhost:3000/api',
  dbConfig: {
    // No incluir credenciales en el frontend
    // Solo URL del backend
  }
};
```

---

## ✅ Verificación de Conexión

### Script de Test (Node.js)

```javascript
const oracledb = require('oracledb');

async function testConnection() {
    let connection;
    try {
        connection = await oracledb.getConnection({
            user: 'salon_user',
            password: 'salon_pass123',
            connectString: 'localhost:1521/XE'
        });
        
        console.log('✅ Conexión exitosa a Oracle!');
        
        const result = await connection.execute(
            'SELECT * FROM v$version'
        );
        
        console.log('Versión de Oracle:');
        console.log(result.rows[0][0]);
        
    } catch (err) {
        console.error('❌ Error de conexión:', err);
    } finally {
        if (connection) {
            await connection.close();
        }
    }
}

testConnection();
```

---

## 🔒 Seguridad

### Mejores Prácticas

1. **Nunca** commitear credenciales en el código
2. Usar variables de entorno para configuración
3. Implementar rate limiting en el backend
4. Validar todos los inputs
5. Usar prepared statements/bind variables
6. Implementar logging de errores
7. Usar HTTPS en producción
8. Implementar autenticación JWT
9. Encriptar datos sensibles
10. Hacer backups regulares

---

## 📚 Recursos Adicionales

- [Oracle Database JavaScript API (oracledb)](https://oracle.github.io/node-oracledb/)
- [Oracle JDBC Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/21/jjdbc/)
- [cx_Oracle Documentation](https://cx-oracle.readthedocs.io/)
- [SQL Developer Documentation](https://docs.oracle.com/en/database/oracle/sql-developer/)
