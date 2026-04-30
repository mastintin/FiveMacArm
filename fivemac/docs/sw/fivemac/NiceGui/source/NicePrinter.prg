#include "Nice.ch"

// NicePrinter.prg - HTML/CSS Paged Media Printer

//----------------------------------------------------------------------------//
// Nice Printer (The Document)
//----------------------------------------------------------------------------//

CLASS TNicePrinter FROM TNiceContainer
    DATA cFormat    INIT "A4"
    DATA lLandscape INIT .F.
    DATA aAllControls INIT {}
    DATA nZoom      INIT 1.0  // Zoom factor (1.0 = 100%)
    DATA cPath       INIT ""
   
    METHOD New( oParent, cFormat, lLandscape )
    METHOD GetResPath()
    METHOD GetAppPath()
    METHOD GetHtml()
    METHOD GetDocHtml()
    METHOD GetCss()
    METHOD Register( oControl ) INLINE AAdd( ::aAllControls, oControl )
    METHOD SetZoom( n ) INLINE ::nZoom := n
    METHOD Preview()
    METHOD NativoPreview()
    METHOD SaveToPDF( cPath )

ENDCLASS

//----------------------------------------------------------------------------------------- 

METHOD Preview() CLASS TNicePrinter
    local oWnd, oPage, oHeader, oFrame
    local cHtmlContent := ::GetDocHtml()
    local oSelf := Self

    DEFINE WINDOW oWnd TITLE "Vista Previa Web (IFrame)" SIZE 1000, 800 FLIPPED

    oPage := TNicePage():New( oWnd )
    
    // 1. Header (Toolbar)
    DEFINE NICE HEADER oHeader CLASS "bg-grey-3 text-black" OF oPage

    // Buttons
    TNiceButton():New( oHeader, "Close", {|| oWnd:End() }, "close",, "margin-right: 20px;" )
    
    TNiceButton():New( oHeader, "<<", nil,,,"margin-right: 5px;", "document.getElementById('myframe').contentWindow.niceScrollPage('first')" )
    TNiceButton():New( oHeader, "<",  nil,,,"margin-right: 5px;", "document.getElementById('myframe').contentWindow.niceScrollPage('-1')" )
    TNiceButton():New( oHeader, ">",  nil,,,"margin-right: 5px;", "document.getElementById('myframe').contentWindow.niceScrollPage('1')" )
    TNiceButton():New( oHeader, ">>",   nil,,,"margin-right: 20px;", "document.getElementById('myframe').contentWindow.niceScrollPage('last')" )
    
    // Zoom Actions: Update Zoom, Update IFrame Content, Reload Page
    /*   TNiceButton():New( oHeader, "Zoom +", {|| ;
        oSelf:SetZoom( oSelf:nZoom + 0.1 ),;
        oSelf:cStyle:= "transform: scale("+Str(oSelf:nZoom)+"); transform-origin: 0 0;",;     
        oFrame:cStyle := "transform: scale(1.0); transform-origin: 0 0;",;  
        oPage:activate() ;
        }, "zoom_in",, "margin-right: 5px;" )
*/

    TNiceButton():New( oHeader, "Zoom +", {|| ;
        oSelf:SetZoom( oSelf:nZoom + 0.1 ),;
        oFrame:cHtmlContent:= ::GetHtml() ,;
        oPage:activate() ;
        }, "zoom_in",, "margin-right: 5px;" )


    TNiceButton():New( oHeader, "Zoom -", {|| ;
        oSelf:SetZoom( oSelf:nZoom - 0.1 ), ;
        oFrame:cHtmlContent:= ::GetHtml() ,;
        oPage:Activate() ;
        }, "zoom_out",, "margin-right: 5px;" ) 

  
    TNiceButton():New( oHeader, "Print", nil, "print",, "margin-right: 5px;", "document.getElementById('myframe').contentWindow.print()" )

    // 2. IFrame Content (Body)
    oFrame := TNiceIFrame():New( oPage, "", cHtmlContent, "100%", "100%" )
    oFrame:cPath := ::cPath
    oFrame:cId := "myframe"
    oFrame:cClass := "absolute-full" 
    oFrame:cStyle := "border: none; top: 0;" 

    ACTIVATE NICE PAGE oPage
    ACTIVATE WINDOW oWnd
return nil

//-----------------------------------------------------------------------------------------

