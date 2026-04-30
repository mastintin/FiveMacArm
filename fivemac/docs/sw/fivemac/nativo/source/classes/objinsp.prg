#include "FiveMac.ch"

//----------------------------------------------------------------------------//
// Real-Time Object Inspector for FiveMac
// Acts like Chrome DevTools to inspect live windows and controls.
//----------------------------------------------------------------------------//

CLASS TObjInspector FROM TWindow

    DATA   oSplit
    DATA   oTree
    DATA   oTabs
    DATA   oBrwProps, oBrwEvents
   
    DATA   oSelected      // Currently inspected control/window
    DATA   oHighlighter   // Transparent overlay to highlight controls
    DATA   aTreeObjMap    // Maps tree row -> Object reference
   
    METHOD New()
   
    METHOD BuildUI()
    METHOD ReloadTree()
    METHOD AddNode( oNode, oObj, cPrefix, nDepth )
   
    METHOD OnSelectNode()
    METHOD Highlight( oCtrl )
   
    METHOD GetProp( nRow, nCol )
    METHOD SetProp( nRow, nCol, cData )
    METHOD EditProp()
   
    METHOD GetEvent( nRow, nCol )
    METHOD SetEvent( nRow, nCol, cData )
    METHOD EditEvent()

    METHOD IsDescendantOf( oObj, oParent )

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New() CLASS TObjInspector

    ::Super:New( , , , , , , , , , , 1000, 600, .T. )
   
    ::cText = "Real-Time Object Inspector"
    ::SetPos( ScreenHeight() - 600, ScreenWidth() - 620 )
   
    ::aTreeObjMap = {}
   
    // Set up the highlighter window (transparent yellow)
    ::oHighlighter = TWindow():New( 0, 0, 0, 0, "", .T., .F., .T., .T., .T., 100, 100, .T. )
    BrwSetBkcolor( ::oHighlighter:hWnd, 255, 255, 0, 50 ) // Semi-transparent yellow
    ::oHighlighter:Hide()
   
    ::BuildUI()
    
    // Defer ReloadTree slightly if needed, but for now just call it
    ::ReloadTree()

return Self

//----------------------------------------------------------------------------//

METHOD BuildUI() CLASS TObjInspector

    // LEFT: Hierarchy Tree
    @ 0, 0 OUTLINE ::oTree OF Self ;
        SIZE 300, ::nHeight AUTORESIZE 16 TITLE "Live Objects" ;
        ACTION ::OnSelectNode()
      
    // RIGHT: Properties / Events Tabs
    @ 0, 305 TABS ::oTabs PROMPTS { "Properties", "Events" } ;
        OF Self SIZE ::nWidth - 305, ::nHeight AUTORESIZE 18
      
    // Tab 1: Properties
    if ::oTabs != nil .and. Len( ::oTabs:aControls ) > 0
        @ 0, 0 BROWSE ::oBrwProps FIELDS "", "" HEADERS "Property", "Value" ;
            OF ::oTabs:aControls[ 1 ] SIZE 680, 550 AUTORESIZE 18
         
        WITH OBJECT ::oBrwProps
        :SetColor( CLR_BLACK, CLR_PANE )
        :bSetValue = { | nRow, nCol, cData | ::SetProp( nRow, nCol, cData ) }
        :bGetValue = { | nRow, nCol | ::GetProp( nRow, nCol ) }
        :bLogicLen = { || If( ::oSelected != nil, Len( ::oSelected:aProps ), 0 ) }
        :cAlias = "_INSPECT"
        :SetColEditable( 1, .F. )
        :bAction = { || ::EditProp(), ::oBrwProps:Refresh() }
    END
    endif
   
    // Tab 2: Events
    if ::oTabs != nil .and. Len( ::oTabs:aControls ) > 1
        @ 0, 0 BROWSE ::oBrwEvents FIELDS "", "" HEADERS "Event", "Code" ;
            OF ::oTabs:aControls[ 2 ] SIZE 680, 550 AUTORESIZE 18
         
        WITH OBJECT ::oBrwEvents
        :SetColor( CLR_BLACK, CLR_PANE )
        :bSetValue = { | nRow, nCol, cData | ::SetEvent( nRow, nCol, cData ) }
        :bGetValue = { | nRow, nCol | ::GetEvent( nRow, nCol ) }
        :bLogicLen = { || If( ::oSelected != nil, Len( ::oSelected:aEvents ), 0 ) }
        :cAlias = "_INSPECT"
        :SetColEditable( 1, .F. )
        :bAction = { || ::EditEvent(), ::oBrwEvents:Refresh() }
    END
    endif

return nil

//----------------------------------------------------------------------------//

