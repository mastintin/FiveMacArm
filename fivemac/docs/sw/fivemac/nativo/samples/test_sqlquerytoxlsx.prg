#include "FiveMac.ch"

//----------------------------------------------------------------------------//

function Main()

    local oSql
    local cSqlFile := path() + "/test_excel.db"
    local cXlsx := path() + "/test_query.xlsx"
    local cSql := "SELECT NOMBRE, SALDO, SALDO * 0.21 AS IVA FROM Clientes"

    oSql := TSQLite():New( cSqlFile )
   
    if empty( oSql:hDB )
    MsgAlert( "Ejecuta primero test_sqlitetoxlsx para crear la base de datos" )
    return nil
    endif

    MsgInfo( "Exportando resultado de consulta SQL a XLSX..." )

    // Usamos la nueva función FMsqlquerytoxlsx pasándole el SQL
    if FMsqlquerytoxlsx( cXlsx, oSql, cSql )
    MsgInfo( "¡Consulta exportada con éxito!" + hb_eol() + ;
        "SQL: " + cSql + hb_eol() + ;
        "Archivo: " + cXlsx )
    else
    MsgAlert( "Error en la exportación de la consulta" )
    endif

    oSql:End()

return nil

//----------------------------------------------------------------------------//
