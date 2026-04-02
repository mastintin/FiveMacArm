#include "FiveMac.ch"
#include "Nice.ch"

//----------------------------------------------------------------------------//
// NiceGui Report Builder Sample
//----------------------------------------------------------------------------//

function Main()
    local oApp := TReportBuilder():New()
return nil

//----------------------------------------------------------------------------//

CLASS TReportBuilder
    DATA oWnd
    DATA oBrw
    DATA oWeb
    DATA aSections INIT {}
    DATA oPrinter
    DATA oProps
    DATA aProps INIT {}
    DATA hPropNames INIT {=>}
   
    METHOD New()
    METHOD BuildUI()
   
    METHOD AddHeader()
    METHOD AddParagraph()
    METHOD AddTable()
    METHOD AddImage()
    METHOD AddChart()
    METHOD AddDiv()
    METHOD EditItem()
    METHOD DeleteItem()

    METHOD BuildReport( oPrinter )
    METHOD UpdatePreview()
    METHOD GenerateCode()
    METHOD ShowCode( cCode )
    
    METHOD GetContainers()
    METHOD GetSafeRowData( n )
    METHOD AddItemWithParent( cType, cContent, cClass )
    
    METHOD MoveUp()
    METHOD MoveDown()
    METHOD EditItemWithParent()
    
    METHOD UpdateProps()
    METHOD EditProp()
    
    METHOD Save()
    METHOD Load()
    
    METHOD GetStylePart( cClass, cPrefix, aOptions )
    METHOD SetStyleClass()
ENDCLASS

METHOD New() CLASS TReportBuilder
    ::hPropNames := { ;
        "TYPE"    => "Element Type",;
        "CONTENT" => "Content/Resource",;
        "CLASS"   => "Tailwind Classes",;
        "NAME"    => "Variable ID",;
        "PARENT"  => "Parent Container", ;
        "S_COLOR" => "Style: Color",;
        "S_BG"    => "Style: Background",;
        "S_SIZE"  => "Style: Font Size",;
        "S_ALIGN" => "Style: Alignment",;
        "S_BOLD"  => "Style: Bold" ;
        }
    ::BuildUI()
return Self


METHOD BuildUI() CLASS TReportBuilder
    local oBar, oBtn
    local  aData := {}
    local oSelf := Self

    ::aSections:= { { "HEADER", "Welcome", "text-xl", "HEAD1", "MAIN" } }

    DEFINE WINDOW ::oWnd TITLE "Report Builder (NiceGui Generator)" SIZE 1400, 800 FLIPPED

    // --- Toolbar ---
    DEFINE TOOLBAR oBar OF ::oWnd
   
    DEFINE BUTTON OF oBar PROMPT "Delete" IMAGE ImgSymbols("trash", "") ACTION ::DeleteItem()
    DEFINE BUTTON OF oBar PROMPT "Up" IMAGE ImgSymbols("arrow.up", "") ACTION ::MoveUp()
    DEFINE BUTTON OF oBar PROMPT "Down" IMAGE ImgSymbols("arrow.down", "") ACTION ::MoveDown()
    oBar:AddSpace()
    
    DEFINE BUTTON OF oBar PROMPT "Open" IMAGE ImgSymbols("folder", "") ACTION ::Load()
    DEFINE BUTTON OF oBar PROMPT "Save" IMAGE ImgSymbols("square.and.arrow.down", "") ACTION ::Save()
    oBar:AddSpace()
    
    DEFINE BUTTON OF oBar PROMPT "Header" IMAGE ImgSymbols("text.viewfinder", "") ACTION ::AddHeader()
    DEFINE BUTTON OF oBar PROMPT "Text" IMAGE ImgSymbols("text.alignleft", "") ACTION ::AddParagraph()
    DEFINE BUTTON OF oBar PROMPT "Table" IMAGE ImgSymbols("tablecells", "") ACTION ::AddTable()
    DEFINE BUTTON OF oBar PROMPT "Image" IMAGE ImgSymbols("photo", "") ACTION ::AddImage()
    DEFINE BUTTON OF oBar PROMPT "Chart" IMAGE ImgSymbols("chart.bar.fill", "") ACTION ::AddChart()
    DEFINE BUTTON OF oBar PROMPT "Div" IMAGE ImgSymbols("square.dashed", "") ACTION ::AddDiv()
   
    oBar:AddSpace()
   
    DEFINE BUTTON OF oBar PROMPT "Refresh" IMAGE ImgSymbols("arrow.clockwise", "") ACTION ::UpdatePreview()
    DEFINE BUTTON OF oBar PROMPT "Code" IMAGE ImgSymbols("doc.text", "") ACTION ::GenerateCode()

    // --- Split Layout ---
   
    // List of Elements
    @ 10, 10 BROWSE ::oBrw OF ::oWnd SIZE 250, 780 ;
        HEADERS "Type", "Name" ;
        COLSIZES 80, 150 ;
        AUTORESIZE nOr( AnclaLeft, AltoMovil )
    
    ::oBrw:SetArray( ::aSections )
    ::oBrw:bLine   := { |n| { ::aSections[n][1], if(Len(::aSections[n])>=4, ::aSections[n][4], "") } }
    ::oBrw:bChange := { || ::UpdateProps() }
    
    // Enable Double Click Editing (Main)
    ::oBrw:SetDblClick()
    ::oBrw:bAction := { ||  ::EditItem() }
   
    // Center: WebView (Flexible)
    @ 10, 270 WEBVIEW ::oWeb OF ::oWnd SIZE 850, 780 ;
        AUTORESIZE nOr( AnchoMovil, AltoMovil )
   
    // Right: Property Inspector (Anchored Right)
    @ 10, 1130 BROWSE ::oProps OF ::oWnd SIZE 260, 780 ;
        HEADERS "Property", "Value" ;
        COLSIZES 100, 140 ;
        AUTORESIZE nOr( AnclaRight, AltoMovil )
    
    ::oProps:SetArray( ::aProps )
    ::oProps:bLine := { |n| ::aProps[n] }
    ::oProps:SetDblClick()
    ::oProps:bAction := { || ::EditProp() }

    ::UpdateProps()

    ACTIVATE WINDOW ::oWnd CENTERED 

