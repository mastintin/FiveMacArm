#include "FiveMac.ch"
#include "SwiftControls.ch"

function Main()

    local oWnd, oBtn, oChart
    local cPdf := GetEnv( "TMPDIR" ) + "/chart_native.pdf"
    local cJson := '[{"label":"Enero","value":120,"group":"Sales"},{"label":"Febrero","value":200,"group":"Sales"},{"label":"Marzo","value":150,"group":"Sales"}]'

    DEFINE WINDOW oWnd TITLE "SwiftUI PDF Export Test" SIZE 600, 500

    @ 20, 20 SWIFTCHART oChart SIZE 560, 300 DATA cJson TYPE "bar" OF oWnd
   
    @ 350, 240 BUTTON oBtn PROMPT "Export to PDF" ;
        ACTION SaveChartToPDF( oChart, cPdf ) ;
        OF oWnd

    ACTIVATE WINDOW oWnd

return nil

function SaveChartToPDF( oChart, cPdf )

    local oPDF := TSwiftPDF():New()
   
    // We pass the oChart object (TSwiftChart) which has an nId
    // TSwiftPDF:SaveView( oView, cPath )
   
    oPDF:SaveView( oChart, cPdf )
   
    WaitRun( "open " + cPdf )

return nil
