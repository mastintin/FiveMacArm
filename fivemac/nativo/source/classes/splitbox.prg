#include "FiveMac.ch"

//----------------------------------------------------------------------------//

CLASS TSplitBox FROM TControl

    DATA   lVertical
    DATA   aViews INIT {}

    METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, lVertical, nStyle, nAutoResize, nViews )
   
    METHOD AddView() 
   
    METHOD SetVertical( lVertical ) INLINE ;
        ( ::lVertical := lVertical, SplitBoxSetVertical( ::hWnd, ::lVertical ) )

    METHOD SetStyle( nStyle ) INLINE SplitBoxSetStyle( ::hWnd, nStyle ) 

    METHOD SetPosition( nDivider, nPos ) INLINE ;
        SplitBoxSetPosition( ::hWnd, nDivider - 1, nPos )

 
ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, lVertical, nStyle, nAutoResize, nViews ) CLASS TSplitBox

    local n

    DEFAULT nWidth := 100, nHeight := 200, oWnd := GetWndDefault()
    DEFAULT lVertical := .T., nStyle := 2 // NSSplitViewDividerStyleThin
    DEFAULT nAutoResize := 0

    ::hWnd = SplitBoxCreate( nTop, nLeft, nWidth, nHeight, oWnd:hWnd, lVertical )
    ::oWnd = oWnd
    ::lVertical = lVertical
    ::nAutoResize = nAutoResize
   
    ::SetStyle( nStyle )

    if ! Empty( nViews )
        for n = 1 to nViews
            ::AddView()
        next
    endif

    oWnd:AddControl( Self )

return Self

//----------------------------------------------------------------------------//

METHOD AddView() CLASS TSplitBox

    local oSplitItem := TSplitBoxItem():New( Self )
    AAdd( ::aViews, oSplitItem )

return oSplitItem

//----------------------------------------------------------------------------//

//----------------------------------------------------------------------------//

CLASS TSplitBoxItem FROM TControl

    METHOD New( oSplitBox )

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( oSplitBox ) CLASS TSplitBoxItem

    ::hWnd = SplitBoxAddView( oSplitBox:hWnd )
    ::oWnd = oSplitBox
   
    oSplitBox:AddControl( Self )
    AAdd( GetAllWin(), Self )

return Self

//----------------------------------------------------------------------------//
