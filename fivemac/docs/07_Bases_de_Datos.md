# Bases de Datos en FiveMac

FiveMac proporciona capas de abstracción para trabajar con motores SQL de una manera muy similar a como se trabajaría con ficheros DBF tradicionales en Harbour, pero aprovechando toda la potencia de los motores relacionales modernos.

## SQL Nativo vs. Estilo xBase

Puedes elegir entre dos enfoques:
1. **Comandos SQL directos**: Ejecutar sentencias `SELECT`, `INSERT`, `UPDATE` directamente.
2. **Comandos de estilo xBase**: Usar comandos como `SQLITE APPEND`, `SQLITE REPLACE`, `SQLITE SKIP`, que emulan el comportamiento de las DBF sobre las tablas SQL.

---

## SQLite

SQLite es el motor recomendado para aplicaciones de escritorio que no requieren un servidor centralizado. En macOS es **nativo** (está integrado en el sistema), por lo que no requiere instalación alguna.

### Comandos SQLITE

Para activar estos comandos, incluya `#include "sqlite.ch"` (o use `FiveMac.ch` que suele incluirlo).

| Comando | Descripción |
|---------|-------------|
| `SQLITE CONNECT <file> [CREATE] INTO <oDb>` | Abre o crea una base de datos SQLite. |
| `SQLITE USE <table> [IN <oDb>] [ORDER <col>]` | Abre una tabla y carga los registros en memoria. |
| `SQLITE APPEND [IN <oDb>]` | Añade un nuevo registro vacío. |
| `SQLITE REPLACE <fld> WITH <val> [IN <oDb>]` | Actualiza el valor de un campo en el registro actual. |
| `SQLITE DELETE [IN <oDb>]` | Borra el registro actual. |
| `SQLITE CLOSE [<oDb>]` | Cierra la conexión. |

### Ejemplo rápido (SQLite)

```harbour
#include "FiveMac.ch"

function Main()
   local oDb
   
   // Conectar (Crea si no existe)
   SQLITE CONNECT "mi_app.db" CREATE INTO oDb
   
   // Crear tabla si no existe
   oDb:Execute( "CREATE TABLE IF NOT EXISTS clientes (id INTEGER PRIMARY KEY, nombre TEXT, saldo NUMERIC)" )
   
   // Añadir un registro
   SQLITE APPEND IN oDb
   SQLITE REPLACE "nombre" WITH "Juan Perez" IN oDb
   SQLITE REPLACE "saldo"  WITH 1250.50 IN oDb
   
   // Consultar y navegar
   SQLITE USE "clientes" IN oDb ORDER "nombre"
   
   oDb:GoTop()
   while ! oDb:EOF()
      ? oDb:FieldGet( 2 ), oDb:FieldGet( 3 )
      oDb:Skip()
   enddo
   
   SQLITE CLOSE oDb
return nil
```

---

## MySQL / MariaDB

FiveMac incluye un wrapper moderno para MySQL/MariaDB que permite conexión remota y centralizada.

### Comandos MYSQL

Requiere `#include "mysql.ch"`.

| Comando | Descripción |
|---------|-------------|
| `MYSQL CONNECT <db> [HOST <h>] [USER <u>] [PASSWORD <p>] INTO <oDb>` | Conecta al servidor MySQL. |
| `MYSQL QUERY <sql> [IN <oDb>]` | Ejecuta una sentencia SQL arbitraria. |
| `MYSQL USE <table> [IN <oDb>] [ORDER <col>]` | Carga una tabla para navegación xBase. |
| `MYSQL INSERT <table> HASH <hData> [IN <oDb>]` | Inserta datos desde un Hash de Harbour. |
| `MYSQL REPLACE <fld> WITH <val>` | Actualiza un campo (requiere que la tabla tenga una PK 'id'). |

### Ejemplo rápido (MySQL)

```harbour
#include "FiveMac.ch"
#include "mysql.ch"

function Main()
   local oDb
   
   MYSQL CONNECT "empresa" HOST "127.0.0.1" USER "root" PASSWORD "secret" INTO oDb
   
   if oDb == nil ; return nil ; endif
   
   // Inserción rápida mediante Hash
   MYSQL INSERT "ventas" IN oDb HASH { "fecha" => Date(), "importe" => 500 }
   
   // Carga de resultados para un Browse
   MYSQL USE "ventas" IN oDb ORDER "id DESC"
   
   MsgInfo( "Registros: " + cValToChar( oDb:RecCount() ) )
   
   SQLITE CLOSE oDb
return nil
```

---

## Herramientas de Interoperabilidad

Una de las grandes potencias de FiveMac es la facilidad para migrar datos entre formatos:

- **Importar de DBF a SQL**: 
  `oDb:ImportFromDBF( "clientes.dbf" )` -> Crea la tabla y vuelca todos los datos.
- **Exportar de SQL a DBF**: 
  `oDb:ExportToDBF( "backup.dbf" )` -> Crea un DBF con la estructura y datos del query actual.
- **Migración SQLite a MySQL**: 
  `oDbMySql:ImportFromSQLite( oDbLite, "ventas" )` -> Mueve una tabla completa de un motor a otro de forma automática.

## La Clase TSQLite / TMySQL

Ambas clases comparten una interfaz común para facilitar el polimorfismo:

- `:Query( cSql )`: Devuelve un array de arrays con los resultados.
- `:Execute( cSql )`: Ejecuta comandos sin retorno (DDL/DML).
- `:GoTop()`, `:GoBottom()`, `:Skip( n )`: Navegación por el set de resultados cargado.
- `:FieldGet( n )`: Obtiene el valor de una columna.
- `:DbStruct()`: Devuelve la estructura de la tabla activa en formato Harbour/Dbf.