METHOD ReloadTree() CLASS TObjInspector

    local aWindows := GetAllWin()
    local oRootNode := ::oTree:oNode
    local n
   
    oRootNode:aNodes = {} // Clear existing
    ::aTreeObjMap = {}
   
    for n = 1 to Len( aWindows )
        // robust filtering: check class name to avoid seeing ourselves
        if ! Empty( aWindows[ n ]:hWnd ) .and. ;
                ! aWindows[ n ]:IsKindOf( "TOBJINSPECTOR" ) .and. ;
                ( ::oHighlighter == nil .or. aWindows[ n ]:hWnd != ::oHighlighter:hWnd )

            if aWindows[ n ]:oWnd == nil
                ::AddNode( oRootNode, aWindows[ n ], "Window: ", 0 )
            endif
        endif
    next

    ::oTree:Rebuild()
    ::oTree:ExpandAll()

return nil

//----------------------------------------------------------------------------//

METHOD AddNode( oParentNode, oObj, cPrefix, nDepth ) CLASS TObjInspector

    local oNode, lHasChildren := .F.
    local cName := cPrefix + oObj:ClassName()
    local n
   
    hb_Default( @nDepth, 0 )

    // Safety check
    if oObj == nil .or. nDepth > 20
        return nil
    endif
    
    // MsgInfo( "Processing: " + oObj:ClassName() + " at depth " + cValToChar( nDepth ) )

    // robust filtering: Use class name and hWnd
    if ( ! Empty( oObj:hWnd ) .and. oObj:hWnd == ::hWnd ) .or. ;
            oObj:IsKindOf( "TOBJINSPECTOR" ) .or. ;
            ( ::oHighlighter != nil .and. ! Empty( oObj:hWnd ) .and. oObj:hWnd == ::oHighlighter:hWnd ) .or. ;
            ::IsDescendantOf( oObj, Self )
        return nil
    endif

    // Special handling for TSplitItem: Don't add node, just recurse children
    if oObj:IsKindOf( "TSPLITITEM" )
        if __ObjHasMsg( oObj, "aControls" ) .and. ! Empty( oObj:aControls )
            for n = 1 to Len( oObj:aControls )
                ::AddNode( oParentNode, oObj:aControls[ n ], "", nDepth + 1 )
            next
        endif
        return nil
    endif

    if ! Empty( oObj:cVarName )
        cName += " (" + oObj:cVarName + ")"
    endif
   
    lHasChildren := .F.

    if __ObjHasMsg( oObj, "aControls" ) .and. ! Empty( oObj:aControls )
        lHasChildren := .T.
    endif
    if __ObjHasMsg( oObj, "aViews" ) .and. ! Empty( oObj:aViews )
        lHasChildren := .T.
    endif

    oNode := oParentNode:AddItem( cName, lHasChildren )
    oNode:Cargo = oObj
    
    // Store flat mapping of node to object (legacy)
    AAdd( ::aTreeObjMap, oObj )
   
    // Recursively add children if they exist
    // Try both aControls and aViews if they exist
    if __ObjHasMsg( oObj, "aControls" ) .and. ! Empty( oObj:aControls )
        for n = 1 to Len( oObj:aControls )
            ::AddNode( oNode, oObj:aControls[ n ], "", nDepth + 1 )
        next
    endif

    if __ObjHasMsg( oObj, "aViews" ) .and. ! Empty( oObj:aViews )
        for n = 1 to Len( oObj:aViews )
            ::AddNode( oNode, oObj:aViews[ n ], "", nDepth + 1 )
        next
    endif

    // Special case for TBOOK (folder) tabs?
    if oObj:IsKindOf( "TBOOK" ) .and. __ObjHasMsg( oObj, "aControls" )
        // Already handled above if they are in aControls
    endif

return nil

//----------------------------------------------------------------------------//

METHOD OnSelectNode() CLASS TObjInspector

    local oNode := ::oTree:GetSelect()
   
    if oNode != nil .and. oNode:Cargo != nil
        ::oSelected = oNode:Cargo
        ::Highlight( ::oSelected )
        ::oBrwProps:Refresh()
        ::oBrwEvents:Refresh()
    endif

return nil

//----------------------------------------------------------------------------//

METHOD Highlight( oCtrl ) CLASS TObjInspector

    if oCtrl == nil
        ::oHighlighter:Hide()
        return nil
    endif
   
    // highlighter disabled temporarily
    ::oHighlighter:Hide()

return nil

//----------------------------------------------------------------------------//

METHOD GetProp( nRow, nCol ) CLASS TObjInspector

    if nCol == 0
        return ::oSelected:aProps[ nRow + 1 ]
    else
        do case
            case ValType( __ObjSendMsg( ::oSelected, ::oSelected:aProps[ nRow + 1 ] ) ) == "A"
                ::oBrwProps:SetColEditable( 2, .F. )
                return "{ ... Array ... }"
                otherwise
                ::oBrwProps:SetColEditable( 2, .T. )
                return cValToChar( __ObjSendMsg( ::oSelected, ::oSelected:aProps[ nRow + 1 ] ) )
        endcase
    endif