return nil

METHOD GetDescription( n ) CLASS TReportBuilder
    local aSec
    local cDesc := "Unknown"
   
    if n == nil .or. n < 1 .or. n > Len( ::aSections )
        return "Invalid Index: " + ValType(n)
    endif
    
    aSec := ::aSections[n]
    if ValType( aSec ) == "A" .and. Len( aSec ) > 0
        cDesc := aSec[1]
        if Len( aSec ) > 1 .and. ValType( aSec[2] ) == "C"
            cDesc += ": " + SubStr( aSec[2], 1, 30 ) + If( Len(aSec[2])>30, "...", "" )
        endif
    endif
return cDesc

METHOD GetSafeRowData( n ) CLASS TReportBuilder
    local aRow := { "", "", "", "", "" }
    local aSec
    
    if n == nil .or. n < 1 .or. n > Len( ::aSections )
        return aRow // Return array of strings to match BROWSE columns
    endif
 
    aSec := ::aSections[n]
    
    if ValType( aSec ) == "A" .and. Len( aSec ) > 0
    aRow[1] := aSec[1] // Type
    if aSec[1] == "TABLE"
    aRow[2] := "[Table Data]"
    // Content (Index 2) is array, so we use placeholder.
    // Other fields are at standard positions now (3, 4, 5)
    if Len(aSec) >= 3; aRow[3] := aSec[3]; else; aRow[3] := ""; endif // Class
    if Len(aSec) >= 4; aRow[4] := aSec[4]; else; aRow[4] := ""; endif // Name
    if Len(aSec) >= 5; aRow[5] := aSec[5]; else; aRow[5] := ""; endif // Parent
    else
    aRow[2] := aSec[2] // Content (String)
    if Len(aSec) >= 3; aRow[3] := aSec[3]; else; aRow[3] := ""; endif // Class
    if Len(aSec) >= 4; aRow[4] := aSec[4]; else; aRow[4] := ""; endif // Name
        if Len(aSec) >= 5; aRow[5] := aSec[5]; else; aRow[5] := ""; endif // Parent
        endif
    endif

return aRow

METHOD GetContainers() CLASS TReportBuilder
    local aContainers := { "MAIN" }
    local i, aSec
    
    for i := 1 to Len( ::aSections )
        aSec := ::aSections[i]
        // If it's a container type (DIV) and has a Name (4th element)
        if aSec[1] == "DIV" .and. Len(aSec) >= 4 .and. !Empty(aSec[4])
            AAdd( aContainers, aSec[4] )
        endif
    next
return aContainers

//----------------------------------------------------------------------------//

METHOD EditItemWithParent() CLASS TReportBuilder
    local nRow := ::oBrw:GetSelect() + 1

    local cType := ::aSections[ nRow ][ 1 ]
    local cContent := ::aSections[ nRow ][ 2 ]
    local cClass := ::aSections[ nRow ][ 3 ]
    local cName := ::aSections[ nRow ][ 4 ]
    local cParent := ::aSections[ nRow ][ 5 ]
    local aParents := ::GetContainers()
    local oDlg, oBtnOk, oBtnCancel
    local nResult := 0
    local oGet1, oGet2, oGet3, oGet4
    
   
    DEFINE DIALOG oDlg TITLE "Edit " + cName SIZE 350, 350 FLIPPED
   
    @ 20, 20 SAY "Content:" OF oDlg
    
    if ValType( cContent ) == "C" .or. ValType( cContent ) == "N"
        @ 20, 100 GET cContent OF oDlg SIZE 200, 24
    else
        @ 20, 100 SAY "(Complex Data)" OF oDlg SIZE 200, 24
    endif
       
    @ 50, 20 SAY "Name (ID):" OF oDlg
    @ 50, 100 GET oGet2 VAR cName OF oDlg SIZE 200, 24 
    oGet2:Disabled()    

    @ 80, 20 SAY "Parent:" OF oDlg
    @ 80, 100 COMBOBOX cParent ITEMS aParents OF oDlg SIZE 200, 25
    
    @ 110, 20 SAY "Class:" OF oDlg
    @ 110, 100 GET cClass OF oDlg SIZE 210, 150
   
    @ 250, 80 BUTTON oBtnOk PROMPT "OK" OF oDlg ACTION ( nResult := 1, oDlg:End() )
    @ 250, 200 BUTTON oBtnCancel PROMPT "Cancel" OF oDlg ACTION ( nResult := 0, oDlg:End() )
    
    ACTIVATE DIALOG oDlg
    
    if nResult == 1
        //msginfo( cParent)
        ::aSections[ nRow ] := { cType, cContent, cClass, cName, cParent }
        ::oBrw:Refresh()
        ::UpdatePreview()
    endif

