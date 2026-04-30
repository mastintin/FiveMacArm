#include "FiveMac.ch"
#include "sqlite.ch"

function Main()

    local oDbSQLite, lExport
  
    // 1. Abrimos SQLite
    oDbSQLite := TSQLite():New( path() + "/jubilacion.db" )
    if Empty( oDbSQLite:hDB )
    MsgInfo( "No se pudo abrir la base de datos SQLite" )    
    Return .f.
    endif

    // 2. Proceso de exportacion de tabla SQLite a DBF
    // Vamos a exportar la tabla "ipc_indices"
    oDbSQLite:TableUse( "ipc_indices" )
    lExport := TableExport( oDbSQLite, path() + "/IPC_EXPORT.DBF" )

    if lExport
    MsgInfo( "Tabla SQLite exportada exitosamente a DBF (IPC_EXPORT.DBF)" )
    else
    MsgInfo( "Error al exportar tabla SQLite a DBF" )
    endif
    
    oDbSQLite:End()

return nil

Function TableExport( oDb, cDbf )
   
    local oWnd, oProg
    local lExit := .t.
    local nRecCount := oDb:RecCount()
    
    DEFINE WINDOW oWnd TITLE "Exportando SQLite a DBF: " + FileNoPath( cDbf )  NOFLIPPED ;
        FROM 200, 200 TO 320, 600
       
    @ 40, 20 PROGRESS oProg POSITION 0 SIZE 360, 20 OF oWnd
    oProg:SetRange( 0, nRecCount )
    
    oWnd:Center()
    oWnd:Show()
    PUMPEVENTS()
 
    lExit := oDb:ExportToDBF( cDbf, { | nDone | oProg:Update( nDone ) } )
    
    oWnd:End()
    
Return lExit   
