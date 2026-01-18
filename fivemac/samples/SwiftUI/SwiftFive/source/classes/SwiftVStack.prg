#include "FiveMac.ch"

static aSwiftControls := {}

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
    METHOD AddText( cText ) INLINE ::AddItem( SWIFT_TYPE_TEXT, cText )
    METHOD AddImage( cSystemName )
    METHOD AddButton( cText, bAction )
    METHOD AddHStack()
    METHOD AddList()
    METHOD AddRow( cImage, cText )
    METHOD SetScroll( lScroll )
    METHOD SetBackgroundColor( nRed, nGreen, nBlue, nAlpha )
    METHOD SetForegroundColor( nRed, nGreen, nBlue, nAlpha )
    METHOD SetInvertedColor( lInvert )
    METHOD SetSpacing( nSpacing )
    METHOD SetAlignment( nAlign )
    
    METHOD RegItem( cId, oItem ) INLINE SwiftRegisterItem( cId, oItem )

ENDCLASS

METHOD New( nRow, nCol, nWidth, nHeight, oWnd ) CLASS TSwiftVStack

    DEFAULT nWidth := 200, nHeight := 300
    DEFAULT oWnd := GetWndDefault()

    ::nIndex = Len( aSwiftControls ) + 1
    AAdd( aSwiftControls, Self )
    ::aBatch := {}

    ::hWnd = SWIFTVSTACKCREATE( oWnd:hWnd, ::nIndex, nRow, nCol, nWidth, nHeight )
   
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
    local oItem, oTempItem, hItem
   
    DEFAULT aItems := ::aBatch
   
    if Empty( aItems )
    return {}
    endif

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
    cJsonIds := SWIFTVSTACKADDBATCH( cJson, nil ) // nil parent for root
   
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

METHOD AddImage( cSystemName ) CLASS TSwiftVStack
    SWIFTVSTACKADDSYSTEMIMAGE( cSystemName )
return nil

METHOD AddButton( cText, bAction ) CLASS TSwiftVStack
    local cId, oItem
    cId := SWIFTVSTACKADDBUTTON( cText )
    if bAction != nil .and. !Empty( cId )
    oItem := TSwiftStackItem():New( cId, Self )
    oItem:bAction := bAction
    SwiftRegisterItem( cId, oItem )
    endif
return nil

METHOD AddList( oParent ) CLASS TSwiftVStack
    local cId
    local cParentId := If( oParent != nil, oParent:cId, nil )
    cId := SWIFTVSTACKADDLIST( cParentId )
return TSwiftStackItem():New( cId, Self )

METHOD AddRow( cImage, cText ) CLASS TSwiftVStack
    SWIFTVSTACKADDHSTACK( cImage, cText )
return nil

METHOD AddHStack() CLASS TSwiftVStack
    local cId, oItem
    cId := SWIFTVSTACKADDHSTACKCONTAINER( nil ) 
    oItem := TSwiftStackItem():New( cId, Self )
return oItem

METHOD SetScroll( lScroll ) CLASS TSwiftVStack
    DEFAULT lScroll := .T.
    SWIFTVSTACKSETSCROLL( lScroll )
return nil

METHOD SetBackgroundColor( nRed, nGreen, nBlue, nAlpha ) CLASS TSwiftVStack
    DEFAULT nRed := 0, nGreen := 0, nBlue := 0
    DEFAULT nAlpha := 1.0
    SWIFTVSTACKSETBGCOLOR( nRed / 255.0, nGreen / 255.0, nBlue / 255.0, nAlpha )
return nil

METHOD SetInvertedColor( lInvert ) CLASS TSwiftVStack
    DEFAULT lInvert := .T.
    SWIFTVSTACKSETINVERTEDCOLOR( lInvert )
return nil

//----------------------------------------------------------------//

function SwiftVStackOnClick( nControlIndex, nItemIndex )
    local oControl
   
    if nControlIndex > 0 .and. nControlIndex <= Len( aSwiftControls )
    oControl = aSwiftControls[ nControlIndex ]
    if oControl:bAction != nil
    Eval( oControl:bAction, nItemIndex )
    endif
    endif
   
return nil

METHOD SetForegroundColor( nRed, nGreen, nBlue, nAlpha ) CLASS TSwiftVStack
    DEFAULT nRed := 0, nGreen := 0, nBlue := 0
    DEFAULT nAlpha := 1.0
    SWIFTVSTACKSETFGCOLOR( nRed, nGreen, nBlue, nAlpha )
return nil

METHOD SetSpacing( nSpacing ) CLASS TSwiftVStack
    SWIFTVSTACKSETSPACING( nSpacing )
return nil

METHOD SetAlignment( nAlign ) CLASS TSwiftVStack
    SWIFTVSTACKSETALIGNMENT( nAlign )
return nil