return nil


//----------------------------------------------------------------------------//

METHOD AddItemWithParent( cType, cContent, cClass ) CLASS TReportBuilder
    local cName := cType + AllTrim( Str( Len( ::aSections ) + 1 ) )
    local aParents := ::GetContainers()
    local cParent_ := "MAIN"
    local oDlg, oBtnOk, oBtnCancel
    local nResult := 0
    
    if Empty( cContent ); cContent := "New Item"; endif
    if Empty( cClass ); cClass := ""; endif
    
    DEFINE DIALOG oDlg TITLE "Add " + cType SIZE 350, 250 FLIPPED
    
    @ 20, 20 SAY "Content:" OF oDlg
    
    if ValType( cContent ) == "C" .or. ValType( cContent ) == "N"
        @ 20, 100 GET cContent OF oDlg SIZE 200, 24
    else
        @ 20, 100 SAY "(Complex Data)" OF oDlg SIZE 200, 24
    endif
    
    @ 50, 20 SAY "Name (ID):" OF oDlg
    @ 50, 100 GET cName OF oDlg SIZE 200, 24
    
    @ 80, 20 SAY "Parent:" OF oDlg
    @ 80, 100 COMBOBOX cParent_ ITEMS aParents OF oDlg SIZE 200, 25
    
    @ 110, 20 SAY "Class:" OF oDlg
    @ 110, 100 GET cClass OF oDlg SIZE 200, 24
    
    @ 150, 80 BUTTON oBtnOk PROMPT "OK" OF oDlg ACTION ( nResult := 1, oDlg:End() )
    @ 150, 200 BUTTON oBtnCancel PROMPT "Cancel" OF oDlg ACTION ( nResult := 0, oDlg:End() )
    
    ACTIVATE DIALOG oDlg
    
    if nResult == 1
        AAdd( ::aSections, { cType, cContent, cClass, cName, cParent_ } )
        ::oBrw:Refresh()
        ::UpdatePreview()
    endif
return nil

METHOD DeleteItem() CLASS TReportBuilder
    local nRow := ::oBrw:GetSelect() + 1
    
    if nRow > 0 .and. nRow <= Len( ::aSections )
        if MsgYesNo( "Are you sure you want to delete this item?", "Delete Item" )
            ADel( ::aSections, nRow )
            ASize( ::aSections, Len( ::aSections ) - 1 )
            ::oBrw:Refresh()
            ::UpdatePreview()
        endif
    endif

return nil


METHOD MoveUp() CLASS TReportBuilder
    local nRow := ::oBrw:GetSelect() + 1
    local aTemp
    
    if nRow > 1 
        aTemp := ::aSections[nRow]
        ::aSections[nRow] := ::aSections[nRow - 1]
        ::aSections[nRow - 1] := aTemp
        ::oBrw:Refresh()
        ::oBrw:SetRowPos( nRow -1 )
        ::UpdatePreview()
    endif
return nil

METHOD MoveDown() CLASS TReportBuilder
    local nRow := ::oBrw:GetSelect() + 1
    local aTemp
    
    if nRow < Len( ::aSections )
        aTemp := ::aSections[nRow]
        ::aSections[nRow] := ::aSections[nRow + 1]
        ::aSections[nRow + 1] := aTemp
        
        ::oBrw:Refresh()
        ::oBrw:SetRowPos( nRow + 1 )
        ::UpdatePreview()
    endif
return nil

