#include "FiveMac.ch"

//----------------------------------------------------------------------------//

function Main()

    local oSql
    local cSqlFile := path() + "/test_excel.db"
    local cXlsx := path() + "/test_sqlite.xlsx"

    if File( cSqlFile )
    FErase( cSqlFile )
    endif

    oSql := TSQLite():New( cSqlFile )
   
    oSql:CreateTable( "Clientes", { { "NOMBRE", "C", 50, 0 }, ;
        { "SALDO",  "N", 10, 2 }, ;
        { "FECHA",  "D",  8, 0 }, ;
        { "VIP",    "L",  1, 0 } } )

    oSql:TableUse( "Clientes" )
   
    oSql:Insert( { "NOMBRE" => "Steve Jobs",   "SALDO" => 150000.50, "FECHA" => Date(), "VIP" => .T. } )
    oSql:Insert( { "NOMBRE" => "Tim Cook",     "SALDO" => 85000.00,  "FECHA" => Date()-5, "VIP" => .T. } )
    oSql:Insert( { "NOMBRE" => "Jony Ive",     "SALDO" => 0.00,      "FECHA" => Date()-20, "VIP" => .F. } )

    // Refrescamos la query del table use
    oSql:TableUse( "Clientes" )

    MsgInfo( "Exportando tabla SQLite a XLSX..." )

    if FMsqlitetoxlsx( cXlsx, oSql )
    MsgInfo( "¡Exportación SQLite completada!" + hb_eol() + ;
        "Archivo: " + cXlsx )
    else
    MsgAlert( "Error en la exportación" )
    endif

    oSql:End()

return nil

//----------------------------------------------------------------------------//
