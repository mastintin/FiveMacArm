#include "FiveMac.ch"

//----------------------------------------------------------------------------//

function Main()

    local oWorkbook, oSheet, oFormat
    local cFile := path()+"/test_created.xlsx"

    oWorkbook := Workbook_New( cFile )
   
    if empty( oWorkbook )
    MsgInfo( "Error creando el libro" )
    return nil
    endif

    oFormat := Workbook_Add_Format( oWorkbook )
    Format_Set_Bold( oFormat )
    Format_Set_Font_Color( oFormat, 0xFF0000 ) // Red (ABGR or RGB? check documentation)

    oSheet := Workbook_Add_Worksheet( oWorkbook, "Mi Hoja" )

    Worksheet_Write_String( oSheet, 0, 0, "Hola desde FiveMac", oFormat )
    Worksheet_Write_Number( oSheet, 1, 0, 123.45, nil )
    Worksheet_Write_Datetime( oSheet, 2, 0, Date(), nil )

    Workbook_Close( oWorkbook )

    MsgInfo( "Archivo '" + cFile + "' creado con éxito" )

    // Ahora intentamos leerlo con el nuevo lector
    TestRead( cFile )

return nil

//----------------------------------------------------------------------------//

static function TestRead( cFile )

    local oReader := TXlsxReader():New( cFile )
    local cOut := "Leyendo archivo recién creado:" + hb_eol()
    local xVal

    if oReader:OpenSheet( "Mi Hoja" )
    while oReader:NextRow()
    while ( xVal := oReader:NextCell() ) != nil
    cOut += "[" + hb_ValToStr( xVal ) + "] "
    end
    cOut += hb_eol()
    end
    oReader:CloseSheet()
    endif
    oReader:End()

    MsgInfo( cOut, "Resultado Lectura" )

return nil

//----------------------------------------------------------------------------//