METHOD EditItem() CLASS TReportBuilder
    local nRow := ::oBrw:GetSelect() + 1
    local cClass := ""
    local oDlg, oBtnOk, oBtnCancel
    local cColor := "text-black", cBg := "bg-transparent", cSize := "text-base", cAlign := "text-left"
    local lBold := .F.
    local cCustom := ""
    local nResult := 0
    local cBackClass
    local aColors := { "text-black", "text-red-600", "text-blue-600", "text-green-600", "text-gray-600", "text-white" }
    local aBg := { "bg-transparent", "bg-gray-100", "bg-blue-100", "bg-green-100", "bg-red-100", "bg-primary" }
    local aSize := { "text-xs", "text-sm", "text-base", "text-lg", "text-xl", "text-2xl", "text-3xl" }
    local aAlign := { "text-left", "text-center", "text-right", "text-justify" }
    
    LOCAL aReemplazo 
    
    local nCol:=  ::oBrw:nColPos()
    if nCol == 1
        ::EditItemWithParent()
        return nil
    endif
    if nCol == 2
        ::EditItemWithParent()
        return nil
    endif
    if nCol == 4
        ::EditItemWithParent()
        return nil
    endif
    if nCol == 5
        ::EditItemWithParent()
        return nil
    endif
    
    // Validate selection
    if nRow < 1 .or. nRow > Len( ::aSections ); return nil; endif
    
    // Retrieve current class
    if Len( ::aSections[ nRow ] ) >= 3
        cClass := ::aSections[ nRow ][ 3 ]    
        cBackClass := cClass
    endif
    
    // Simple parsing to set defaults
    if "text-red" $ cClass; cColor := "text-red-600"; endif
    if "text-blue" $ cClass; cColor := "text-blue-600"; endif
    if "text-green" $ cClass; cColor := "text-green-600"; endif
    if "text-gray" $ cClass; cColor := "text-gray-600"; endif
    if "text-white" $ cClass; cColor := "text-white"; endif
    
    if "bg-gray" $ cClass; cBg := "bg-gray-100"; endif
    if "bg-blue" $ cClass; cBg := "bg-blue-100"; endif
    if "bg-green" $ cClass; cBg := "bg-green-100"; endif
    if "bg-red" $ cClass; cBg := "bg-red-100"; endif
    if "bg-primary" $ cClass; cBg := "bg-primary"; endif
    
    if "font-bold" $ cClass; lBold := .T.; endif
    
    if "text-xs" $ cClass; cSize := "text-xs"; endif
    if "text-lg" $ cClass; cSize := "text-lg"; endif
    if "text-xl" $ cClass; cSize := "text-xl"; endif
    if "text-2xl" $ cClass; cSize := "text-2xl"; endif
    if "text-3xl" $ cClass; cSize := "text-3xl"; endif
    if "text-sm" $ cClass; cSize := "text-sm"; endif
    
    if "text-center" $ cClass; cAlign := "text-center"; endif
    if "text-right" $ cClass; cAlign := "text-right"; endif
    if "text-justify" $ cClass; cAlign := "text-justify"; endif

    DEFINE DIALOG oDlg TITLE "Edit Properties" SIZE 400, 350 FLIPPED
    
    @ 20, 20 SAY "Color:" OF oDlg
    @ 20, 100 COMBOBOX cColor ITEMS aColors OF oDlg SIZE 200, 25
    
    @ 50, 20 SAY "Background:" OF oDlg
    @ 50, 100 COMBOBOX cBg ITEMS aBg OF oDlg SIZE 200, 25
    
    @ 80, 20 SAY "Size:" OF oDlg
    @ 80, 100 COMBOBOX cSize ITEMS aSize OF oDlg SIZE 150, 25
    
    @ 110, 20 SAY "Align:" OF oDlg
    @ 110, 100 COMBOBOX cAlign ITEMS aAlign OF oDlg SIZE 150, 25
    
    @ 140, 100 CHECKBOX lBold PROMPT "Bold Text (font-bold)" OF oDlg
    
    @ 170, 20 SAY "Custom Class:" OF oDlg
    @ 170, 100 GET cCustom VAR cBackClass OF oDlg SIZE 200, 100 
    
    @ 290, 80 BUTTON oBtnOk PROMPT "OK" OF oDlg ACTION ( nResult := 1 , oDlg:end())
    @ 290, 200 BUTTON oBtnCancel PROMPT "Cancel" OF oDlg ACTION (  nResult := 0 , oDlg:end())
    
    ACTIVATE DIALOG oDlg
    
    if nResult == 1
    if cColor $ cBackClass       
        // Use cValToChar to preve
        aReemplazo := Array( Len( aColors ) ) 
        AFill( aReemplazo, "" )
        cBackClass := hb_StrReplace( cBackClass, aColors, aReemplazo )       
    endif      
    if  cBg $ cBackClass
        aReemplazo := Array( Len( aBg ) ) 
        AFill( aReemplazo, "" )
        cBackClass := hb_StrReplace( cBackClass, aBg, aReemplazo )       
    endif
    if  cSize $ cBackClass
        aReemplazo := Array( Len( aSize ) ) 
        AFill( aReemplazo, "" )
        cBackClass := hb_StrReplace( cBackClass, aSize, aReemplazo )       
    endif
    if  cAlign $ cBackClass
        aReemplazo := Array( Len( aAlign ) ) 
        AFill( aReemplazo, "" )
        cBackClass := hb_StrReplace( cBackClass, aAlign, aReemplazo )       
    endif
    DO WHILE "  " $ cBackClass
        cBackClass := StrTran( cBackClass, "  ", " " )
    ENDDO 
        
    cClass := cBackClass + cValToChar( cColor ) + " " + cValToChar( cBg ) + " " + cValToChar( cSize ) + " " + cValToChar( cAlign )
    msginfo( cClass ) 
           
    if lBold; cClass += " font-bold"; endif
           
        // Update array
        if Len( ::aSections[ nRow ] ) < 3
            AAdd( ::aSections[ nRow ], cClass )
        else
            ::aSections[ nRow ][ 3 ] := cClass
        endif
       
        ::oBrw:Refresh()
        ::UpdatePreview()
    endif

