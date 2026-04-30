#include "FiveMac.ch"

function Main()

    local oWnd, oWeb, oBtn
    local cUrl := "http://localhost:8080/report"
    local cPdf := GetEnv( "TMPDIR" ) + "/nicegui_report.pdf"

    DEFINE WINDOW oWnd TITLE "NiceGUI -> PDF Bridge" SIZE 850, 700 NOFLIPPED 

    @ 10, 10 SAY "Paso 1: Inicia el servidor Python (report_server.py)" OF oWnd SIZE 400, 20
    @ 35, 10 SAY "Paso 2: Pulsa 'Cargar Reporte'" OF oWnd SIZE 400, 20

    @ 70, 10 WEBVIEW oWeb SIZE 830, 550 OF oWnd
   
    @ 630, 20 BUTTON "Cargar Reporte" ACTION oWeb:SetURL( cUrl ) SIZE 150, 30 OF oWnd
   
    @ 630, 180 BUTTON "Exportar a PDF" ;
        ACTION ( oWeb:SaveToPDF( cPdf ), MsgInfo( "PDF Generado en: " + cPdf ) ) ;
        SIZE 150, 30 OF oWnd

    ACTIVATE WINDOW oWnd

return nil
