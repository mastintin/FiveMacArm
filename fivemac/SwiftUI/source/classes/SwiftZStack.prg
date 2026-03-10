#include "FiveMac.ch"

// Removed s_hRegistry from here, now in SwiftCommon.prg

INIT PROCEDURE SwiftZStackInit()
    // s_hRegistry initialization handled in SwiftCommon or lazy init
return

// SwiftVStackOnAction removed - moved to SwiftCommon.prg as SwiftOnAction
// SwiftRegisterItem removed - moved to SwiftCommon.prg

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

CLASS TSwiftZStack FROM TControl

    DATA nIndex
    DATA bAction
    DATA hItems INIT {=>}
    DATA aBatch INIT {}

    METHOD New( nRow, nCol, nWidth, nHeight, oWnd )
    
    METHOD RegItem( cId, oItem ) INLINE SwiftRegisterItem( cId, oItem )
    METHOD GetItem( cId ) INLINE SwiftGetItem( cId ) 
    
    METHOD AddText( cText )
    METHOD AddButton( cText, bAction )
    METHOD AddImage( cSystemName )
    METHOD AddImageFile( cFile )
    METHOD Reset()
    
    METHOD AddVStack( oParent )
    METHOD AddHStack( oParent )
    
    METHOD SetAlignment( nAlign )
    METHOD SetBackgroundColor( nRed, nGreen, nBlue, nAlpha )
    METHOD SetForegroundColor( nRed, nGreen, nBlue, nAlpha )
    
    METHOD AddGrid( aColumns ) // Returns Item
    METHOD AddList( oParent )  // Returns Item

    METHOD AddItem( nType, cContent, bAction, cSecondary, nClrFore, nClrBack, nAlphaFore, nAlphaBack )
    METHOD AddBatch( aItems )

ENDCLASS

METHOD New( nRow, nCol, nWidth, nHeight, oWnd, nAutoResize ) CLASS TSwiftZStack

    DEFAULT nWidth := 200
    DEFAULT nHeight := 200
    DEFAULT oWnd := GetWndDefault(), nAutoResize := 0

    ::oWnd = oWnd
    
    ::nIndex = SwiftRegisterControl( Self )
    ::hItems := {=>}
    ::aBatch := {}

    ::hWnd = ZSTK_CREATE( oWnd:hWnd, hb_ntos( ::nIndex ), nRow, nCol, nWidth, nHeight )

    if nAutoResize != 0
    SWIFTAUTORESIZE( ::hWnd, nAutoResize )
    endif

    oWnd:AddControl( Self )

return Self

METHOD AddText( cText ) CLASS TSwiftZStack
    local cId
    cId := ZSTK_ADD_ITEM( hb_ntos( ::nIndex ), cText )
return cId

METHOD AddImage( cSystemName ) CLASS TSwiftZStack
    local cId
    cId := ZSTK_ADD_IMAGE( hb_ntos( ::nIndex ), cSystemName )
return cId

METHOD AddImageFile( cFile ) CLASS TSwiftZStack
    local cId
    cId := ZSTK_ADD_FILE_IMAGE( hb_ntos( ::nIndex ), cFile )
return cId

METHOD AddButton( cText, bAction ) CLASS TSwiftZStack
    local cId, oItem
    cId := ZSTK_ADD_BUTTON_TO( hb_ntos( ::nIndex ), cText, nil )
    if bAction != nil .and. !Empty( cId )
    oItem := TSwiftStackItem():New( cId, Self )
    oItem:bAction := bAction
    SwiftRegisterItem( cId, oItem )
    endif
return cId

METHOD AddVStack( oParent ) CLASS TSwiftZStack
    local cId
    local cParentId := If( oParent != nil, oParent:cId, nil )
    cId := ZSTK_ADD_VSTACK( hb_ntos( ::nIndex ), cParentId )
return TSwiftStackItem():New( cId, Self )

METHOD Reset() CLASS TSwiftZStack
    ZSTK_REMOVE_ALL_ITEMS( hb_ntos( ::nIndex ) )
return nil

