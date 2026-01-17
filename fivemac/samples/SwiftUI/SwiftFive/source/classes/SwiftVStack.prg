#include "FiveMac.ch"

static aSwiftControls := {}

CLASS TSwiftVStack FROM TControl

    DATA nIndex
    DATA bAction // Codeblock {|nItemIndex| ... }

    METHOD New( nRow, nCol, nWidth, nHeight, oWnd )
    METHOD AddItem( cText )
    METHOD AddImage( cSystemName )
    METHOD AddRow( cImage, cText )
    METHOD SetScroll( lScroll )
    METHOD SetBackgroundColor( nRed, nGreen, nBlue, nAlpha )
    METHOD SetForegroundColor( nRed, nGreen, nBlue, nAlpha )
    METHOD SetInvertedColor( lInvert )
    METHOD SetSpacing( nSpacing )
    METHOD SetAlignment( nAlign )

ENDCLASS

METHOD New( nRow, nCol, nWidth, nHeight, oWnd ) CLASS TSwiftVStack

    DEFAULT nWidth := 200, nHeight := 300
    DEFAULT oWnd := GetWndDefault()

    ::nIndex = Len( aSwiftControls ) + 1
    AAdd( aSwiftControls, Self )

    ::hWnd = SWIFTVSTACKCREATE( oWnd:hWnd, ::nIndex, nRow, nCol, nWidth, nHeight )
   
    oWnd:AddControl( Self )

return Self

METHOD AddItem( cText ) CLASS TSwiftVStack
    SWIFTVSTACKADDITEM( cText )
return nil

METHOD AddImage( cSystemName ) CLASS TSwiftVStack
    SWIFTVSTACKADDSYSTEMIMAGE( cSystemName )
return nil

METHOD AddRow( cImage, cText ) CLASS TSwiftVStack
    SWIFTVSTACKADDHSTACK( cImage, cText )
return nil

METHOD SetScroll( lScroll ) CLASS TSwiftVStack
    DEFAULT lScroll := .T.
    SWIFTVSTACKSETSCROLL( lScroll )
return nil

METHOD SetBackgroundColor( nRed, nGreen, nBlue, nAlpha ) CLASS TSwiftVStack
    DEFAULT nRed := 0, nGreen := 0, nBlue := 0
    DEFAULT nAlpha := 1.0  // 100% visible by default logic, but usually alpha is typically 0.0-1.0 range
   
    // Convert 0-255 to 0.0-1.0
    // Note: If user passes small floats < 1.0, they might mean 0-1, but strictly 0-255 is safer to divide
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
    // 0: Center, 1: Leading, 2: Trailing
    SWIFTVSTACKSETALIGNMENT( nAlign )
return nil