return nil

//----------------------------------------------------------------------------//

METHOD SetProp( nRow, nCol, cData ) CLASS TObjInspector

    local cProp, cType, uVal
   
    if ::oSelected != nil
        cProp = ::oSelected:aProps[ nRow + 1 ]
        cType = ValType( __ObjSendMsg( ::oSelected, cProp ) )
      
        do case
            case cType == "C"
                uVal = cData
                if cProp == "cText" .or. cProp == "cTitle"
                    // Polymorphic update: calls GetSetText for GETs, WndSetText for Windows, etc.
                    if __ObjHasMsg( ::oSelected, "SetText" )
                        ::oSelected:SetText( cData )
                    elseif __ObjHasMsg( ::oSelected, "cText" )     
                        ::oSelected:cText( cData )
                    endif
                    
                    // Sync with associated variable if it exists (bSetGet)
                    if __ObjHasMsg( ::oSelected, "bSetGet" ) .and. ValType( ::oSelected:bSetGet ) == "B"
                        Eval( ::oSelected:bSetGet, cData )
                    endif
                endif
                __ObjSendMsg( ::oSelected, "_" + cProp, cData )
                
            case cType == "N"
                uVal = Val( cData )
                __ObjSendMsg( ::oSelected, "_" + cProp, uVal )
                
                // Live updates for position, size and colors
                do case
                    case cProp == "nTop" .or. cProp == "nLeft"
                        ::oSelected:SetPos( ::oSelected:nTop, ::oSelected:nLeft )
                    case cProp == "nWidth" .or. cProp == "nHeight"
                        ::oSelected:SetSize( ::oSelected:nWidth, ::oSelected:nHeight )
                    case cProp == "nClrText"
                        ::oSelected:SetColor( uVal, ::oSelected:nClrBack )
                    case cProp == "nClrBack"
                        ::oSelected:SetColor( ::oSelected:nClrText, uVal )
                endcase

            case cType == "L"
                uVal = ( Lower( cData ) == ".t." )
                __ObjSendMsg( ::oSelected, "_" + cProp, uVal )
        endcase
        
        if __ObjHasMsg( ::oSelected, "Refresh" )
            ::oSelected:Refresh()
        endif
    endif

return nil

//----------------------------------------------------------------------------//

METHOD EditProp() CLASS TObjInspector

    local cProp, uVal, cVal
    local nRow := ::oBrwProps:nArrayAt
   
    if ::oSelected != nil .and. nRow > 0
        cProp = ::oSelected:aProps[ nRow ]
        uVal  = __ObjSendMsg( ::oSelected, cProp )
        
        if ValType( uVal ) == "A"
            MsgInfo( "Cannot edit arrays" )
            return nil
        endif
        
        cVal  = cValToChar( uVal )
       
        if MsgGet( "Editing " + cProp, "Value:", @cVal )
            ::SetProp( nRow - 1, 1, cVal )
            ::oBrwProps:Refresh()
        endif
    endif

return nil

//----------------------------------------------------------------------------//

METHOD GetEvent( nRow, nCol ) CLASS TObjInspector

    if nCol == 0
        return ::oSelected:aEvents[ nRow + 1 ][ 1 ][ 1 ]
    else
        return If( ! Empty( ::oSelected:aEvents[ nRow + 1 ][ 2 ] ), ::oSelected:aEvents[ nRow + 1 ][ 2 ], "" )
    endif
   
return nil

//----------------------------------------------------------------------------//

METHOD SetEvent( nRow, nCol, cData ) CLASS TObjInspector

    ::oSelected:aEvents[ nRow + 1 ][ 2 ] = cData

return nil

//----------------------------------------------------------------------------//

METHOD IsDescendantOf( oObj, oParent ) CLASS TObjInspector

    local oWnd := oObj:oWnd
    
    while oWnd != nil
        if oWnd == oParent .or. oWnd:hWnd == oParent:hWnd
            return .T.
        endif
        if __ObjHasMsg( oWnd, "oWnd" )
            oWnd = oWnd:oWnd
        else
            exit
        endif
    end

return .F.

//----------------------------------------------------------------------------//

METHOD EditEvent() CLASS TObjInspector

    local cCode := ::oSelected:aEvents[ ::oBrwEvents:nArrayAt ][ 2 ]
    if ! Empty( cCode )
        ::oSelected:SetEventCode( ::oSelected:aEvents[ ::oBrwEvents:nArrayAt ][ 1 ], cCode )
    endif

return nil

//----------------------------------------------------------------------------//
