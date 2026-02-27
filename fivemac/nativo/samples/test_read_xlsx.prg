#include "FiveMac.ch"
#include "hbxlsxwriter.ch"

function Main()
    local oReader
    local cFile := Path() + "/test_final.xlsx"
    local aSheets, aData
    local nRow, nCol

    if !File( cFile )
    MsgInfo( "El archivo " + cFile + " no existe. Por favor, ejecuta primero test_xlsx." )
    return nil
    endif

    // Crear el lector
    oReader := XLSXReader():New()
    
    // Abrir el archivo
    oReader:Open( cFile )
    
    // Obtener lista de hojas
    aSheets := oReader:WorkSheetList()
    
    if Len( aSheets ) > 0
    MsgInfo( "Hojas encontradas: " + hb_ValToExp( aSheets ) )
        
    // Leer la primera hoja
    aData := oReader:WorkSheet( aSheets[1] )
        
    if Len( aData ) > 0
    MsgInfo( "Leidas " + hb_ntos( Len( aData ) ) + " filas." )
           
    // Mostrar un poco del contenido para verificar
    for nRow := 1 to Min( 5, Len( aData ) )
    for nCol := 1 to Min( 5, Len( aData[nRow] ) )
    if aData[nRow][nCol] != nil
    ? "Fila " + hb_ntos(nRow) + ", Col " + hb_ntos(nCol) + ": " + hb_ValToStr( aData[nRow][nCol] )
    endif
    next
    next
    else
    MsgInfo( "La hoja " + aSheets[1] + " esta vacia." )
    endif
    else
    MsgInfo( "No se encontraron hojas en " + cFile )
    endif

    oReader:Close()
    
return nil
