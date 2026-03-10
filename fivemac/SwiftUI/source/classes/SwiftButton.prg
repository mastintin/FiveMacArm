#include "FiveMac.ch"

static aSwiftButtons := {}

#xcommand @ <nRow>, <nCol> SWIFTBUTTON [ <oBtn> PROMPT ] <cCaption> ;
    [ SIZE <nWidth>, <nHeight> ] ;
    [ OF <oWnd> ] ;
    [ ACTION <uAction> ] ;
    => ;
    [ <oBtn> := ] TSwiftButton():New( <nRow>, <nCol>, <nWidth>, <nHeight>, <cCaption>, <oWnd>, [<{uAction}>] )

CLASS TSwiftButton FROM TControl

    DATA bAction
    DATA nIndex
    DATA lGlass

    METHOD New( nTop, nLeft, nWidth, nHeight, cPrompt, oWnd, bAction )
    METHOD Click()
    METHOD SetColor( nFgColor, nBgColor )
    METHOD SetRadius( nRadius )
    METHOD SetPadding( nPadding )
    METHOD SetGlass( lGlass )
    METHOD SetText( cText )  INLINE BTN_SET_TEXT( hb_ntos( ::nIndex ), cText )
    METHOD SetImage( cImage ) 
    METHOD SetAutoResize( nAutoResize ) INLINE  if(nAutoResize != 0 , SWIFTAUTORESIZE( ::hWnd, nAutoResize ), )
      
ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, cPrompt, oWnd, bAction, nAutoResize ) CLASS TSwiftButton

    DEFAULT nWidth := 90, nHeight := 30, oWnd := GetWndDefault(), cPrompt := "SwiftBtn", nAutoResize := 0

    ::bAction = bAction
    ::oWnd    = oWnd
    ::nId     = ::GetCtrlIndex()
   
    AAdd( aSwiftButtons, Self )
    ::nIndex  = Len( aSwiftButtons )

    // Pass ::nIndex (Param 7) instead of Action String
    ::hWnd = SWIFTBTNCREATE( nTop, nLeft, nWidth, nHeight, cPrompt, oWnd:hWnd, ::nIndex )

    if nAutoResize != 0
    SWIFTAUTORESIZE( ::hWnd, nAutoResize )
    endif

    oWnd:AddControl( Self )

return Self

METHOD Click() CLASS TSwiftButton
   
    if ::bAction != nil
    Eval( ::bAction, Self )
    endif

return nil

METHOD SetColor( nFgColor, nBgColor ) CLASS TSwiftButton
    if nBgColor != nil
    BTN_SET_BG( hb_ntos( ::nIndex ), clrToHex( nBgColor ) )
    endif
    if nFgColor != nil
    BTN_SET_FG( hb_ntos( ::nIndex ), clrToHex( nFgColor ) )
    endif
return nil

METHOD SetRadius( nRadius ) CLASS TSwiftButton
    BTN_SET_RADIUS( hb_ntos( ::nIndex ), hb_ntos( nRadius ) )
return nil

METHOD SetPadding( nPadding ) CLASS TSwiftButton
    BTN_SET_PADDING( hb_ntos( ::nIndex ), hb_ntos( nPadding ) )
return nil

METHOD SetGlass( lGlass ) CLASS TSwiftButton
    DEFAULT lGlass := .T.
    ::lGlass := lGlass
    BTN_SET_GLASS( hb_ntos( ::nIndex ), if( lGlass, "1", "0" ) )
return nil

METHOD SetImage( cImage ) CLASS TSwiftButton
    if cImage != nil
    BTN_SET_IMAGE( hb_ntos( ::nIndex ), cImage )
    endif
return nil

// Called from C callback
function SwiftBtnOnClick( nIndex )
   
    if nIndex > 0 .and. nIndex <= Len( aSwiftButtons )
    aSwiftButtons[ nIndex ]:Click()
    endif
   
return nil
