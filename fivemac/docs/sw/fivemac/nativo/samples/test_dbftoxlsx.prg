#include "FiveMac.ch"

//----------------------------------------------------------------------------//

function Main()

    local cDbf := path() + "/test.dbf"
    local cXlsx := path() + "/test_dbf.xlsx"
    local nSeconds := 0

    // 1. Crear un DBF de prueba si no existe
    if ! File( cDbf )
        dbCreate( cDbf, { { "NOMBRE", "C", 20, 0 }, ;
            { "EDAD",   "N",  3, 0 }, ;
            { "FECHA",  "D",  8, 0 }, ;
            { "ACTIVO", "L",  1, 0 } } )
    endif

    use ( cDbf ) alias TEST shared
   
    if TEST->( LastRec() ) == 0
        TEST->( dbAppend() )
        TEST->NOMBRE := "Manuel"
        TEST->EDAD   := 45
        TEST->FECHA  := Date()
        TEST->ACTIVO := .T.
      
        TEST->( dbAppend() )
        TEST->NOMBRE := "Anton"
        TEST->EDAD   := 38
        TEST->FECHA  := Date() - 10
        TEST->ACTIVO := .F.
    endif

    // 2. Probar la nueva función de conversión
    MsgInfo( "Convirtiendo DBF a XLSX..." )
    nSeconds := Seconds()

    if FMdbftoxlsx( cXlsx, "TEST" )
        nSeconds:= Seconds() - nSeconds 
        MsgInfo( "¡Convertido con éxito!" + hb_eol() + ;
            "Archivo: " + cXlsx + hb_eol() + ;
            "Tiempo: " + str(nSeconds) + " segundos" )
      
        // Intentar abrirlo
        // open_browser_url( "file://" + cXlsx ) // No tenemos esta herramienta pero el usuario puede abrirlo
    else
        MsgAlert( "Error en la conversión" )
    endif

    close TEST

return nil

//----------------------------------------------------------------------------//
