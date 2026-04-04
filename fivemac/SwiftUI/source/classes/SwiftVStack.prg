#include "FiveMac.ch"
#include "SwiftControls.ch"

CLASS TSwiftVStack FROM TSwiftControl

    DATA aBatch INIT {}
    DATA aIds   INIT {}

    ASSIGN Glass( l )       INLINE ::SetGlass( l )
    ASSIGN Spacing( n )     INLINE ::SetSpacing( n )
    ASSIGN Alignment( n )   INLINE ::SetAlignment( n )
    ASSIGN Scrollable( l )  INLINE ::SetScrollable( l )

    METHOD New( nRow, nCol, nWidth, nHeight, oWnd, nAutoResize, cId )
    METHOD AddItem( nType, cContent, bAction, cSecondary, nClrFore, nClrBack, nAlphaFore, nAlphaBack )
    METHOD AddBatch( aItems )
    
    // Items management
    METHOD AddText( cText, bAction )
    METHOD AddImage( cName )
    METHOD AddButton( cText, bAction )
    METHOD AddToggle( cCaption, lOn, bAction, lSwitch, cId )
    METHOD AddSlider( nVal, nMin, nMax, bAction, lGlass, cId )
    METHOD AddHStack( oParent )
    METHOD AddList( oParent )
    METHOD AddRow( cText, bAction )
    METHOD AddSpacer( oParent )
    METHOD AddDivider( oParent )
    METHOD AddSystemImage( cName ) INLINE ::AddImage( cName )

    // Configuration
    METHOD SetScroll( lScroll )
    METHOD SetGlass( lGlass )
    METHOD SetBackgroundColor( nClr, nAlpha )
    METHOD SetForegroundColor( nClr, nAlpha )
    METHOD SetInvertedColor( lInvert )
    METHOD SetSpacing( nSpacing )
    METHOD SetAlignment( nAlign )
    METHOD SetRadius( nRadius )
    METHOD RemoveAll()

    // Items interaction
    METHOD SetItemColor( cId, nClr, nAlpha ) 
    METHOD SetItemText( cId, cText )     INLINE SD_VSTK_SET_ITEM_TEXT( ::cId, cId, cText )
    METHOD SetLastItemId( cId )          INLINE SD_VSTK_SET_LAST_ITEM_ID( ::cId, cId )
    METHOD GetLastItemId()               INLINE SD_VSTK_GET_LAST_ITEM_ID( ::cId )

    METHOD OnAction( cItemId )
    METHOD End()

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nRow, nCol, nWidth, nHeight, oWnd, nAutoResize, cId ) CLASS TSwiftVStack

    DEFAULT nWidth := 200, nHeight := 300
    DEFAULT oWnd := GetWndDefault(), nAutoResize := 0

    ::Super:New( nRow, nCol, nWidth, nHeight, cId )
    ::oWnd := oWnd
    
    ::aBatch := {}
    ::aIds   := {}

    ::Register( SD_SWIFT_VSTACK_CREATE( nRow, nCol, nWidth, nHeight, oWnd:hWnd, ::cId ) )
   
    if nAutoResize != 0
        SWIFTAUTORESIZE( ::hWnd, nAutoResize )
    endif

    oWnd:AddControl( Self )

return Self

//----------------------------------------------------------------------------//

METHOD AddItem( nType, cContent, bAction, cSecondary, nClrFore, nClrBack, nAlphaFore, nAlphaBack ) CLASS TSwiftVStack
    AAdd( ::aBatch, { "type" => nType, "content" => cContent, "action" => bAction, ;
        "secondaryContent" => cSecondary, "nClrFore" => nClrFore, "nClrBack" => nClrBack, ;
        "nAlphaFore" => nAlphaFore, "nAlphaBack" => nAlphaBack } )
return nil

//----------------------------------------------------------------------------//