METHOD AddHStack( oParent ) CLASS TSwiftZStack
    local cId
    local cParentId := If( oParent != nil, oParent:cId, nil )
    cId := ZSTK_ADD_HSTACK( hb_ntos( ::nIndex ), cParentId )
return TSwiftStackItem():New( cId, Self )

METHOD SetAlignment( nAlign ) CLASS TSwiftZStack
    ZSTK_SET_ALIGNMENT( hb_ntos( ::nIndex ), hb_ntos( nAlign ) )
return nil

METHOD AddGrid( aColumns ) CLASS TSwiftZStack
    local cId
    local cJsonColumns 
    
    DEFAULT aColumns := {}
    cJsonColumns := hb_jsonEncode( aColumns )
    
    cId := ZSTK_ADD_LAZYVGRID( hb_ntos( ::nIndex ), nil, cJsonColumns )
return TSwiftStackItem():New( cId, Self )

METHOD AddList( oParent ) CLASS TSwiftZStack
    local cId
    local cParentId := If( oParent != nil, oParent:cId, nil )
    cId := ZSTK_ADD_LIST( hb_ntos( ::nIndex ), cParentId )
return TSwiftStackItem():New( cId, Self )

METHOD SetForegroundColor( nRed, nGreen, nBlue, nAlpha ) CLASS TSwiftZStack
    local nClr 
    DEFAULT nAlpha := 1.0
    
    if pcount() <= 2
    nClr   := nRed
    else
    nClr := nRGB( nRed, nGreen, nBlue )
    endif

    ZSTK_SET_FGCOLOR_HEX( hb_ntos( ::nIndex ), clrToHex( nClr, nAlpha ) )
return nil

METHOD SetBackgroundColor( nRed, nGreen, nBlue, nAlpha ) CLASS TSwiftZStack
    local nClr 
    DEFAULT nAlpha := 1.0
    
    if pcount() <= 2
    nClr   := nRed
    else
    nClr := nRGB( nRed, nGreen, nBlue )
    endif

    ZSTK_SET_BGCOLOR_HEX( hb_ntos( ::nIndex ), clrToHex( nClr, nAlpha ) )
return nil

METHOD AddItem( nType, cContent, bAction, cSecondary, nClrFore, nClrBack, nAlphaFore, nAlphaBack ) CLASS TSwiftZStack
    AAdd( ::aBatch, { "type" => nType, "content" => cContent, "action" => bAction, ;
        "secondaryContent" => cSecondary, "nClrFore" => nClrFore, "nClrBack" => nClrBack, ;
        "nAlphaFore" => nAlphaFore, "nAlphaBack" => nAlphaBack } )
return nil

METHOD AddBatch( aItems ) CLASS TSwiftZStack
    local aJsonData := {}
    local aIds, n, cJson, cJsonIds, oTempItem, hItem
   
    DEFAULT aItems := ::aBatch
    if Empty( aItems ) ; return {} ; endif

    for n := 1 to Len( aItems )
    hItem := { "type" => aItems[n]["type"], ;
        "content" => aItems[n]["content"], ;
        "secondaryContent" => If( hb_HHasKey( aItems[n], "secondaryContent" ), aItems[n]["secondaryContent"], nil ) }
        
    if hb_HHasKey( aItems[n], "nClrBack" ) .and. aItems[n]["nClrBack"] != nil
    hItem["bgHex"] := clrToHex( aItems[n]["nClrBack"], If( hb_HHasKey( aItems[n], "nAlphaBack" ), aItems[n]["nAlphaBack"], nil ) )
    endif
    if hb_HHasKey( aItems[n], "nClrFore" ) .and. aItems[n]["nClrFore"] != nil
    hItem["fgHex"] := clrToHex( aItems[n]["nClrFore"], If( hb_HHasKey( aItems[n], "nAlphaFore" ), aItems[n]["nAlphaFore"], nil ) )
    endif
    AAdd( aJsonData, hItem )
    next
   
    cJson := hb_jsonEncode( aJsonData )
    cJsonIds := ZSTK_ADD_BATCH( hb_ntos( ::nIndex ), cJson, nil ) // nil parent for root
   
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


//---------------------------------------------------------//

// TSwiftStackItem moved to SwiftStackItem.prg
