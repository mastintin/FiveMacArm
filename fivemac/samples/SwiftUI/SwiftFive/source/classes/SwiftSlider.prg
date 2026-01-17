#include "FiveMac.ch"
#include "SwiftControls.ch"

static aSwiftSliders := {}

CLASS TSwiftSlider FROM TControl

    DATA bChange
    DATA nIndex

    METHOD New( nTop, nLeft, nWidth, nHeight, nValue, oWnd, bChange )
    METHOD SetValue( nValue ) // Todo
   
ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, nValue, oWnd, bChange ) CLASS TSwiftSlider

    DEFAULT nWidth := 200, nHeight := 40, nValue := 50
    DEFAULT oWnd := GetWndDefault()

    ::oWnd    = oWnd
    ::nId     = ::GetCtrlIndex()
    ::bChange = bChange
   
    AAdd( aSwiftSliders, Self )
    ::nIndex = Len( aSwiftSliders )

    ::hWnd = SWIFTSLIDERCREATE( nTop, nLeft, nWidth, nHeight, nValue, oWnd:hWnd, ::nIndex )

    oWnd:AddControl( Self )

return Self

METHOD SetValue( nValue ) CLASS TSwiftSlider
return nil

// The C callback calls this function
function SwiftSliderOnChange( nIndex, nValue )
    local oSlider
   
    if nIndex > 0 .and. nIndex <= Len( aSwiftSliders )
    oSlider = aSwiftSliders[ nIndex ]
    if oSlider:bChange != nil
    Eval( oSlider:bChange, nValue, oSlider )
    endif
    endif
return nil
