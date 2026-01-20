#include "FiveMac.ch"
#include "SwiftControls.ch"

static aSwiftLabels := {}

CLASS TSwiftLabel FROM TControl

    DATA nIndex

    METHOD New( nTop, nLeft, nWidth, nHeight, cText, oWnd )
    METHOD SetText( cText )
    METHOD SetFont( nSize )
    METHOD SetColor( nColor )

ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, cText, oWnd ) CLASS TSwiftLabel

    DEFAULT nWidth := 100, nHeight := 20, oWnd := GetWndDefault(), cText := "Swift Label"

    ::oWnd    = oWnd
    ::nId     = ::GetCtrlIndex()
    
    AAdd( aSwiftLabels, Self )
    ::nIndex = Len( aSwiftLabels )
   
    // Pass ::nIndex (Param 7)
    ::hWnd = SWIFTLABELCREATE( nTop, nLeft, nWidth, nHeight, cText, oWnd:hWnd, ::nIndex )

    oWnd:AddControl( Self )

return Self

METHOD SetText( cText ) CLASS TSwiftLabel
   
    SwiftUpdateLabel( "SwiftFive.SwiftLabelLoader", cText, ::nIndex )

return nil

METHOD SetFont( nSize ) CLASS TSwiftLabel
    SWIFTLABELSETFONT( nSize, ::nIndex )
return nil

METHOD SetColor( nColor ) CLASS TSwiftLabel
    SWIFTLABELSETCOLOR( nColor, ::nIndex )
return nil