METHOD NativoPreview( cFile ) CLASS TNicePrinter
    local oWnd, oWeb, oBtn
    local oSelf := Self
    
    if cFile == nil
    cFile := path() + "/invoice.pdf"
    endif

    DEFINE WINDOW oWnd TITLE "Vista Previa del Informe (Nativo)" SIZE 1000, 800 Flipped
    
    // --- Toolbar Area (Top) ---
    // Buttons Row: First <<, Prev <, Next >, Last >> | Print | Close | Zoom +, -
    
    @ 10, 20 BUTTON oBtn PROMPT "<<" OF oWnd SIZE 40, 24 ACTION oWeb:ScriptCallMethod("niceScrollPage('first')")
    @ 10, 65 BUTTON oBtn PROMPT "<"  OF oWnd SIZE 40, 24 ACTION oWeb:ScriptCallMethod("niceScrollPage('-1')")
    @ 10, 110 BUTTON oBtn PROMPT ">"  OF oWnd SIZE 40, 24 ACTION oWeb:ScriptCallMethod("niceScrollPage('1')")
    @ 10, 155 BUTTON oBtn PROMPT ">>" OF oWnd SIZE 40, 24 ACTION oWeb:ScriptCallMethod("niceScrollPage('last')")

    @ 10, 220 BUTTON oBtn PROMPT "Guardar PDF" OF oWnd SIZE 100, 24 ACTION ;
        ( oWeb:SaveToPDF( cFile ), MsgInfo("Guardado en: " + cFile) )

    @ 10, 330 BUTTON oBtn PROMPT "Cerrar" OF oWnd SIZE 80, 24 ACTION oWnd:End()

    @ 10, 450 BUTTON oBtn PROMPT "Zoom +" OF oWnd SIZE 60, 24 ACTION ;
        ( oSelf:SetZoom( oSelf:nZoom + 0.1 ), oWeb:SetHtml( oSelf:GetDocHtml(), oSelf:cPath ) )

    @ 10, 515 BUTTON oBtn PROMPT "Zoom -" OF oWnd SIZE 60, 24 ACTION ;
        ( oSelf:SetZoom( oSelf:nZoom - 0.1 ), oWeb:SetHtml( oSelf:GetDocHtml(), oSelf:cPath ) )

    // --- WebView Area (Below Toolbar) ---
    @ 50, 10 WEBVIEW oWeb SIZE oWnd:nWidth - 20, oWnd:nHeight - 60 OF oWnd
    oWeb:_nAutoResize( 18 ) // Width + Height
    
    oWeb:SetHtml( ::GetDocHtml(), ::cPath )

    ACTIVATE WINDOW oWnd
return nil

//-----------------------------------------------------------------------------------------

METHOD SaveToPDF( cFile ) CLASS TNicePrinter
    local oWndHidden, oWeb, oTimer
     
    if cFile == nil
    cFile := path() + "/invoice.pdf"
    endif
    
    // 2. Create Window OFF-SCREEN
    DEFINE WINDOW oWndHidden TITLE "Generando PDF..." SIZE 0, 0 FLIPPED
     
    // 3. Create WebView
    @ 0, 0 WEBVIEW oWeb SIZE 1000, 800 OF oWndHidden
    
    // 4. Load HTML
    oWeb:SetHtml( ::GetDocHtml(), ::cPath  )
       

    // 5. Use a Timer to wait for loading/rendering then save
    DEFINE TIMER oTimer INTERVAL 2 OF oWndHidden ;
        ACTION ( oWeb:SaveToPDF( cFile ), ;
        oTimer:DeActivate(), ;
        oWndHidden:End() )
    
    oTimer:Activate()
      
    // 6. Activate the window (Off-screen) to start the Cocoa loop
    ACTIVATE WINDOW oWndHidden
    
    // MsgInfo( "SaveToPDF Completed -> Returning .T." )
RETURN .T.





METHOD New( oParent, cFormat, lLandscape ) CLASS TNicePrinter
    if oParent != nil
    ::Super:New( oParent )
    else
    ::oParent := nil
    endif
    
    ::cFormat    := If( cFormat != nil, cFormat, "A4" )
    ::lLandscape := If( lLandscape != nil, lLandscape, .F. )
    
    ::cPath := ::GetResPath()
return Self

