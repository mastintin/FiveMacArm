#include "FiveMac.ch"
#include "Nice.ch"

FUNCTION Main()
    local oWnd, oBtnPrint, oBtnPreview

    // 1. Native Launcher Window (Small)
    DEFINE WINDOW oWnd TITLE "Report Launcher" SIZE 400, 240 NOFLIPPED 

    @ 60, 50 BUTTON oBtnPreview PROMPT "Previsualizar Factura" SIZE 300, 40 OF oWnd ;
        ACTION ShowPreview()

    @ 110, 50 BUTTON oBtnPrint PROMPT "Generar PDF Directo" SIZE 300, 40 OF oWnd ;
        ACTION PrintDirect()

    ACTIVATE WINDOW oWnd CENTERED
RETURN NIL

// -----------------------------------------------------------------------------------------
// 2. Report Content Definition (Decoupled)
// -----------------------------------------------------------------------------------------
// Receives the Printer object to populate
FUNCTION BuildReport( oPrinter )
    local oPrnPage1, oPrnPage2
    local oHdr, oGrid, oStack, oStack2, oStack3

    // --- Page 1 ---
    NICE PRINT PAGE oPrnPage1 OF oPrinter
      
    // Header
    DEFINE NICE HSTACK oHdr OF oPrnPage1 CLASS "p-8 mb-8 rounded" ALIGN "center" JUSTIFY "between" BGCOLOR "blue-100"
    NICE SAY PROMPT "FACTURA" SIZE "4xl" BOLD COLOR "blue-900" OF oHdr
         
    DEFINE NICE VSTACK oStack OF oHdr ALIGN "end" GAP "none"
    NICE SAY PROMPT "Empresa Modelo S.L." BOLD OF oStack
    NICE SAY PROMPT "C/ Ejemplo, 123" SIZE "sm" OF oStack
    NICE SAY PROMPT "28080 Madrid" SIZE "sm" OF oStack
    END NICE VSTACK
    END NICE HSTACK
      
    // Invoice Details
    DEFINE NICE GRID oGrid OF oPrnPage1 COLS 2 CLASS "mb-8 p-4" GAP "xl"
    DEFINE NICE VSTACK oStack2 OF oGrid GAP "sm"
    NICE SAY PROMPT "Cliente:" BOLD COLOR "gray-600" OF oStack2
    NICE SAY PROMPT "Juan Pérez García" SIZE "lg" OF oStack2
    END NICE VSTACK
         
    DEFINE NICE VSTACK oStack3 GAP "sm" ALIGN "end" OF oGrid
    NICE SAY PROMPT "Fecha: " + DToC( Date() ) BOLD OF oStack3
    NICE SAY PROMPT "Num: 2024/0001" BOLD OF oStack3
    END NICE VSTACK
    END NICE GRID
      
    // Lines
    DEFINE NICE VSTACK GAP "sm" CLASS "border-t-2 border-gray-200 pt-4" OF oPrnPage1
    NICE SAY PROMPT "Servicios de Consultoría ......................... 1.000,00 €" OF oPrnPage1
    NICE SAY PROMPT "Mantenimiento Anual ................................ 500,00 €" OF oPrnPage1
    END NICE VSTACK

    END NICE PRINT PAGE

    // --- Page 2 ---
    NICE PRINT PAGE oPrnPage2 OF oPrinter
      
    NICE SAY PROMPT "Términos y Condiciones" SIZE "2xl" BOLD CLASS "mb-4" OF oPrnPage2
      
    DEFINE NICE VSTACK GAP "md" OF oPrnPage2
    NICE SAY PROMPT "1. El pago se realizará en 30 días." OF oPrnPage2
    NICE SAY PROMPT "2. Garantía de satisfacción." OF oPrnPage2
    NICE SAY PROMPT "3. Jurisdicción: Madrid." OF oPrnPage2
    END NICE VSTACK

    END NICE PRINT PAGE

RETURN nil

// -----------------------------------------------------------------------------------------
// 3. Preview Action
// -----------------------------------------------------------------------------------------
FUNCTION ShowPreview()
    local oPrinter
    
    // Create Printer
    oPrinter := TNicePrinter():New( nil, "A4" )
    
    // Build Content
    BuildReport( oPrinter )
    
    // Launch Native Preview
    oPrinter:NativoPreview()
RETURN nil

// -----------------------------------------------------------------------------------------
// 4. Direct PDF Generation (Hidden Window)
// -----------------------------------------------------------------------------------------
FUNCTION PrintDirect()
  
    oPrinter := TNicePrinter():New( nil, "A4" )
    BuildReport( oPrinter )
    cPdfPath := path() + "/invoice.pdf"

    oPrinter:SaveToPDF( cPdfPath )
   
RETURN nil
