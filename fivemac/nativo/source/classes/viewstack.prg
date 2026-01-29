#include "FiveMac.ch"

//----------------------------------------------------------------------------//

CLASS TViewStack FROM TPanel

    DATA   aViews
    DATA   nCurrent
    DATA   oBar       // Instance of TViewStackBar
    DATA   aItems     // Now inside oBar mostly, but kept for mapping views? 
    DATA   nBarHeight

    // Actually TViewStack maps index -> view. 
    // oBar maps index -> visually highlighted button.

    METHOD New( oWnd, nTop, nLeft, nWidth, nHeight, nBarHeight )
   
    METHOD AddView( cTitle, cImage )
    METHOD SetView( nIndex )
    METHOD FindControl( hWnd ) 
    
    METHOD SetButtonSize( nWidth, nHeight ) INLINE ::oBar:SetButtonSize( nWidth, nHeight ) 

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( oWnd, nTop, nLeft, nWidth, nHeight , nBarHeight ) CLASS TViewStack

    DEFAULT oWnd := GetWndDefault()
    DEFAULT nTop := 0, nLeft := 0
    DEFAULT nWidth := oWnd:nWidth(), nHeight := oWnd:nHeight()
    DEFAULT nBarHeight := 60
    
    ::Super:New( nTop, nLeft, nWidth, nHeight, oWnd )
    ::SetFlipped( .T. )
   
    ::aViews   := {}
    ::nCurrent := 0
   
    // Create the native "Modern" Toolbar using the new class
    // Height 60

    // Create the native "Modern" Toolbar using the new class
    // Height 60
    ::nBarHeight := nBarHeight
    ::oBar := TViewStackBar():New( 0, 0, ::nWidth, ::nBarHeight, Self )
   
return Self

//----------------------------------------------------------------------------//

METHOD AddView( cTitle, cImage ) CLASS TViewStack

    local oPanel, oItem
    local nIndex

    DEFAULT cTitle := "View " + AllTrim( Str( Len( ::aViews ) + 1 ) )
    DEFAULT cImage := "" 

    nIndex := Len( ::aViews ) + 1

    // 1. Add Button to Bar
    oItem := ::oBar:AddButton( cTitle, cImage, {|| ::SetView( nIndex ) } )
    
    // We map the item? ::oBar handles the buttons. 
    // We just need to know that index 'n' corresponds to view 'n'.

    // 2. Create View Panel (Below the bar area)
    // Assuming bar height 60.
    oPanel := TPanel():New( ::nBarHeight, 0, ::nWidth, ::nHeight - ::nBarHeight, Self )
   
    if ::lFlipped
    oPanel:SetFlipped( .T. )
    endif
   
    oPanel:_nAutoResize( 18 ) // Width (2) + Height (16)

   
    AAdd( ::aViews, oPanel )
   
    // Selection Logic
    if nIndex == 1
    ::SetView( 1 )
    else
    oPanel:Hide()
    endif

return oPanel

//----------------------------------------------------------------------------//


//----------------------------------------------------------------------------//

METHOD SetView( nIndex ) CLASS TViewStack

    local n
   
    if nIndex > 0 .and. nIndex <= Len( ::aViews )
    ::nCurrent := nIndex
      
    for n := 1 to Len( ::aViews )
    if n == nIndex
    ::aViews[ n ]:Show()
    else
    ::aViews[ n ]:Hide()
    endif
    next
       
    // Delegate visual update to the bar
    ::oBar:SetOption( nIndex )
       
    endif


return nil

//----------------------------------------------------------------------------//

METHOD FindControl( hWnd ) CLASS TViewStack

    local nAt := AScan( ::aItems, { | o | o:hWnd == hWnd } )

    if nAt != 0
    return ::aItems[ nAt ]
    endif

    // Also check child panels
    nAt := AScan( ::aViews, { | o | o:hWnd == hWnd } )
    if nAt != 0
    return ::aViews[ nAt ] // Found a panel directly
    else
    // If panels have children, TWindow checks them via ::aControls
    // But TViewStack is a TPanel/TControl, so TWindow calls its FindControl recursively?
    // No, standard TControl:FindControl is recursive in TWindow logic.
    endif

return nil

//----------------------------------------------------------------------------//