METHOD GetResPath() CLASS TNicePrinter
    local cResPath := path() + "/libs/"
 
    if hb_DirExists( path() + "/nicegui_dist" )
    cResPath := path() + "/nicegui_dist/"
    endif

    // If we are in a Mac App Bundle: Contents/MacOS/...
    // Resources are at Contents/Resources/nicegui
    if hb_DirExists( respath() + "/nicegui" )
    cResPath := respath() + "/nicegui/"
    endif
return "file://" + cResPath

METHOD GetAppPath() CLASS TNicePrinter
    local cPath := path()
    // If inside a bundle, go up 3 levels to reach the folder containing the .app
    // Contents/MacOS/
return cPath

METHOD GetHtml() CLASS TNicePrinter
    local cHtml := ""
   
    // Inject Print CSS
    cHtml += "<style>" + ::GetCss() + "</style>"
   
    // Container for pages
    cHtml += '<div class="nice-document">'
    cHtml += ::GetHtmlChildren()
    cHtml += '</div>'
   
return cHtml

METHOD GetDocHtml() CLASS TNicePrinter
    local cHtml := '<!DOCTYPE html>'
    cHtml += '<html><head>'
    
    // Inject Local Styles
    cHtml += '<link href="material-icons.css" rel="stylesheet" type="text/css">'
    cHtml += '<link href="quasar.prod.css" rel="stylesheet" type="text/css">'
    
    // Tailwind (Local)
    cHtml += '<link href="tailwind.min.css" rel="stylesheet">'
    
    cHtml += '<script>'
    cHtml += 'window.niceScrollPage = function(payload) {'
    cHtml += '  var pages = document.querySelectorAll(".nice-page");'
    cHtml += '  if (typeof window.curPage === "undefined") window.curPage = 0;'
    cHtml += '  if (payload === "first") { window.curPage = 0; }'
    cHtml += '  else if (payload === "last") { window.curPage = pages.length - 1; }'
    cHtml += '  else { window.curPage += parseInt(payload); }'
    cHtml += '  if (window.curPage < 0) window.curPage = 0;' 
    cHtml += '  if (window.curPage >= pages.length) window.curPage = pages.length - 1;' 
    cHtml += '  pages[window.curPage].scrollIntoView({ behavior: "smooth" });'
    cHtml += '};'
    cHtml += '</script>' 
    cHtml += '</head><body>'
    
    cHtml += ::GetHtml()
    
    cHtml += '</body></html>'
return cHtml