METHOD AddBatch( aItems ) CLASS TSwiftVStack
    local aJsonData := {}
    local aIds, n, cJson, cJsonIds
    local hItem, oTempItem
   
    if Empty( aItems ) ; return {} ; endif

    for n := 1 to Len( aItems )
    hItem := { "type" => aItems[n]["type"], ;
        "content" => aItems[n]["content"], ;
        "secondaryContent" => If( hb_HHasKey( aItems[n], "secondaryContent" ), aItems[n]["secondaryContent"], nil ) }
        
    if hb_HHasKey( aItems[n], "nClrBack" ) .and. aItems[n]["nClrBack"] != nil
        if aItems[n]["nClrBack"] == -2 .or. ( hb_HHasKey( aItems[n], "isProminent" ) .and. aItems[n]["isProminent"] )
            hItem["isProminent"] := .T.
        else
            aRGBA := hb_ClrToRGBA( aItems[n]["nClrBack"], aItems[n]["nAlphaBack"] )
            hItem["bgColor"] := { "r" => aRGBA[1], "g" => aRGBA[2], "b" => aRGBA[3], "a" => aRGBA[4] }
        endif
    endif
        
    if hb_HHasKey( aItems[n], "nClrFore" ) .and. aItems[n]["nClrFore"] != nil
        aRGBA := hb_ClrToRGBA( aItems[n]["nClrFore"], aItems[n]["nAlphaFore"] )
        hItem["fgColor"] := { "r" => aRGBA[1], "g" => aRGBA[2], "b" => aRGBA[3], "a" => aRGBA[4] }
    endif
        
    AAdd( aJsonData, hItem )
    next
   
    cJson := hb_jsonEncode( aJsonData )
    cJsonIds := SD_VSTK_ADD_BATCH( ::cId, cJson, nil ) 
   
    aIds := hb_jsonDecode( cJsonIds )
   
    if ValType( aIds ) == "A"
        for n := 1 to Len( aIds )
            AAdd( ::aIds, aIds[n] )
            if n <= Len( aItems ) .and. hb_HHasKey( aItems[n], "action" ) .and. !Empty( aItems[n]["action"] )
                oTempItem := TSwiftStackItem():New( aIds[n], Self )
                oTempItem:bAction := aItems[n]["action"]
                SwiftRegisterItem( aIds[n], oTempItem )
            endif
        next
    endif
   
    if ValType( aItems ) == "A" .and. aItems == ::aBatch
        ::aBatch := {} // Reset after flush
    endif

return aIds

//----------------------------------------------------------------------------//

METHOD AddText( cText, bAction ) CLASS TSwiftVStack
return TSwiftLabelStack():New( Self, cText, nil, bAction )

//----------------------------------------------------------------------------//

METHOD AddImage( cName ) CLASS TSwiftVStack
    local cId := SD_VSTK_ADD_SYSTEM_IMAGE_TO( ::cId, cName, nil )
return TSwiftStackItem():New( cId, Self )

METHOD AddButton( cText, bAction ) CLASS TSwiftVStack
return TSwiftButtonStack():New( Self, cText, nil, bAction )

METHOD AddToggle( cCaption, lOn, bAction, lSwitch, cId ) CLASS TSwiftVStack
return TSwiftToggleStack():New( Self, cCaption, lOn, lSwitch, cId, bAction )

METHOD AddSlider( nVal, nMin, nMax, bAction, lGlass, cId ) CLASS TSwiftVStack
return TSwiftSliderStack():New( Self, nVal, nMin, nMax, lGlass, cId, bAction )

//----------------------------------------------------------------------------//

METHOD AddList( oParent ) CLASS TSwiftVStack
    local cId
    local cParentId := If( oParent != nil, oParent:cId, nil )
    cId := SD_VSTK_ADD_LIST( ::cId, cParentId )
return TSwiftStackItem():New( cId, Self )

//----------------------------------------------------------------------------//

METHOD AddRow( cText, bAction ) CLASS TSwiftVStack
    local oItem := ::AddHStack()
    if !Empty( cText ) ; oItem:AddText( cText ) ; endif
    if bAction != nil  ; oItem:bAction := bAction ; endif
