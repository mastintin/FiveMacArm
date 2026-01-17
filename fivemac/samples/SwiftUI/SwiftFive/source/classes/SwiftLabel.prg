#include "FiveMac.ch"
#include "SwiftControls.ch"

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
   
    ::hWnd = SWIFTLABELCREATE( nTop, nLeft, nWidth, nHeight, cText, oWnd:hWnd )

    oWnd:AddControl( Self )

return Self

METHOD SetText( cText ) CLASS TSwiftLabel
   
    // Reuse the existing generic label updater for now
    // In future we might want instance-specific updating if we store the hosting controller
    SwiftUpdateLabel( "SwiftFive.SwiftLabelLoader", cText )

return nil

METHOD SetFont( nSize ) CLASS TSwiftLabel
    SWIFTLABELSETFONT( nSize )
return nil

METHOD SetColor( nColor ) CLASS TSwiftLabel
    SWIFTLABELSETCOLOR( nColor )
return nil