METHOD GetCss() CLASS TNicePrinter
    local cCss := ""
    local cWidth := "210mm"
    local cHeight := "297mm"
    local cTemp

    if ::cFormat == "Letter"
    cWidth := "8.5in"
    cHeight := "11in"
    endif
    
    if ::lLandscape
    cTemp := cWidth
    cWidth := cHeight
    cHeight := cTemp
    endif

    // Screen Styles (Paper Look)
    cCss += "@media screen {"
    cCss += "  body { background: #e0e0e0; -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; }"
    cCss += "  .nice-document { display: flex; flex-direction: column; align-items: center; padding: 20px; "
    if ::nZoom != 1.0
    cCss += "zoom: " + AllTrim(Str(::nZoom)) + ";"
    endif
    cCss += " }"
    cCss += "  .nice-page {"
    cCss += "    width: " + cWidth + ";"
    cCss += "    min-height: " + cHeight + ";"
    cCss += "    margin-bottom: 20px;"
    cCss += "    background: white;"
    cCss += "    box-shadow: 0 4px 10px rgba(0,0,0,0.2);"
    cCss += "    padding: 20px;" // Default internal padding
    cCss += "    box-sizing: border-box;"
    cCss += "  }"
    cCss += "}"

    // Print Styles (Native PDF/Print Dialog)
    // Print Styles (Native PDF/Print Dialog)
    // Print Styles (Native PDF/Print Dialog)
    cCss += "@media print {"
    cCss += "  body { -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; }"
    cCss += "  @page { size: " + cWidth + " " + cHeight + "; margin: 0; }"
    cCss += "  body { background: white; margin: 0; width: 100%; height: auto; }"
    cCss += "  .nice-document { display: block !important; float: none !important; position: static !important; overflow: visible !important; width: 100%; height: auto; padding: 0; }"
    cCss += "  .nice-page {"
    cCss += "    width: " + cWidth + ";"
    cCss += "    min-height: 290mm !important;" // Reduced from A4 full height to prevent overflow
    cCss += "    margin: 0;"
    cCss += "    box-shadow: none;"
    cCss += "    padding: 20px;" 
    cCss += "    display: block !important;"
    cCss += "    position: relative !important;"
    cCss += "    box-sizing: border-box !important;" // CRITICAL: Padding included in width/height
    cCss += "    page-break-after: always !important;" // ONLY break after
    cCss += "  }"
    cCss += "  .nice-page:last-child { page-break-after: auto !important; }" // No break after last page
    cCss += "  .nice-page + .nice-page { margin-top: 0 !important; }" // Remove redundant break-before
    cCss += "  .no-print, .q-btn, .q-drawer, .q-header, .q-footer { display: none !important; }"
    cCss += "  .q-page-container { padding: 0 !important; }"
    cCss += "}"

    // "Print Mode" Simulation (For SaveToPDF capture)
    cCss += "html.printing-mode, body.printing-mode {"
    cCss += "  background: white !important; margin: 0 !important; padding: 0 !important;"
    cCss += "  width: " + cWidth + " !important; height: auto !important; overflow: visible !important;"
    cCss += "}"
    cCss += "body.printing-mode #q-app { display: none !important; }"
    cCss += "body.printing-mode .nice-document { display: block !important; float: none !important; position: static !important; overflow: visible !important; height: auto !important; }"
    cCss += "body.printing-mode .nice-page {"
    cCss += "  width: " + cWidth + " !important;"
    cCss += "  min-height: " + cHeight + " !important;"
    cCss += "  margin: 0 !important;"
    cCss += "  padding: 20px !important;" 
    cCss += "  display: block !important;"
    cCss += "  position: relative !important;"
    cCss += "  box-sizing: border-box !important;"
    cCss += "  break-after: page !important;"
    cCss += "  page-break-after: always !important;"
    cCss += "}"
    // Force break before subsequent pages just in case 'after' fails
    cCss += "body.printing-mode .nice-page + .nice-page { page-break-before: always !important; margin-top: 0 !important; }"
    cCss += "body.printing-mode .no-print { display: none !important; visibility: hidden !important; }"
    cCss += "body.printing-mode .q-btn { display: none !important; }" // Kill all buttons in print mode
   
return cCss

//----------------------------------------------------------------------------//
// Nice Print Page (The Sheet)
//----------------------------------------------------------------------------//

CLASS TNicePrintPage FROM TNiceContainer
    DATA oHeader
    DATA oFooter
   
    METHOD New( oParent )
    METHOD SetHeader( oHeader ) INLINE ::oHeader := oHeader
    METHOD SetFooter( oFooter ) INLINE ::oFooter := oFooter
    METHOD GetHtml()
ENDCLASS

METHOD New( oParent ) CLASS TNicePrintPage
    ::Super:New( oParent )
return Self

METHOD GetHtml() CLASS TNicePrintPage
    // Remove 'column' class to avoid Flexbox interference with page breaks
    local cHtml := '<div class="nice-page">' 
    
    if ::oHeader != nil
    cHtml += ::oHeader:GetHtml()
    endif

    cHtml += ::GetHtmlChildren()
    
    if ::oFooter != nil
    cHtml += ::oFooter:GetHtml()
    endif

    cHtml += '</div>'
return cHtml

//----------------------------------------------------------------------------//
// Nice Print Button (Helper)
//----------------------------------------------------------------------------//

CLASS TNicePrintButton FROM TNiceButton
    METHOD New( oParent, cLabel, cClass, cStyle )
    METHOD GetHtml()
ENDCLASS

METHOD New( oParent, cLabel, cClass, cStyle ) CLASS TNicePrintButton
    DEFAULT cLabel := "Imprimir / PDF"
    ::Super:New( oParent, cLabel, , "print", cClass, cStyle )
return Self

METHOD GetHtml() CLASS TNicePrintButton
    // Uses window.print() and adds 'no-print' class so it doesn't appear on the paper
    local cHtml := '<q-btn class="no-print ' + ::GetFullClass() + '" '
    cHtml += 'icon="print" label="' + ::cLabel + '" '
    cHtml += 'color="primary" '
    cHtml += 'onclick="window.nicePrint()" '
    cHtml += '></q-btn>'
return cHtml
