#include "FiveMac.ch"
#include "mysql.ch"

function Main()

    local oDbMySQL, lTableImport
  
    // 1. acedemos a MySql
    oDbMySQL := TMySQL():New( "134.0.10.187", "mastintin", "Mas_0210199999", "testfivemac" )
    if oDbMySQL == nil .or. Empty( oDbMySQL:oServer )
        MsgInfo( "No se pudo abrir la base de datos MySQL" )    
        Return .f.
    endif

    // 2. proceso de creacion de la tabla en MySQL desde DBF
    // Usamos CONTROLES.DBF que existe en samples/
    lTableImport := TableImport( oDbMySQL, path() + "/CONTROLES.DBF" )

    if lTableImport
        MsgInfo( "DBF importada exitosamente a MySQL" )
    else
        MsgInfo( "Error al importar DBF" )
    endif
    
    oDbMySQL:End()

return nil

Function TableImport( oDbMySQL, cDbf )
   
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

    DEFINE WINDOW oWnd TITLE "Importando DBF: " + FileNoPath( cDbf )  NOFLIPPED ;
        FROM 200, 200 TO 320, 600
       
    @ 40, 20 PROGRESS oProg POSITION 0 SIZE 360, 20 OF oWnd
    oProg:SetRange( 0, nRecCount )
    
    oWnd:Center()
    oWnd:Show()
    PUMPEVENTS()
 
    lExit := oDbMySQL:ImportFromDBF( cDbf, { | nDone | oProg:Update( nDone ) } )
    
    oWnd:End()
    
Return lExit   