return nil

METHOD AddHeader() CLASS TReportBuilder
    ::AddItemWithParent( "HEADER", "Report Title", "text-2xl font-bold mb-4" )
return nil

METHOD AddParagraph() CLASS TReportBuilder
    ::AddItemWithParent( "TEXT", "Enter paragraph text here...", "text-body1 text-justify q-mb-md" )
return nil

METHOD AddTable() CLASS TReportBuilder
    // Content is array: { Headers, Rows }
    local aHeaders := { "Column 1", "Column 2" }
    local aRows := { { "Data A1", "Data B1" }, { "Data A2", "Data B2" } }
    
    // We use a temporary array for content to keep structure consistent
    // { Type, Content, Class, Name, Parent }
    // Content for table will be { aHeaders, aRows }
    
    ::AddItemWithParent( "TABLE", { aHeaders, aRows }, "w-full border-collapse border border-gray-300 mb-4" )
    
    ::oBrw:Refresh()
    ::UpdatePreview()
return nil

METHOD AddImage() CLASS TReportBuilder
    local cFile := ChooseFile( "Select Image", "png,jpg" )
    if !Empty( cFile )
        ::AddItemWithParent( "IMAGE", cFile, "w-full h-auto mb-4" )
    endif
return nil

METHOD AddChart() CLASS TReportBuilder
    ::AddItemWithParent( "CHART", "Chart Title", "w-full h-64 mb-4" )
return nil

METHOD AddDiv() CLASS TReportBuilder
    ::AddItemWithParent( "DIV", "Div Content", "p-4 border rounded shadow-sm bg-white" )
return nil

METHOD UpdatePreview() CLASS TReportBuilder
    local cHtml
    ::oPrinter := TNicePrinter():New()
    ::BuildReport( ::oPrinter )
    cHtml := ::oPrinter:GetDocHtml()
    ::oWeb:SetHtml( cHtml, ::oPrinter:GetResPath() )
    ::oWeb:refresh()

return nil

METHOD BuildReport( oPrinter ) CLASS TReportBuilder
    local oPage, oMain
    local i, aSec
    local oDiv, oTbl, oChart, x
    local aCols, aRows
    local hObjects := {=>}
    local cName, cParent, oParent
    
    oPage := TNicePrintPage():New( oPrinter )
    DEFINE NICE VSTACK oMain GAP "md" CLASS "nice-page-content full-width" OF oPage
    
    // Register MAIN container
    hObjects[ "MAIN" ] := oMain
    
    for i := 1 to Len( ::aSections )
    aSec := ::aSections[i]
       
    // Get Name and Parent
    cName := if( Len(aSec) >= 4 .and. !Empty(aSec[4]), aSec[4], "" )
    cParent := if( Len(aSec) >= 5 .and. !Empty(aSec[5]), aSec[5], "MAIN" )
       
    // Resolve Parent
    if Hb_HHasKey( hObjects, cParent )
        oParent := hObjects[ cParent ]
    else
        oParent := oMain // Fallback
    endif
       
    do case
    case aSec[1] == "HEADER"
    DEFINE NICE DIV oDiv CLASS aSec[3] OF oParent
    NICE SAY PROMPT aSec[2] SIZE "2xl" BOLD OF oDiv
    if !Empty(cName); hObjects[cName] := oDiv; endif
    END NICE DIV
             
    case aSec[1] == "DIV"
    DEFINE NICE DIV oDiv CLASS aSec[3] OF oParent
    if !Empty(aSec[2]) .and. aSec[2] != "Div Content"
        NICE SAY PROMPT aSec[2] OF oDiv
    endif
    if !Empty(cName); hObjects[cName] := oDiv; endif
    END NICE DIV
             
    case aSec[1] == "TEXT"
    NICE SAY PROMPT aSec[2] CLASS aSec[3] OF oParent
             
    case aSec[1] == "TABLE"
    if ValType( aSec[2] ) == "A" .and. Len( aSec[2] ) >= 2
    aCols := aSec[2][1]
    aRows := aSec[2][2]
    DEFINE NICE TABLE oTbl TITLE "Table" CLASS aSec[3] OF oParent
    for x := 1 to Len(aCols)
        oTbl:AddCol( aCols[x] )
    next
    oTbl:SetData( aRows )
    if !Empty(cName); hObjects[cName] := oTbl; endif
    else
        NICE SAY PROMPT "[Invalid Table Data]" OF oParent
    endif
             
    case aSec[1] == "IMAGE"
    DEFINE NICE IMAGE oDiv FILE aSec[2] CLASS aSec[3] OF oParent
    if !Empty(cName); hObjects[cName] := oDiv; endif
             
    case aSec[1] == "CHART"
    DEFINE NICE CARD oDiv CLASS aSec[3] OF oParent
    NICE SAY PROMPT aSec[2] SIZE "xl" BOLD OF oDiv
    x := TNiceChart():New( oDiv )
    x:SetTitle( aSec[2] )
    x:SetXAxis( { "Jan", "Feb", "Mar", "Apr", "May", "Jun" } )
    x:AddSeries( { 12, 19, 3, 5, 2, 3 }, "bar" )
    if !Empty(cName); hObjects[cName] := oDiv; endif
    END NICE CARD
             
    endcase
    next
