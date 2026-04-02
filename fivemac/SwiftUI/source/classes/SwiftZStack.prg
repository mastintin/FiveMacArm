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

    DATA cID
    DATA bAction
    DATA hItems INIT {=>}
    DATA aBatch INIT {}

    ASSIGN OnAction( b )    INLINE ::bAction := b
    
    ASSIGN BgColor( c )     INLINE ::SetBackgroundColor( c )
    ASSIGN FgColor( c )     INLINE ::SetForegroundColor( c )
    
    ASSIGN Alignment( n )   INLINE ::SetAlignment( n )

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

    METHOD AddBatch( aItems )
    METHOD AddItem( nType, cContent, bAction, cSecondary, nClrFore, nClrBack, nAlphaFore, nAlphaBack )
    METHOD SetLastItemId( cId )
    METHOD GetLastItemId() INLINE SD_ZSTK_GET_LAST_ITEM_ID( ::cId )
    METHOD End()

ENDCLASS

METHOD New( nRow, nCol, nWidth, nHeight, oWnd, nAutoResize ) CLASS TSwiftZStack

    DEFAULT nWidth := 200
    DEFAULT nHeight := 200
    DEFAULT oWnd := GetWndDefault(), nAutoResize := 0

    ::oWnd = oWnd
    ::cId := ""
    ::hItems := {=>}
    ::aBatch := {}

    ::hWnd = SD_SWIFT_ZSTACK_CREATE( nRow, nCol, nWidth, nHeight, oWnd:hWnd, ::cId )
    ::cId := SW_GET_ID( ::hWnd )

    if nAutoResize != 0
    SWIFTAUTORESIZE( ::hWnd, nAutoResize )
    endif

    oWnd:AddControl( Self )

return Self

METHOD AddText( cText ) CLASS TSwiftZStack
    local cId
    cId := SD_ZSTK_ADD_ITEM( ::cId, cText )
return cId

METHOD AddImage( cSystemName ) CLASS TSwiftZStack
    local cId
    cId := SD_ZSTK_ADD_IMAGE( ::cId, cSystemName )
return cId

METHOD AddImageFile( cFile ) CLASS TSwiftZStack
    local cId
    cId := SD_ZSTK_ADD_FILE_IMAGE( ::cId, cFile )
return cId

METHOD AddButton( cText, bAction ) CLASS TSwiftZStack
    local cId, oItem
    cId := SD_ZSTK_ADD_BUTTON_TO( ::cId, cText, nil )
    if bAction != nil .and. !Empty( cId )
    oItem := TSwiftStackItem():New( cId, Self )
    oItem:bAction := bAction
    SwiftRegisterItem( cId, oItem )
    endif
return cId

METHOD AddVStack( oParent ) CLASS TSwiftZStack
    local cId
    local cParentId := If( oParent != nil, oParent:cId, nil )
    cId := SD_ZSTK_ADD_VSTACK( ::cId, cParentId )
return TSwiftStackItem():New( cId, Self )

METHOD Reset() CLASS TSwiftZStack
    SD_ZSTK_REMOVE_ALL_ITEMS( ::cId )
return nil

METHOD AddHStack( oParent ) CLASS TSwiftZStack
    local cId
    local cParentId := If( oParent != nil, oParent:cId, nil )
    cId := SD_ZSTK_ADD_HSTACK( ::cId, cParentId )
return TSwiftStackItem():New( cId, Self )

METHOD SetAlignment( nAlign ) CLASS TSwiftZStack
    SD_ZSTK_SET_ALIGNMENT( ::cId, nAlign )
return nil

METHOD AddGrid( aColumns ) CLASS TSwiftZStack
    local cId
    local cJsonColumns 
    
    DEFAULT aColumns := {}
    cJsonColumns := hb_jsonEncode( aColumns )
    
    cId := SD_ZSTK_ADD_LAZYVGRID( ::cId, nil, cJsonColumns )
return TSwiftStackItem():New( cId, Self )

METHOD AddList( oParent ) CLASS TSwiftZStack
    local cId
    local cParentId := If( oParent != nil, oParent:cId, nil )
    cId := SD_ZSTK_ADD_LIST( ::cId, cParentId )
return TSwiftStackItem():New( cId, Self )

METHOD SetForegroundColor( nRed, nGreen, nBlue, nAlpha ) CLASS TSwiftZStack
    local nClr 
    DEFAULT nAlpha := 1.0
    
    if pcount() <= 2
    nClr   := nRed
    else
    nClr := nRGB( nRed, nGreen, nBlue )
    endif

    SD_ZSTK_SET_FGCOLOR_HEX( ::cId, clrToHex( nClr, nAlpha ) )
return nil

METHOD SetBackgroundColor( nRed, nGreen, nBlue, nAlpha ) CLASS TSwiftZStack
    local nClr 
    DEFAULT nAlpha := 1.0
    
    if pcount() <= 2
    nClr   := nRed
    else
    nClr := nRGB( nRed, nGreen, nBlue )
    endif

    SD_ZSTK_SET_BGCOLOR_HEX( ::cId, clrToHex( nClr, nAlpha ) )
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
    cJsonIds := SD_ZSTK_ADD_BATCH( ::cId, cJson, nil ) // nil parent for root
   
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

METHOD SetLastItemId( cId ) CLASS TSwiftZStack
    SD_ZSTK_SET_LAST_ITEM_ID( ::cId, cId )
return nil

METHOD End() CLASS TSwiftZStack
   SD_ZSTK_DESTROY( ::cId, ::hWnd )
   ::hWnd = nil
   ::cId  = ""
return nil


//---------------------------------------------------------//

// TSwiftStackItem moved to SwiftStackItem.prg
