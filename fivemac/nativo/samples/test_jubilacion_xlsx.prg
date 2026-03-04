#include "FiveMac.ch"

//----------------------------------------------------------------------------//

function Main()

    local oSql
    local cSqlFile := path() + "/jubilacion.db"
    local cXlsx := path() + "/ipcs_jubilacion.xlsx"
    local nStart, nEnd

    if ! File( cSqlFile )
    MsgAlert( "No se encuentra el archivo: " + cSqlFile )
    return nil
    endif

    oSql := TSQLite():New( cSqlFile )
   
    if empty( oSql:hDB )
    MsgAlert( "Error al abrir la base de datos" )
    return nil
    endif

    // Seleccionamos la tabla ipc_indices
    oSql:TableUse( "ipc_indices" )

    MsgInfo( "Exportando tabla 'ipc_indices' de jubilacion.db..." + hb_eol() + ;
        "Registros a procesar: " + AllTrim( Str( oSql:RecCount() ) ) )

    nStart := Seconds()
   
    if FMsqlitetoxlsx( cXlsx, oSql )
    nEnd := Seconds()
      
    MsgInfo( "¡Exportación completada con éxito!" + hb_eol() + ;
        "Archivo: " + cXlsx + hb_eol() + ;
        "Tiempo empleado: " + AllTrim( Str( nEnd - nStart, 10, 3 ) ) + " segundos", ;
        "Rendimiento FiveMac" )
    else
    MsgAlert( "Error en la exportación" )
    endif

    oSql:End()

return nil

//----------------------------------------------------------------------------//