return nil
   

METHOD GenerateCode() CLASS TReportBuilder
    local cCode := ""
    local i, aSec
    local cType, cContent, cClass, cName, cParent
    local cParentVar, cVarName, cProps
    local hVars := {=>}
    
    // Header
    cCode += '// Generated by ReportBuilder' + CRLF
    cCode += '#include "FiveMac.ch"' + CRLF
    cCode += '#include "Nice.ch"' + CRLF + CRLF
    cCode += 'function GenerateReport()' + CRLF
    cCode += '   local oPrinter := TNicePrinter():New()' + CRLF
    cCode += '   local oPage, oMain' + CRLF
    cCode += '   local oDiv, oTbl, oChart, oImg, oText' + CRLF 
    
    // Add locals for named containers
    for i := 1 to Len( ::aSections )
        aSec := ::aSections[i]
        cName := if( Len(aSec) >= 4 .and. !Empty(aSec[4]), aSec[4], "" )
        if !Empty( cName )
            cCode += '   local o' + cName + CRLF
            hVars[ cName ] := "o" + cName
        endif
    next
    hVars[ "MAIN" ] := "oMain"

    cCode += CRLF
    cCode += '   oPage := TNicePrintPage():New( oPrinter )' + CRLF
    cCode += '   DEFINE NICE VSTACK oMain GAP "md" CLASS "nice-page-content" OF oPage' + CRLF + CRLF
   
    for i := 1 to Len( ::aSections )
        aSec := ::aSections[i]
        
        cType   := aSec[1]
        cContent:= aSec[2] // Can be Array for Table
        cClass  := if( Len(aSec) >= 3, aSec[3], "" )
        cName   := if( Len(aSec) >= 4 .and. !Empty(aSec[4]), aSec[4], "" )
        cParent := if( Len(aSec) >= 5 .and. !Empty(aSec[5]), aSec[5], "MAIN" )
        
        // Resolve Parent Variable
        if Hb_HHasKey( hVars, cParent )
            cParentVar := hVars[ cParent ]
        else
            cParentVar := "oMain"
        endif
        
        if !Empty( cName )
            cVarName := "o" + cName
        else
            // Temporary variables based on type
            if cType == "TABLE"
                cVarName := "oTbl"
            elseif cType == "CHART"
                cVarName := "oChart"
            elseif cType == "IMAGE"
                cVarName := "oImg"
            elseif cType == "TEXT" .or. cType == "HEADER"
                cVarName := "oText" // or oDiv
            else
                cVarName := "oDiv"
            endif
        endif

        cCode += '   // --- ' + cType + ' ---' + CRLF
      
        do case
            case cType == "HEADER"
                cCode += '   DEFINE NICE DIV ' + cVarName + ' CLASS "' + cClass + '" OF ' + cParentVar + CRLF
                cCode += '      NICE SAY PROMPT "' + cContent + '" SIZE "2xl" BOLD OF ' + cVarName + CRLF
                cCode += '   END NICE DIV' + CRLF
            
            case cType == "TEXT"
                cCode += '   NICE SAY PROMPT "' + cContent + '" CLASS "' + cClass + '" OF ' + cParentVar + CRLF
            
            case cType == "DIV"
                cCode += '   DEFINE NICE DIV ' + cVarName + ' CLASS "' + cClass + '" OF ' + cParentVar + CRLF
                if !Empty(cContent) .and. cContent != "Div Content"
                    cCode += '      NICE SAY PROMPT "' + cContent + '" OF ' + cVarName + CRLF
                endif
                cCode += '   END NICE DIV' + CRLF

            case cType == "IMAGE"
                cCode += '   DEFINE NICE IMAGE ' + cVarName + ' FILE "' + cContent + '" WIDTH "100%" HEIGHT "200px" CLASS "' + cClass + '" OF ' + cParentVar + CRLF

            case cType == "TABLE"
                // Content is { Headers, Rows }
                cCode += '   DEFINE NICE TABLE ' + cVarName + ' TITLE "Table" CLASS "' + cClass + '" OF ' + cParentVar + CRLF
                 
                // Generate Headers
                if ValType(cContent) == "A" .and. Len(cContent) >= 1
                    cCode += '   ' + cVarName + ':SetCols( ' + cValToChar( cContent[1] ) + ' )' + CRLF
                endif
                 
                // Generate Rows
                if ValType(cContent) == "A" .and. Len(cContent) >= 2
                    // Build array string manually or use cValToChar if it produces valid literal
                    // cValToChar on array of arrays produces "{ {...}, {...} }" which is valid
                    cCode += '   ' + cVarName + ':SetData( ' + cValToChar( cContent[2] ) + ' )' + CRLF
                endif

            case cType == "CHART"
                cCode += '   DEFINE NICE CARD ' + cVarName + ' CLASS "' + cClass + '" OF ' + cParentVar + CRLF
                cCode += '   NICE SAY PROMPT "' + cContent + '" SIZE "xl" BOLD OF ' + cVarName + CRLF
                cCode += '   x := TNiceChart():New( ' + cVarName + ' )' + CRLF
                cCode += '   x:SetType( "bar" )' + CRLF
                cCode += '   x:SetData( { 12, 19, 3, 5, 2, 3 }, { "Red", "Blue", "Yellow", "Green", "Purple", "Orange" } )' + CRLF
                cCode += '   x:SetOption( "responsive", .T. )' + CRLF
                cCode += '   END NICE CARD' + CRLF
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
   
    DEFINE DIALOG oDlg TITLE "Generated Source Code" SIZE 800, 600 NOFLIPPED 
   
    @ 10, 10 GET oGet VAR cCode MEMO OF oDlg SIZE 780, 500
   
    @ 550, 680 BUTTON "Copy" OF oDlg ACTION ( oGet:Copy(), oDlg:End() )
    @ 550, 580 BUTTON "Close" OF oDlg ACTION oDlg:End()
   
    ACTIVATE DIALOG oDlg CENTERED
