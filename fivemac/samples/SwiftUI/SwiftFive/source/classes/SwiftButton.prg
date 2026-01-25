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

return nil

METHOD SetColor( nFgColor, nBgColor ) CLASS TSwiftButton
    if nBgColor != nil
    SWIFTBTNSETBGCOLOR( nBgColor, ::nIndex )
    endif
    if nFgColor != nil
    SWIFTBTNSETFGCOLOR( nFgColor, ::nIndex )
    endif
return nil

METHOD SetRadius( nRadius ) CLASS TSwiftButton
    SWIFTBTNSETRADIUS( nRadius, ::nIndex )
return nil

METHOD SetPadding( nPadding ) CLASS TSwiftButton
    SWIFTBTNSETPADDING( nPadding, ::nIndex )
return nil

METHOD SetGlass( lGlass ) CLASS TSwiftButton
    DEFAULT lGlass := .T.
    ::lGlass := lGlass
    SWIFTBTNSETGLASS( lGlass, ::nIndex )
return nil

METHOD SetImage( cImage ) CLASS TSwiftButton
    if cImage != nil
    SWIFTBTNSETIMAGE( cImage, ::nIndex )
    endif
return nil

// Called from C callback
function SwiftBtnOnClick( nIndex )
   
    if nIndex > 0 .and. nIndex <= Len( aSwiftButtons )
    aSwiftButtons[ nIndex ]:Click()
    endif
   
return nil
