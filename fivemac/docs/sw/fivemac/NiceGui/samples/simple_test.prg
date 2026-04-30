#include "FiveMac.ch"

FUNCTION Main()
    local oPrinter
    
    // Create the document using the helper function
    oPrinter := CreaDocument()
    
    // Launch the Native Preview (defined in TNicePrinter class)
    oPrinter:NativoPreview()

RETURN NIL

Function CreaDocument()
    local oPrinter, oPage1, oPage2
    local oLabel1, oLabel2, oLabel3, oLabel4, oLabel5

    // Create Printer (Document) - Root Object (nil parent)
    oPrinter := TNicePrinter():New( nil, "A4" )
    oPrinter:SetZoom( 0.5 ) // Default Zoom for Native Preview

    // --- PAGE 1 ---
    oPage1 := TNicePrintPage():New( oPrinter ) 
    
    oLabel1   := TNiceLabel():New( oPage1, "PAGINA 1", "text-h3", "font-weight: bold; margin-bottom: 20px;" )
    oLabel2   := TNiceLabel():New( oPage1, "Este es el contenido de la primera página (Generado por TNiceLabel dentro de TNicePrintPage).", "text-body1", "margin-bottom: 10px;" )
    oLabel3   := TNiceLabel():New( oPage1, "Hola desde TNiceLabel Real (Código Nativo)", "text-h4 text-primary", "margin-top: 20px; font-weight: bold;" )

    // --- PAGE 2 ---
    oPage2 := TNicePrintPage():New( oPrinter ) 

    oLabel4   := TNiceLabel():New( oPage2, "PAGINA 2", "text-h3", "font-weight: bold; margin-bottom: 20px;" )
    oLabel5   := TNiceLabel():New( oPage2, "Este es el contenido de la segunda página (También TNiceLabel).", "text-body1", "" )

Return oPrinter