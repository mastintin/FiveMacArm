#include "FiveMac.ch"
#include "Nice.ch"

//----------------------------------------------------------------------------//
// NiceGui Report Builder Sample
//----------------------------------------------------------------------------//

function Main()
    local oApp := TReportBuilder():New()
    oApp:Activate()
return nil

//----------------------------------------------------------------------------//

CLASS TReportBuilder
    DATA oWnd
    DATA oBrw
    DATA oWeb
    DATA aSections INIT {}
    DATA oPrinter
   
    METHOD New()
    METHOD Activate()
    METHOD BuildUI()
   
    METHOD AddHeader()
    METHOD AddParagraph()
    METHOD AddTable()
    METHOD AddImage()
    METHOD AddChart()
   
    METHOD BuildReport( oPrinter )
    METHOD UpdatePreview()
    METHOD GenerateCode()
    METHOD ShowCode( cCode )
   
ENDCLASS

METHOD New() CLASS TReportBuilder
return Self

METHOD Activate() CLASS TReportBuilder
    ::BuildUI()
    ACTIVATE WINDOW ::oWnd CENTERED
return nil

METHOD BuildUI() CLASS TReportBuilder
    local oBar, oBtn
   
    DEFINE WINDOW ::oWnd TITLE "Report Builder (NiceGui Generator)" SIZE 1200, 800 FLIPPED

    // --- Toolbar ---
    DEFINE TOOLBAR oBar OF ::oWnd
   
    DEFINE BUTTON OF oBar PROMPT "Header" IMAGE ImgSymbols("text.viewfinder", "") ACTION ::AddHeader()
    DEFINE BUTTON OF oBar PROMPT "Text" IMAGE ImgSymbols("text.alignleft", "") ACTION ::AddParagraph()
    DEFINE BUTTON OF oBar PROMPT "Table" IMAGE ImgSymbols("tablecells", "") ACTION ::AddTable()
    DEFINE BUTTON OF oBar PROMPT "Image" IMAGE ImgSymbols("photo", "") ACTION ::AddImage()
    DEFINE BUTTON OF oBar PROMPT "Chart" IMAGE ImgSymbols("chart.bar.fill", "") ACTION ::AddChart()
   
    oBar:AddSpace()
   
    DEFINE BUTTON OF oBar PROMPT "Refresh" IMAGE ImgSymbols("arrow.clockwise", "") ACTION ::UpdatePreview()
    DEFINE BUTTON OF oBar PROMPT "Code" IMAGE ImgSymbols("doc.text", "") ACTION ::GenerateCode()

    // --- Split Layout ---
    // Left: Listbox for sections
    @ 10, 10 LISTBOX ::oBrw FIELDS "" HEADERS "" OF ::oWnd SIZE 300, 780
    ::oBrw:SetArray( ::aSections )
    ::oBrw:bLine = { |n| { ::GetDescription(n) } }
   
    // Right: WebView
    @ 10, 320 WEBVIEW ::oWeb OF ::oWnd SIZE 870, 780
   
    // Initial Update
    ::UpdatePreview()

return nil

METHOD GetDescription( n ) CLASS TReportBuilder
    local aSec := ::aSections[n]
    local cDesc := aSec[1]
   
    if Len( aSec ) > 1 .and. ValType( aSec[2] ) == "C"
    cDesc += ": " + SubStr( aSec[2], 1, 30 ) + If( Len(aSec[2])>30, "...", "" )
    endif
return cDesc

METHOD AddHeader() CLASS TReportBuilder
    local cTitle := "Report Title"
    if MsgGet( "Header", "Enter Title:", @cTitle )
    AAdd( ::aSections, { "HEADER", cTitle, "Subtitle or Date" } )
    ::oBrw:Refresh()
    ::UpdatePreview()
    endif
return nil

METHOD AddParagraph() CLASS TReportBuilder
    local cText := "Enter paragraph text here..."
    if MsgGet( "Text", "Enter Text:", @cText )
    AAdd( ::aSections, { "TEXT", cText } )
    ::oBrw:Refresh()
    ::UpdatePreview()
    endif
return nil

METHOD AddTable() CLASS TReportBuilder
    // Placeholder for table wizard
    AAdd( ::aSections, { "TABLE", { "Column 1", "Column 2" }, { { "Data A1", "Data B1" }, { "Data A2", "Data B2" } } } )
    ::oBrw:Refresh()
    ::UpdatePreview()
return nil

METHOD AddImage() CLASS TReportBuilder
    local cFile := ChooseFile( "Select Image", "png" )
    if !Empty( cFile )
    AAdd( ::aSections, { "IMAGE", cFile } )
    ::oBrw:Refresh()
    ::UpdatePreview()
    endif
return nil

METHOD AddChart() CLASS TReportBuilder
    local cTitle := "Chart Title"
    if MsgGet( "Chart", "Enter Chart Title:", @cTitle )
    AAdd( ::aSections, { "CHART", cTitle } )
    ::oBrw:Refresh()
    ::UpdatePreview()
    endif
return nil

METHOD UpdatePreview() CLASS TReportBuilder
    local cHtml
    ::oPrinter := TNicePrinter():New()
    ::BuildReport( ::oPrinter )
    cHtml := ::oPrinter:GetDocHtml()
    ::oWeb:SetHtml( cHtml, ::oPrinter:GetResPath() )
return nil