return nil

METHOD UpdateProps() CLASS TReportBuilder
    local n := ::oBrw:nRowPos()
    local aSec, cClass
    
    ::aProps := {}
    
    if n > 0 .and. n <= Len( ::aSections )
        aSec := ::aSections[ n ]
        cClass := if(Len(aSec)>=3, cValToChar(aSec[3]), "")

        AAdd( ::aProps, { ::hPropNames["TYPE"],    cValToChar(aSec[1]) } )
        AAdd( ::aProps, { ::hPropNames["CONTENT"], if(ValType(aSec[2])=="A", "[Complex Data]", cValToChar(aSec[2])) } )
        AAdd( ::aProps, { ::hPropNames["CLASS"],   cClass } )
        AAdd( ::aProps, { ::hPropNames["NAME"],    if(Len(aSec)>=4, cValToChar(aSec[4]), "") } )
        AAdd( ::aProps, { ::hPropNames["PARENT"],  if(Len(aSec)>=5, cValToChar(aSec[5]), "MAIN") } )

        // styling sub-properties
        AAdd( ::aProps, { ::hPropNames["S_COLOR"], ::GetStylePart( cClass, "text-", { "text-black", "text-red-600", "text-blue-600", "text-green-600", "text-gray-600", "text-white" } ) } )
        AAdd( ::aProps, { ::hPropNames["S_BG"],    ::GetStylePart( cClass, "bg-",   { "bg-transparent", "bg-gray-100", "bg-blue-100", "bg-green-100", "bg-red-100", "bg-primary" } ) } )
        AAdd( ::aProps, { ::hPropNames["S_SIZE"],  ::GetStylePart( cClass, "text-", { "text-xs", "text-sm", "text-base", "text-lg", "text-xl", "text-2xl", "text-3xl" } ) } )
        AAdd( ::aProps, { ::hPropNames["S_ALIGN"], ::GetStylePart( cClass, "text-", { "text-left", "text-center", "text-right", "text-justify" } ) } )
        AAdd( ::aProps, { ::hPropNames["S_BOLD"],  if("font-bold" $ cClass, "Yes" , "No") } )

    else
        AAdd( ::aProps, { "No element", "Selected" } )
    endif
    
    if ::oProps != nil
        ::oProps:SetArray( ::aProps )
        ::oProps:Refresh()
    endif
return nil

