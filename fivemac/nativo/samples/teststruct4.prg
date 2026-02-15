#include "FiveMac.ch"
#include "sqlite.ch"

function Main()

    local oDbSQLite, lTableImport
  
    // 1. Abrimos SQLite
    oDbSQLite := TSQLite():New( path() + "/jubilacion.db" )
    if Empty( oDbSQLite:hDB )
        MsgInfo( "No se pudo abrir la base de datos SQLite" )    
        Return .f.
    endif

    // 2. Proceso de creacion de la tabla en SQLite desde DBF
    // Usamos CONTROLES.DBF que existe en samples/
    lTableImport := TableImport( oDbSQLite, path() + "/CONTROLES.DBF" )

    if lTableImport
        MsgInfo( "DBF importada exitosamente a SQLite" )
    else
        MsgInfo( "Error al importar DBF" )
    endif
    
    oDbSQLite:End()

return nil

Function TableImport( oDbSQLite, cDbf )
   
    local oWnd, oProg
    local lExit := .t.
    local nRecCount
    
    if ! File( cDbf )
        MsgStop( "No existe el archivo: " + cDbf )
        return .f.
    endif
    
    dbUseArea( .t.,, cDbf, "TEMP_DBF", .t. )
    nRecCount := TEMP_DBF->( LastRec() )
    dbCloseArea()

    DEFINE WINDOW oWnd TITLE "Importando DBF a SQLite: " + FileNoPath( cDbf ) ;
        FROM 200, 200 TO 320, 600
       
    @ 40, 20 PROGRESS oProg POSITION 0 SIZE 360, 20 OF oWnd
    oProg:SetRange( 0, nRecCount )
    
    oWnd:Center()
    oWnd:Show()
    PUMPEVENTS()
 
    lExit := oDbSQLite:ImportFromDBF( cDbf, { | nDone | oProg:Update( nDone ) } )
    
    oWnd:End()
    
Return lExit   
