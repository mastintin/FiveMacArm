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

    METHOD New( nTop, nLeft, nWidth, nHeight, cPrompt, oWnd, bAction )
    METHOD Click()
    METHOD SetColor( nFgColor, nBgColor )
    METHOD SetRadius( nRadius )
    METHOD SetPadding( nPadding )

ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, cPrompt, oWnd, bAction ) CLASS TSwiftButton

    DEFAULT nWidth := 90, nHeight := 30, oWnd := GetWndDefault(), cPrompt := "SwiftBtn"

    ::bAction = bAction
    ::oWnd    = oWnd
    ::nId     = ::GetCtrlIndex()
   
    AAdd( aSwiftButtons, Self )
    ::nIndex  = Len( aSwiftButtons )

    // Pass ::nIndex (Param 7) instead of Action String
    ::hWnd = SWIFTBTNCREATE( nTop, nLeft, nWidth, nHeight, cPrompt, oWnd:hWnd, ::nIndex )

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
    SWIFTBTNSETBGCOLOR( nBgColor )
    endif
    if nFgColor != nil
    SWIFTBTNSETFGCOLOR( nFgColor )
    endif
return nil

METHOD SetRadius( nRadius ) CLASS TSwiftButton
    SWIFTBTNSETRADIUS( nRadius )
return nil

METHOD SetPadding( nPadding ) CLASS TSwiftButton
    SWIFTBTNSETPADDING( nPadding )
return nil

// Called from C callback
function SwiftBtnOnClick( nIndex )
   
    if nIndex > 0 .and. nIndex <= Len( aSwiftButtons )
    aSwiftButtons[ nIndex ]:Click()
    endif
   
return nil