METHOD EditProp() CLASS TReportBuilder
    local nBrw := ::oBrw:nRowPos()
    local nProp := ::oProps:nRowPos()
    local aSec, cPropName, uValue, cNewVal
    local oDlg, oCombo, nResult := 0
    local aOptions := {}
    
    if nBrw == 0 .or. nProp == 0; return nil; endif
    
    aSec := ::aSections[ nBrw ]
    cPropName := ::aProps[ nProp ][1]
    uValue := ::aProps[ nProp ][2]
    
    if uValue == "[Complex Data]"
        MsgInfo( "Complex data cannot be edited here yet." )
        return nil
    endif
    
    // Special handling for styling sub-properties
    if cPropName == ::hPropNames["S_COLOR"]
        aOptions := { "text-black", "text-red-600", "text-blue-600", "text-green-600", "text-gray-600", "text-white" }
    elseif cPropName == ::hPropNames["S_BG"]
        aOptions := { "bg-transparent", "bg-gray-100", "bg-blue-100", "bg-green-100", "bg-red-100", "bg-primary" }
    elseif cPropName == ::hPropNames["S_SIZE"]
        aOptions := { "text-xs", "text-sm", "text-base", "text-lg", "text-xl", "text-2xl", "text-3xl" }
    elseif cPropName == ::hPropNames["S_ALIGN"]
        aOptions := { "text-left", "text-center", "text-right", "text-justify" }
    elseif cPropName == ::hPropNames["S_BOLD"]
        ::aProps[ nProp ][ 2 ] := if( uValue == "Yes", "No", "Yes" )
        ::SetStyleClass()
        return nil
    endif
    
    if !Empty( aOptions )
        cNewVal := uValue
        DEFINE DIALOG oDlg TITLE "Select " + cPropName SIZE 300, 150 FLIPPED
        @ 20, 20 SAY "Value:" OF oDlg
        @ 20, 80 COMBOBOX oCombo VAR cNewVal ITEMS aOptions OF oDlg SIZE 180, 25
        @ 80, 50 BUTTON "OK" OF oDlg ACTION ( nResult := 1, oDlg:End() )
        @ 80, 150 BUTTON "Cancel" OF oDlg ACTION ( nResult := 0, oDlg:End() )
        ACTIVATE DIALOG oDlg CENTERED
        
        if nResult == 1
            ::aProps[ nProp ][ 2 ] := cNewVal
            ::SetStyleClass()
        endif
        return nil
    endif

    cNewVal := uValue
    if MsgGet( "Edit Property", cPropName, @cNewVal )
    do case
    case cPropName == ::hPropNames["TYPE"]
    aSec[1] := cNewVal
    case cPropName == ::hPropNames["CONTENT"]
    aSec[2] := cNewVal
    case cPropName == ::hPropNames["CLASS"]
    if Len(aSec) < 3; ASize(aSec, 3); endif
    aSec[3] := cNewVal
    case cPropName == ::hPropNames["NAME"]
    if Len(aSec) < 4; ASize(aSec, 4); endif
        aSec[4] := cNewVal
        case cPropName == ::hPropNames["PARENT"]
        if Len(aSec) < 5; ASize(aSec, 5); endif
        aSec[5] := cNewVal
        endcase
        
        ::UpdateProps()
        ::oBrw:Refresh()
        ::UpdatePreview()
    endif
    
return nil

METHOD Save() CLASS TReportBuilder
    local cFile := SaveFile( "Save Report Design", "design.rpb" )
    if !Empty( cFile )
        if hb_memoWrit( cFile, hb_Serialize( ::aSections ) )
            MsgInfo( "Report saved successfully!" )
        else
            MsgStop( "Error saving report!" )
        endif
    endif
return nil

METHOD Load() CLASS TReportBuilder
    local cFile := ChooseFile( "Open Report Design", "rpb" )
    local cData
    if !Empty( cFile )
        cData := hb_memoRead( cFile )
        if !Empty( cData )
            ::aSections := hb_Deserialize( cData )
            ::oBrw:SetArray( ::aSections )
            ::oBrw:Refresh()
            ::UpdateProps()
            ::UpdatePreview()
            MsgInfo( "Report loaded successfully!" )
        else
            MsgStop( "Error reading report file!" )
        endif
    endif
return nil
METHOD GetStylePart( cClass, cPrefix, aOptions ) CLASS TReportBuilder
    local cPart := ""
    local cOpt
    
    for each cOpt in aOptions
        if cOpt $ cClass
            return cOpt
        endif
    next
    
return if( !Empty(aOptions), aOptions[1], "" )

METHOD SetStyleClass() CLASS TReportBuilder
    local n := ::oBrw:nRowPos()
    local aSec, cClass := ""
    local hP := {=>}
    local cProp, aP
    
    if n == 0; return nil; endif
    aSec := ::aSections[ n ]
    
    for each aP in ::aProps
        hP[ aP[1] ] := aP[2]
    next
    
    // Assemble class from parts
    cClass += hP[ ::hPropNames["S_COLOR"] ] + " "
    cClass += hP[ ::hPropNames["S_BG"] ] + " "
    cClass += hP[ ::hPropNames["S_SIZE"] ] + " "
    cClass += hP[ ::hPropNames["S_ALIGN"] ] + " "
    if hP[ ::hPropNames["S_BOLD"] ] == "Yes"
        cClass += "font-bold "
    endif
    
    // Clean up extra spaces
    cClass := AllTrim( cClass )
    while "  " $ cClass
        cClass := StrTran( cClass, "  ", " " )
    enddo
    
    if Len( aSec ) < 3; ASize( aSec, 3 ); endif
    aSec[ 3 ] := cClass
    
    ::UpdateProps()
    ::oBrw:Refresh()
    ::UpdatePreview()
    
return nil
