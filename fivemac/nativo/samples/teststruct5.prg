#include "FiveMac.ch"
#include "mysql.ch"

function Main()

    local oDbMySQL, lExport
  
    // 1. acedemos a MySql
    oDbMySQL := TMySQL():New( "134.0.10.187", "mastintin", "Mas_0210199999", "testfivemac" )
    if oDbMySQL == nil .or. Empty( oDbMySQL:oServer )
        MsgInfo( "No se pudo abrir la base de datos MySQL" )    
        Return .f.
    endif

    // 2. Proceso de exportacion de tabla MySQL a DBF
    oDbMySQL:TableUse( "ipc_indices" )
    lExport := TableExport( oDbMySQL, path() + "/IPC_MYSQL_EXPORT.DBF" )

    if lExport
        MsgInfo( "Tabla MySQL exportada exitosamente a DBF (IPC_MYSQL_EXPORT.DBF)" )
    else
        MsgInfo( "Error al exportar tabla MySQL a DBF" )
    endif
    
    oDbMySQL:End()

return nil

Function TableExport( oDb, cDbf )
   
    local oWnd, oProg
    local lExit := .t.
    local nRecCount := oDb:RecCount()
    
    DEFINE WINDOW oWnd TITLE "Exportando a DBF: " + FileNoPath( cDbf ) ;
        FROM 200, 200 TO 320, 600
       
    @ 40, 20 PROGRESS oProg POSITION 0 SIZE 360, 20 OF oWnd
    oProg:SetRange( 0, nRecCount )
    
    oWnd:Center()
    oWnd:Show()
    PUMPEVENTS()
 
    lExit := oDb:ExportToDBF( cDbf, { | nDone | oProg:Update( nDone ) } )
    
    oWnd:End()
    
Return lExit   
