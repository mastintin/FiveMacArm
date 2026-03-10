#include "FiveMac.ch"


#define SWIFT_TYPE_TEXT          0
#define SWIFT_TYPE_SYSTEMIMAGE   1
#define SWIFT_TYPE_HSTACK        2
#define SWIFT_TYPE_IMAGEFILE     3
#define SWIFT_TYPE_VSTACK        4
#define SWIFT_TYPE_HSTACKCONTAINER 5
#define SWIFT_TYPE_SPACER        6
#define SWIFT_TYPE_LAZYVGRID     7
#define SWIFT_TYPE_LIST          8
#define SWIFT_TYPE_BUTTON        9
#define SWIFT_TYPE_DIVIDER       10

CLASS TSwiftVStack FROM TControl

    DATA nIndex
    DATA bAction // Codeblock {|nItemIndex| ... }
    DATA aBatch INIT {}

    METHOD New( nRow, nCol, nWidth, nHeight, oWnd )
    METHOD AddItem( nType, cContent, bAction, cSecondary )
    METHOD AddBatch( aItems )
    
    // Legacy / Convenience methods
    METHOD AddText( cText )
    METHOD AddImage( cSystemName )
     
    METHOD AddButton( cText, bAction )
    METHOD AddHStack( oParent )
    METHOD AddList( oParent )
    METHOD AddRow( cText, bAction )
    METHOD SetScroll( lScroll )
    METHOD SetBackgroundColor( nRed, nGreen, nBlue, nAlpha )
    METHOD SetForegroundColor( nRed, nGreen, nBlue, nAlpha )
    METHOD SetScrollable( lScroll )
    METHOD SetBgColorHex( cHex )
    METHOD SetFgColorHex( cHex )
    METHOD SetInvertedColor( lInvert )
    METHOD SetSpacing( nSpacing )
    METHOD SetAlignment( nAlign )
    METHOD AddSpacer()
    METHOD AddDivider()
    
    METHOD SetLastItemId( cId )
    METHOD GetLastItemId() INLINE VSTK_GET_LAST_ITEM_ID( hb_ntos( ::nIndex ) )
    METHOD SetItemColor( cId, nRed, nGreen, nBlue, nAlpha ) 
    METHOD SetItemText( cId, cText ) INLINE VSTK_SET_ITEM_TEXT( hb_ntos( ::nIndex ), cId, cText )
    METHOD AddSystemImage( cName ) INLINE ::AddImage( cName )
    METHOD SetRadius( nRadius )
    METHOD RemoveAll()

    METHOD RegItem( cId, oItem ) INLINE SwiftRegisterItem( cId, oItem )

ENDCLASS

METHOD New( nRow, nCol, nWidth, nHeight, oWnd, nAutoResize ) CLASS TSwiftVStack

    DEFAULT nWidth := 200, nHeight := 300
    DEFAULT oWnd := GetWndDefault(), nAutoResize := 0

    ::nIndex = SwiftRegisterControl( Self )
    ::aBatch := {}

    ::hWnd = VSTK_CREATE( oWnd:hWnd, ::nIndex, nRow, nCol, nWidth, nHeight )
   
    if nAutoResize != 0
    SWIFTAUTORESIZE( ::hWnd, nAutoResize )
    endif

    oWnd:AddControl( Self )

return Self

METHOD AddItem( nType, cContent, bAction, cSecondary, nClrFore, nClrBack, nAlphaFore, nAlphaBack ) CLASS TSwiftVStack
    AAdd( ::aBatch, { "type" => nType, "content" => cContent, "action" => bAction, ;
        "secondaryContent" => cSecondary, "nClrFore" => nClrFore, "nClrBack" => nClrBack, ;
        "nAlphaFore" => nAlphaFore, "nAlphaBack" => nAlphaBack } )
return nil

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
    hItem["bg"] := { "r" => nRGBRed( aItems[n]["nClrBack"] ) / 255.0, ;
        "g" => nRGBGreen( aItems[n]["nClrBack"] ) / 255.0, ;
        "b" => nRGBBlue( aItems[n]["nClrBack"] ) / 255.0, ;
        "a" => If( hb_HHasKey( aItems[n], "nAlphaBack" ) .and. aItems[n]["nAlphaBack"] != nil, aItems[n]["nAlphaBack"], 1.0 ) }
    endif
        
    if hb_HHasKey( aItems[n], "nClrFore" ) .and. aItems[n]["nClrFore"] != nil
    hItem["fg"] := { "r" => nRGBRed( aItems[n]["nClrFore"] ) / 255.0, ;
        "g" => nRGBGreen( aItems[n]["nClrFore"] ) / 255.0, ;
        "b" => nRGBBlue( aItems[n]["nClrFore"] ) / 255.0, ;
        "a" => If( hb_HHasKey( aItems[n], "nAlphaFore" ) .and. aItems[n]["nAlphaFore"] != nil, aItems[n]["nAlphaFore"], 1.0 ) }
    endif
        
    AAdd( aJsonData, hItem )
    next
   
    cJson := hb_jsonEncode( aJsonData )
    // Pass ::nIndex as rootID
    cJsonIds := VSTK_ADD_BATCH( hb_ntos( ::nIndex ), cJson, nil ) 
   
    aIds := hb_jsonDecode( cJsonIds )
   
    if ValType( aIds ) == "A"
    for n := 1 to Len( aIds )
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

METHOD AddText( cText, bAction ) CLASS TSwiftVStack
    local cId := VSTK_ADD_TEXT_TO( hb_ntos( ::nIndex ), cText, nil )
    local oItem := TSwiftStackItem():New( cId, Self )
    if bAction != nil ; oItem:bAction := bAction ; endif
