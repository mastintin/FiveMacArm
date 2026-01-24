#include "FiveMac.ch"

//----------------------------------------------------------------------------//

CLASS TViewStackBar FROM TControl

    DATA   aItems
   
    METHOD New( nTop, nLeft, nWidth, nHeight, oWnd )
   
    METHOD AddButton( cText, cImage, bAction )
    METHOD SetOption( nOption )
   
    METHOD SetButtonSize( nWidth, nHeight )
    METHOD SetColor( nColor )
    
    METHOD AddControl( oControl ) INLINE AAdd( ::aControls, oControl ), oControl:oWnd := Self
    METHOD FindControl( hWnd )

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, nWidth, nHeight, oWnd ) CLASS TViewStackBar

    DEFAULT nTop := 0, nLeft := 0
    DEFAULT nWidth := 300, nHeight := 60
    DEFAULT oWnd := GetWndDefault()

    ::Super:New( nTop, nLeft, nWidth, nHeight, oWnd )
   
    ::aItems    := {}
    ::aControls := {}
   
    // Create the native control
    // Note: ViewStackBarCreate is the C function name in viewstackbar.m
    ::hWnd := ViewStackBarCreate( nTop, nLeft, nWidth, nHeight, oWnd:hWnd )
   
    // Ensure generic control setup
    oWnd:AddControl( Self )
   
    // Apply Flipped if parent is flipped? 
    // Native implementation forces isFlipped=YES internally now.
   
return Self

//----------------------------------------------------------------------------//

METHOD AddButton( cText, cImage, bAction ) CLASS TViewStackBar

    local hBtn, oItem
   
    DEFAULT cText := ""
    DEFAULT cImage := ""
   
    hBtn := ViewStackBarAddButton( ::hWnd, cText, cImage )
   
    // We could wrap the button in a TControl/TBtn object if we wanted events on it
    // For now, TViewStack used a lightweight TStackItem wrapper.
    // We will replicate that pattern or just store the handle/action.
   
    oItem := TStackItem():New( hBtn, Self, bAction )

    if ::aItems == nil
    ::aItems := {}
    endif
    
    if oItem == nil
    return nil
    endif

    oItem:nIndex := Len( ::aItems ) + 1
   
    AAdd( ::aItems, oItem )
   
return oItem

//----------------------------------------------------------------------------//

METHOD SetOption( nOption ) CLASS TViewStackBar

    local n
   
    if nOption > 0 .and. nOption <= Len( ::aItems )
    for n := 1 to Len( ::aItems )
    if n == nOption
    BtnSetState( ::aItems[ n ]:hWnd, 1 ) // Highlight
    else
    BtnSetState( ::aItems[ n ]:hWnd, 0 ) // Normal
    endif
    next
    endif

return nil

//----------------------------------------------------------------------------//

METHOD SetButtonSize( nWidth, nHeight ) CLASS TViewStackBar

    DEFAULT nWidth := 90, nHeight := 40
   
    ViewStackBarSetButtonSize( ::hWnd, nWidth, nHeight )
   
return nil

//----------------------------------------------------------------------------//

METHOD SetColor( nColor ) CLASS TViewStackBar

    local nRed   := nRgbRed( nColor )
    local nGreen := nRgbGreen( nColor )
    local nBlue  := nRgbBlue( nColor )

    ViewStackBarSetColor( ::hWnd, nRed, nGreen, nBlue, 255 )

return nil

//----------------------------------------------------------------------------//

METHOD FindControl( hWnd ) CLASS TViewStackBar

    local n, oControl

    for n = 1 to Len( ::aControls )
    if ::aControls[ n ]:hWnd == hWnd
    return ::aControls[ n ]
    endif
    next

return nil

//----------------------------------------------------------------------------//
