#include "FiveMac.ch"
#include "sqlite.ch"
#include "mysql.ch"

function Main()

    local oDbSQLite, oDbMySQL, lTableSqlitetoMySql
  
    // 1. Abrimos SQLite
    oDbSQLite := TSQLite():New( path() + "/jubilacion.db" )
    if oDbSQLite == nil .or. Empty( oDbSQLite:hDB )
        MsgInfo( "No se pudo abrir la base de datos SQLite" )    
        Return .f.
    endif

    // 2. acedemos a MySql
    oDbMySQL := TMySQL():New( "134.0.10.187", "mastintin", "Mas_0210199999", "testfivemac" )
    if oDbMySQL == nil .or. Empty( oDbMySQL:oServer )
        MsgInfo( "No se pudo abrir la base de datos MySQL" )    
        Return .f.
    endif

    // 3. proceso de creacion de la tabla en MySQL
    lTableSqlitetoMySql := TableImport( oDbSQLite, oDbMySQL, "ipc_indices" )

    if lTableSqlitetoMySql
        MsgInfo( "Tabla copiada exitosamente" )
    else
        MsgInfo( "Error al copiar la tabla" )
    endif
    
    
    oDbSQLite:End()
    oDbMySQL:End()

return nil

Function TableImport( oDbSQLite, oDbMySQL, cTable )
   
    local oWnd, oProg
    local lExit := .t.
    local nRecCount := oDbSQLite:RecCount()

    DEFINE WINDOW oWnd TITLE "Importando " + cTable ;
        FROM 200, 200 TO 320, 600
       
    @ 40, 20 PROGRESS oProg POSITION 0 SIZE 360, 20 OF oWnd
    oProg:SetRange( 0, nRecCount )
    
    oWnd:Center()
    oWnd:Show()
    PUMPEVENTS()
 
    lExit := oDbMySQL:ImportFromSQLite( oDbSQLite, cTable, { | nDone | oProg:Update( nDone ) } )
    
    oWnd:End()
    
Return lExit   
    