METHOD BuildReport( oPrinter ) CLASS TReportBuilder
    local oPage, oMain
    local i, aSec
    local oDiv, oTbl, oChart, x
    local aCols, aRows
   
    oPage := TNicePrintPage():New( oPrinter )
    DEFINE NICE VSTACK oMain GAP "md" CLASS "nice-page-content full-width" OF oPage
   
    for i := 1 to Len( ::aSections )
    aSec := ::aSections[i]
      
    do case
    case aSec[1] == "HEADER"
    DEFINE NICE DIV oDiv CLASS "bg-primary text-white p-4 rounded shadow-sm" OF oMain
    NICE SAY PROMPT aSec[2] SIZE "2xl" BOLD OF oDiv
    if Len(aSec) > 2
    NICE SAY PROMPT aSec[3] SIZE "sm" CLASS "opacity-80" OF oDiv
    endif
    END NICE DIV
             
    case aSec[1] == "TEXT"
    NICE SAY PROMPT aSec[2] CLASS "text-body1 text-justify q-mb-md" OF oMain
             
    case aSec[1] == "TABLE"
    // Fixed: Removed COLUMNS clause which is not supported by command
    DEFINE NICE TABLE oTbl TITLE "Data Table" OF oMain
                
    aCols := aSec[2]
    aRows := aSec[3]
                
    // Add columns manually
    for x := 1 to Len( aCols )
    oTbl:AddCol( "col"+AllTrim(Str(x)), aCols[x], "col"+AllTrim(Str(x)) )
    next
                
    // Transform data to objects/hash if needed or use SetData if it supports array of arrays
    // Assuming SetData supports array of arrays or we adjust data
    oTbl:SetData( aRows )
    END NICE TABLE
             
    case aSec[1] == "IMAGE"
    if File( aSec[2] )
    // Using the new TNiceImage class
    DEFINE NICE IMAGE FILE aSec[2] WIDTH "100%" HEIGHT "200px" CLASS "rounded border q-mb-md" OF oMain
    endif

    case aSec[1] == "CHART"
    DEFINE NICE CHART oChart WIDTH "100%" HEIGHT 300 OF oMain
    NICE CHART oChart SET TITLE aSec[2]
    NICE CHART oChart SET XAXIS DATA {"Jan", "Feb", "Mar", "Apr"}
    // Fixed: Removed NAME clause
    NICE CHART oChart ADD SERIES DATA {10, 25, 15, 30} TYPE "bar"
    END NICE CHART

    endcase
    next
   
    END NICE VSTACK
return nil

METHOD GenerateCode() CLASS TReportBuilder
    local cCode := ""
    local i, aSec
   
    cCode += '// Generated by ReportBuilder' + CRLF
    cCode += 'function GenerateReport()' + CRLF
    cCode += '   local oPrinter := TNicePrinter():New()' + CRLF
    cCode += '   local oPage, oMain' + CRLF
    cCode += '   local oDiv, oTbl, oChart' + CRLF + CRLF
    cCode += '   oPage := TNicePrintPage():New( oPrinter )' + CRLF
    cCode += '   DEFINE NICE VSTACK oMain GAP "md" CLASS "nice-page-content" OF oPage' + CRLF + CRLF
   
    for i := 1 to Len( ::aSections )
    aSec := ::aSections[i]
    cCode += '   // --- ' + aSec[1] + ' ---' + CRLF
      
    do case
    case aSec[1] == "HEADER"
    cCode += '   DEFINE NICE DIV oDiv CLASS "bg-primary text-white p-4 rounded shadow-sm" OF oMain' + CRLF
    cCode += '      NICE SAY PROMPT "' + aSec[2] + '" SIZE "2xl" BOLD OF oDiv' + CRLF
    cCode += '      NICE SAY PROMPT "' + aSec[3] + '" SIZE "sm" CLASS "opacity-80" OF oDiv' + CRLF
    cCode += '   END NICE DIV' + CRLF
            
    case aSec[1] == "TEXT"
    cCode += '   NICE SAY PROMPT "' + aSec[2] + '" CLASS "text-body1 text-justify q-mb-md" OF oMain' + CRLF
            
    case aSec[1] == "IMAGE"
    cCode += '   DEFINE NICE IMAGE FILE "' + aSec[2] + '" WIDTH "100%" HEIGHT "200px" CLASS "rounded border q-mb-md" OF oMain' + CRLF

    case aSec[1] == "CHART"
    cCode += '   DEFINE NICE CHART oChart WIDTH "100%" HEIGHT 300 OF oMain' + CRLF
    cCode += '   NICE CHART oChart SET TITLE "' + aSec[2] + '"' + CRLF
    cCode += '   NICE CHART oChart SET XAXIS DATA {"Jan", "Feb", "Mar", "Apr"}' + CRLF
    cCode += '   NICE CHART oChart ADD SERIES DATA {10, 25, 15, 30} TYPE "bar"' + CRLF
    cCode += '   END NICE CHART' + CRLF
    endcase
      
    cCode += CRLF
    next
   
    cCode += '   END NICE VSTACK' + CRLF
    cCode += '   oPrinter:Preview()' + CRLF
    cCode += 'return nil'
   
    ::ShowCode( cCode )
return nil


METHOD ShowCode( cCode ) CLASS TReportBuilder
    local oDlg, oGet
   
    DEFINE DIALOG oDlg TITLE "Generated Source Code" SIZE 800, 600
   
    @ 10, 10 GET oGet VAR cCode MEMO OF oDlg SIZE 780, 500
   
    @ 550, 680 BUTTON "Copy" OF oDlg ACTION ( oGet:Copy(), oDlg:End() )
    @ 550, 580 BUTTON "Close" OF oDlg ACTION oDlg:End()
   
    ACTIVATE DIALOG oDlg CENTERED
return nil