return oItem

METHOD AddImage( cName ) CLASS TSwiftVStack
    local cId := VSTK_ADD_SYSTEM_IMAGE_TO( hb_ntos( ::nIndex ), cName, nil )
return TSwiftStackItem():New( cId, Self )

METHOD AddButton( cText, bAction ) CLASS TSwiftVStack
    local cId, oItem
    cId := VSTK_ADD_BUTTON_ITEM( hb_ntos( ::nIndex ), cText, nil )
    oItem := TSwiftStackItem():New( cId, Self )
    if bAction != nil .and. !Empty( cId )
    oItem:bAction := bAction
    endif
return oItem

METHOD AddList( oParent ) CLASS TSwiftVStack
    local cId, oItem
    local cParentId := If( oParent != nil, oParent:cId, nil )
    cId := VSTK_ADD_LIST( hb_ntos( ::nIndex ), cParentId )
return TSwiftStackItem():New( cId, Self )

METHOD AddRow( cText, bAction ) CLASS TSwiftVStack
    local oItem
    oItem := ::AddHStack()
    if !Empty( cText )
    oItem:AddText( cText )
    endif
    if bAction != nil
    oItem:bAction := bAction
    endif
return oItem

METHOD AddHStack( oParent ) CLASS TSwiftVStack
    local cId
    local cParentId := If( oParent != nil, oParent:cId, nil )
    cId := VSTK_ADD_HSTACK( hb_ntos( ::nIndex ), cParentId )
return TSwiftStackItem():New( cId, Self )

METHOD SetScroll( lScroll ) CLASS TSwiftVStack
    DEFAULT lScroll := .T.
    VSTK_SET_SCROLL( hb_ntos( ::nIndex ), lScroll )
return nil

METHOD SetBackgroundColor( nRed, nGreen, nBlue, nAlpha ) CLASS TSwiftVStack
    local nClr 
    DEFAULT nAlpha := 1.0
    
    if pcount() <= 2
    nClr   := nRed
    else
    nClr := nRGB( nRed, nGreen, nBlue )
    endif

    VSTK_SET_BGCOLOR_HEX( hb_ntos( ::nIndex ), clrToHex( nClr, nAlpha ) )
return nil

METHOD SetInvertedColor( lInvert ) CLASS TSwiftVStack
    DEFAULT lInvert := .T.
    VSTK_SET_INVERTED_COLOR( hb_ntos( ::nIndex ), lInvert )
return nil

function SwiftVStackGetControl( nIndex )
return SwiftGetControl( nIndex )

METHOD SetForegroundColor( nRed, nGreen, nBlue, nAlpha ) CLASS TSwiftVStack
    local nClr 
    DEFAULT nAlpha := 1.0
    
    if pcount() <= 2
    nClr   := nRed
    else
    nClr := nRGB( nRed, nGreen, nBlue )
    endif

    VSTK_SET_FGCOLOR_HEX( hb_ntos( ::nIndex ), clrToHex( nClr, nAlpha ) )
return nil

METHOD SetSpacing( nSpacing ) CLASS TSwiftVStack
    VSTK_SET_SPACING( hb_ntos( ::nIndex ), hb_ntos( nSpacing ) )
return nil


METHOD SetAlignment( nAlign ) CLASS TSwiftVStack
    VSTK_SET_ALIGNMENT( hb_ntos( ::nIndex ), hb_ntos( nAlign ) )
return nil

METHOD AddSpacer( oParent ) CLASS TSwiftVStack
    local cParentId := If( oParent != nil, oParent:cId, nil )
return VSTK_ADD_SPACER_TO( hb_ntos( ::nIndex ), cParentId )

METHOD AddDivider( oParent ) CLASS TSwiftVStack
    local cParentId := If( oParent != nil, oParent:cId, nil )
return VSTK_ADD_DIVIDER_TO( hb_ntos( ::nIndex ), cParentId )

METHOD SetItemColor( cId, nRed, nGreen, nBlue, nAlpha ) CLASS TSwiftVStack
    DEFAULT nRed := 0, nGreen := 0, nBlue := 0
    DEFAULT nAlpha := 1.0
    VSTK_SET_ITEM_COLOR_HEX( hb_ntos( ::nIndex ), cId, clrToHex( nRGB( nRed, nGreen, nBlue ), nAlpha ) )
return nil

METHOD SetRadius( nRadius ) CLASS TSwiftVStack
    VSTK_SET_ITEM_RADIUS( hb_ntos( ::nIndex ), "-1", nRadius )
return nil

METHOD RemoveAll() CLASS TSwiftVStack
    VSTK_REMOVE_ALL_ITEMS( hb_ntos( ::nIndex ) )
return nil

METHOD SetScrollable( lScroll ) CLASS TSwiftVStack
    ::lScrollable := lScroll
    VSTK_SET_SCROLL( hb_ntos( ::nIndex ), If( lScroll, "1", "0" ) )
return nil

METHOD SetBgColorHex( cHex ) CLASS TSwiftVStack
    ::cBgColorHex := cHex
    VSTK_SET_BGCOLOR_HEX( hb_ntos( ::nIndex ), cHex )
return nil

METHOD SetFgColorHex( cHex ) CLASS TSwiftVStack
    ::cFgColorHex := cHex
    VSTK_SET_FGCOLOR_HEX( hb_ntos( ::nIndex ), cHex )
return nil

METHOD SetLastItemId( cId ) CLASS TSwiftVStack
return nil
