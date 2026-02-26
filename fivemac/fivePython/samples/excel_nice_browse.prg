#include "FiveMac.ch"
#include "Nice.ch"

static oPython

function Main()

    local oWnd, oPage
    local cFile := ""
    local cSheet := "Hoja1"
    local cRange := "B5:Z100"
    local oPanel

    // 1. Inicializar Python
    oPython := TPython():New()
    if !oPython:IsReady()
        MsgStop( "Python no está listo" )
        return nil
    endif

    DEFINE WINDOW oWnd TITLE "Excel Browse con NiceGUI y Pandas" SIZE 1100, 750 FLIPPED

    // Parte NATIVA (Selector)
    @ 20, 20 SAY "Archivo Excel:" OF oWnd SIZE 100, 20
    @ 20, 130 GET cFile OF oWnd SIZE 400, 24 
   
    @ 20, 540 BUTTON "Seleccionar..." OF oWnd SIZE 120, 30 ;
        ACTION ( cFile := ChooseFile( "Seleccione un Excel", "*.xlsx" ) )

    @ 50, 20 SAY "Hoja:" OF oWnd SIZE 50, 20
    @ 50, 100 GET cSheet OF oWnd SIZE 150, 24

    @ 50, 270 SAY "Rango:" OF oWnd SIZE 60, 20
    @ 50, 340 GET cRange OF oWnd SIZE 150, 24

    @ 45, 540 BUTTON "EJECUTAR BROWSE" OF oWnd SIZE 150, 40 ;
        ACTION ProcessData( oPage, cFile, cSheet, cRange )

    @ 45, 700 BUTTON "TEST TABLA" OF oWnd SIZE 120, 40 ;
        ACTION TestTable( oPage )

    @ 45, 830 BUTTON "DUMP HTML" OF oWnd SIZE 120, 40 ;
        ACTION MemoWrit( hb_DirBase() + "debug_excel.html", oPage:GetHtml() )

    // Área para NiceGUI
    oPanel := TPanel():New( 100, 20, 1060, 630, oWnd )
    DEFINE NICE PAGE oPage OF oPanel
   
    NICE SAY PROMPT "Seleccione un archivo y haga clic en Ejecutar para ver los datos." CLASS "text-h5 text-center q-mt-xl" OF oPage

    oPage:Activate()

    ACTIVATE WINDOW oWnd CENTERED

return nil

//----------------------------------------------------------------------------//

procedure ProcessData( oPage, cFile, cSheet, cRange )
    local cJsonStr, aData := {}
    local oTable, cKey
    local aAux := {}
    local hAux
    if Empty( cFile )
        MsgStop( "Debe seleccionar un archivo" )
        return
    endif

    // Llamada a Python
    cJsonStr := oPython:Call( "excel_test", "read_excel_adv", cFile, cSheet, cRange )
    //MemoWrit( hb_DirBase() + "debug_py_json.txt", cJsonStr )
   
    if Empty( cJsonStr ) .or. "error" $ Lower( cJsonStr )
        MsgStop( "Error en Python: " + cValToChar( cJsonStr ) )
        return
    endif

    // "Despiezamos" el JSON en Harbour
    hb_jsonDecode( cJsonStr, @aData )

    if ValType( aData ) != "A" .or. Len( aData ) == 0
        MsgStop( "No se recibieron datos válidos o el archivo está vacío." )
        return
    endif

    // Limpiar UI anterior
    oPage:aControls := {}
    oPage:aAllControls := {}

    // Crear Tabla
    oTable := TNiceTable():New( oPage, "Datos Excel: " + hb_FNameName( cFile ) )

    // 1. Extraer COLUMNAS dinámicamente
    if ValType( aData[ 1 ] ) == "H"
        for each cKey in hb_HKeys( aData[ 1 ] )
            oTable:AddCol( cKey, cKey, cKey )
        next
    endif
  

    // 2. Establecer datos (NiceTable se encarga de convertirlos a JSON seguro)
    oTable:SetData( aData )

    // Refrescar página
    oPage:Activate()

return

//----------------------------------------------------------------------------//

procedure TestTable( oPage )
    local oTable
    
    oPage:aControls := {}
    oPage:aAllControls := {}

    oTable := TNiceTable():New( oPage, "Test Estático" )
    oTable:AddCol( "id", "ID", "id" )
    oTable:AddCol( "name", "Nombre", "name", , .T. )

    oTable:SetData( { ;
        { "id" => 1, "name" => "Manuel (OK)" }, ;
        { "id" => 2, "name" => "Juan (OK)" } ;
        } )

    oPage:Activate()
return

//----------------------------------------------------------------------------//

static function ChooseFile( cTitle, cFilter )
return cGetFile( cFilter, cTitle )
