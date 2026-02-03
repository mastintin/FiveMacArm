#include "FiveMac.ch"
#include "Nice.ch"

function Main()

    local oWnd, oPage, oGrid, oCard, oChart
    local cPdf := path() + "/harbour_native_report.pdf"
   
    // 1. Create a Standard FiveMac Window
    DEFINE WINDOW oWnd TITLE "Harbour Serverless Report Demo" SIZE 900, 700 FLIPPED
   
    // 2. Wrap it with a NicePage (Serverless - using local assets)
    DEFINE NICE PAGE oPage OF oWnd
   
    // 3. Build the Report Content using Commands
    // Wrap everything in a VSTACK to ensure vertical separation
    DEFINE NICE VSTACK oMain GAP "lg" CLASS "full-width" OF oPage

    // Header Row
    DEFINE NICE HSTACK oHdr JUSTIFY "between" ALIGN "center" BGCOLOR "indigo-900" CLASS "text-white p-4 rounded-lg" OF oMain
    NICE SAY PROMPT "xlsJubila" SIZE "2xl" BOLD OF oHdr
    NICE SAY PROMPT "INFORME DE SIMULACIÓN - " + DToC( Date() ) SIZE "sm" CLASS "italic" OF oHdr
    END NICE HSTACK

    // Metrics Grid
    DEFINE NICE GRID oGrid COLS 3 OF oMain
      
    DEFINE NICE CARD oCardA BGCOLOR "green-50" OF oGrid
    NICE SAY PROMPT "Resultados Escenario A" SIZE "xs" COLOR "green-700" BOLD OF oCardA
    NICE SAY PROMPT "2.415,17 €" SIZE "2xl" COLOR "green-900" BOLD OF oCardA
    END NICE CARD

    DEFINE NICE CARD oCardB BGCOLOR "blue-50" OF oGrid
    NICE SAY PROMPT "Resultados Escenario B" SIZE "xs" COLOR "blue-700" BOLD OF oCardB
    NICE SAY PROMPT "2.342,31 €" SIZE "2xl" COLOR "blue-900" BOLD OF oCardB
    END NICE CARD
         
    DEFINE NICE CARD oCardC BGCOLOR "orange-50" OF oGrid
    NICE SAY PROMPT "Diferencia Mensual" SIZE "xs" COLOR "orange-700" BOLD OF oCardC
    NICE SAY PROMPT "72,86 €" SIZE "2xl" COLOR "orange-900" BOLD OF oCardC
    END NICE CARD

    END NICE GRID

    // Chart Section
    DEFINE NICE CARD oCardPlot OF oMain
    NICE SAY PROMPT "Proyección Comparativa de Pensiones" SIZE "lg" BOLD CLASS "mb-4" OF oCardPlot
         
    DEFINE NICE CHART oChart WIDTH 800 HEIGHT 300 OF oCardPlot
    NICE CHART oChart SET TITLE "Pensión Mensual Proyectada"
    NICE CHART oChart SET XAXIS DATA {"Actual", "A 24m", "A 48m"}
    NICE CHART oChart ADD SERIES DATA {2100, 2415, 2600} TYPE "line" SMOOTH AREA
    END NICE CHART
    END NICE CARD

    END NICE VSTACK

    // 4. Add action buttons to the window (not part of the report HTML)
    @ 640, 20 BUTTON "Generar PDF" ;
        ACTION ( oPage:SaveToPDF( cPdf ), MsgInfo( "PDF Generado en: " + cPdf ) ) ;
        SIZE 150, 30 OF oWnd

    // 5. Initialize the Page (Generates HTML and loads it into WebView)
    oPage:Activate()

    ACTIVATE WINDOW oWnd

return nil
