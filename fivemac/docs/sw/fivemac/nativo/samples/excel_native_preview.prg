#include "FiveMac.ch"

function Main()

    local oWnd, oQL

    DEFINE WINDOW oWnd TITLE "FiveMac: QuickLook Preview"  NOFLIPPED ;
        SIZE 900, 700

    @ 10, 10 BUTTON "Abrir Archivo..." SIZE 130, 25 OF oWnd ;
        ACTION LoadFile( oQL )

    @ 10, 150 BUTTON "Zoom +" SIZE 80, 25 OF oWnd ;
        ACTION oQL:ZoomIn()

    @ 10, 240 BUTTON "Zoom -" SIZE 80, 25 OF oWnd ;
        ACTION oQL:ZoomOut()

    @ 10, 330 BUTTON "100%" SIZE 60, 25 OF oWnd ;
        ACTION oQL:SetZoom( 1.0 )

    
    @ 10, 420 BUTTON "Abrir Excel" SIZE 130, 25 OF oWnd ;
        ACTION MiExcelView()

    @ 45, 0 QUICKLOOK oQL SIZE oWnd:nWidth, oWnd:nHeight - 45 OF oWnd

    oWnd:Activate()

return nil

function LoadFile( oQL )

    local cFile := ChooseFile( "Seleccione un archivo", "xlsx,xls,pdf,txt,png,jpg" )

    if ! Empty( cFile )
        oQL:SetFile( cFile )
    endif

return nil


function MiExcelView()
    local cFile := ChooseFile( "Seleccione un archivo", "xlsx" )
    msginfo(cFile)
    if ! Empty( cFile )
        AbrirExcel( cFile )
    endif
return nil   