return oItem

//----------------------------------------------------------------------------//

METHOD AddHStack( oParent ) CLASS TSwiftVStack
    local cId
    local cParentId := If( oParent != nil, oParent:cId, nil )
    cId := SD_VSTK_ADD_HSTACK( ::cId, cParentId )
return TSwiftStackItem():New( cId, Self )

//----------------------------------------------------------------------------//

METHOD SetScroll( lScroll ) CLASS TSwiftVStack
    DEFAULT lScroll := .T.
    SD_VSTK_SET_SCROLL( ::cId, lScroll )
return nil

//----------------------------------------------------------------------------//

METHOD SetGlass( lGlass ) CLASS TSwiftVStack
    DEFAULT lGlass := .T.
    SD_VSTK_SET_GLASS_EFFECT( ::cId, lGlass )
return nil

//----------------------------------------------------------------------------//

METHOD SetBackgroundColor( nClr, nAlpha ) CLASS TSwiftVStack
return ::SetAccentColor( nClr, nAlpha )

METHOD SetForegroundColor( nClr, nAlpha ) CLASS TSwiftVStack
return ::SetTextColor( nClr, nAlpha )

//----------------------------------------------------------------------------//

METHOD SetInvertedColor( lInvert ) CLASS TSwiftVStack
    DEFAULT lInvert := .T.
    SD_VSTK_SET_INVERTED_COLOR( ::cId, lInvert )
return nil

//----------------------------------------------------------------------------//

METHOD SetSpacing( nSpacing ) CLASS TSwiftVStack
    SD_VSTK_SET_SPACING( ::cId, nSpacing )
return nil

//----------------------------------------------------------------------------//

METHOD SetAlignment( nAlign ) CLASS TSwiftVStack
    SD_VSTK_SET_ALIGNMENT( ::cId, nAlign )
return nil

//----------------------------------------------------------------------------//

METHOD AddSpacer( oParent ) CLASS TSwiftVStack
    local cParentId := If( oParent != nil, oParent:cId, nil )
return SD_VSTK_ADD_SPACER_TO( ::cId, cParentId )

//----------------------------------------------------------------------------//

METHOD AddDivider( oParent ) CLASS TSwiftVStack
    local cParentId := If( oParent != nil, oParent:cId, nil )
return SD_VSTK_ADD_DIVIDER_TO( ::cId, cParentId )

//----------------------------------------------------------------------------//

METHOD SetItemColor( cId, nClr, nAlpha ) CLASS TSwiftVStack
    DEFAULT nAlpha := 100
    sd_vstk_set_item_color( ::cId, cId, nClr, nAlpha )
return nil

//----------------------------------------------------------------------------//

METHOD SetRadius( nRadius ) CLASS TSwiftVStack
    SD_VSTK_SET_ITEM_RADIUS( ::cId, "-1", nRadius )
return nil

//----------------------------------------------------------------------------//

METHOD RemoveAll() CLASS TSwiftVStack
    SD_VSTK_REMOVE_ALL_ITEMS( ::cId )
return nil

//----------------------------------------------------------------------------//

METHOD OnAction( cItemId ) CLASS TSwiftVStack
    local oItem := SwiftGetItem( cItemId )

    if oItem != nil .and. __ObjHasMsg( oItem, "BACTION" ) .and. oItem:bAction != nil
        Eval( oItem:bAction, cItemId, oItem )
        return nil 
    endif

    if ::bAction != nil
        Eval( ::bAction, cItemId, Self )
    endif
return nil

//----------------------------------------------------------------------------//

METHOD End() CLASS TSwiftVStack
    if !Empty( ::hWnd )
        SD_VSTK_DESTROY( ::cId, ::hWnd )
        // Unregister all items from global registry
        SwiftUnregisterItem( ::cId )
        Aeval( ::aIds, { | cId | SwiftUnregisterItem( cId ) } )
        ::aIds := {}
    endif
return ::Super:End()
