#include "FiveMac.ch"

//----------------------------------------------------------------------------//

function Main()

    local cFile := path()+"/test_final.xlsx"
    local oReader
    local aSheets, nRow := 0, xVal
    local cOut := ""

    if ! File( cFile )
        MsgInfo( "El archivo '" + cFile + "' no existe en el directorio actual" )
        return nil
    endif

    oReader := TXlsxReader():New( cFile )

    if empty( oReader:hReader )
        MsgInfo( "ERROR: XlsxioReadOpen devolvió 0 para '" + cFile + "'" )
        return nil
    endif

    cOut += "Versión de XLSX I/O: " + oReader:GetVersion() + hb_eol()

    aSheets := oReader:ListSheets()
    cOut += "Hojas encontradas: " + hb_ValToExp( aSheets ) + hb_eol()

    if len( aSheets ) > 0
        if oReader:OpenSheet( aSheets[ 1 ] )
            cOut += "Contenido de la primera hoja (" + aSheets[ 1 ] + "):" + hb_eol()
            while oReader:NextRow() .and. nRow < 5
                nRow++
                cOut += "Fila " + hb_ntos( nRow ) + ": "
                while ( xVal := oReader:NextCell() ) != nil
                    cOut += "[" + hb_ValToStr( xVal ) + "] "
                end
                cOut += hb_eol()
            end
            oReader:CloseSheet()
        else
            cOut += "ERROR: No se pudo abrir la hoja '" + aSheets[ 1 ] + "'" + hb_eol()
        endif
    endif

    oReader:End()

    MsgInfo( cOut, "Depuración TXlsxReader" )

return nil

//----------------------------------------------------------------------------//
