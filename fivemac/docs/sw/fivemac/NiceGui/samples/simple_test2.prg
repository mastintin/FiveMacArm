#include "FiveMac.ch"
#include "Nice.ch"

FUNCTION Main()
    local oWnd
    local oPage, oFrame, oRow, oHeader
    local cReportHtml, cReportFile
    local oPrinter

    oPrinter := TNicePrinter():New( nil, "A4" ) 
    CreaDocument( oPrinter )
    
    // Use the new simplified Preview method
    oPrinter:Preview()

RETURN NIL

Function CreaDocument( oPrinter )
    local oPage1,oPage2
    local oLabel1,oLabel2,oLabel3,oLabel4

    // 1. Generate Report Content (Using TNicePrinter)
    // ----------------------------------------------
   
    // Page 1
    oPage1 := TNicePrintPage():New( oPrinter )
    oLabel1 := TNiceLabel():New( oPage1, "INFORME NATIVO (PAGE 1)", "text-h3", "font-weight: bold; margin-bottom: 20px;" )
    oLabel2 := TNiceLabel():New( oPage1, "Este contenido está dentro de un IFRAME.", "text-body1" )

    // Page 2
    oPage2 := TNicePrintPage():New( oPrinter )
    oLabel3 := TNiceLabel():New( oPage2, "INFORME NATIVO (PAGE 2)", "text-h3", "font-weight: bold; margin-bottom: 20px;" )
    oLabel4 := TNiceLabel():New( oPage2, "Segunda página de prueba.", "text-body1" )

Return nil
