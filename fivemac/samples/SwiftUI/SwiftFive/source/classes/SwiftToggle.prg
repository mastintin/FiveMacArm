#include "FiveMac.ch"

static aSwiftToggles := {}

CLASS TSwiftToggle FROM TControl

    DATA cID
    DATA nIndex
    DATA cCaption
    DATA bChange
    DATA lOn
    DATA lSwitch

    METHOD New( nTop, nLeft, nWidth, nHeight, cCaption, lOn, lSwitch, oWnd, bChange )
    METHOD Set( lOn )
    METHOD Get()

ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, cCaption, lOn, lSwitch, oWnd, bChange, nAutoResize ) CLASS TSwiftToggle

    DEFAULT nWidth := 100, nHeight := 30
    DEFAULT lOn := .F.
    DEFAULT cCaption := ""
    DEFAULT lSwitch := .F.
    DEFAULT nAutoResize := 0

    ::nTop     = nTop
    ::nLeft    = nLeft
    ::nWidth   = nWidth
    ::nHeight  = nHeight
    ::cCaption = cCaption
    ::lOn      = lOn
    ::lSwitch  = lSwitch
   
    ::bChange  = bChange
    ::oWnd     = oWnd
    ::cID      = SWIFT_UUID()
   
    AAdd( aSwiftToggles, Self )
    ::nIndex   = Len( aSwiftToggles )

    ::hWnd = SWIFTTOGGLECREATE( nTop, nLeft, nWidth, nHeight, cCaption, lOn, oWnd:hWnd, ::nIndex, ::cID, ::lSwitch )

    if nAutoResize != 0
    SWIFTAUTORESIZE( ::hWnd, nAutoResize )
    endif

    oWnd:AddControl( Self )

return Self

METHOD Set( lOn ) CLASS TSwiftToggle
    
    ::lOn = lOn
    SWIFTTOGGLESET( lOn, ::cID )
   
    if ::bChange != nil
    Eval( ::bChange, ::lOn )
    endif

return nil

METHOD Get() CLASS TSwiftToggle
   
    ::lOn = SWIFTTOGGLEGET( ::nIndex )
   
return ::lOn

// ---------------------------------------------------------------------------

function SwiftToggleOnChange( nIndex, lOn )
   
    local oControl

    if nIndex > 0 .and. nIndex <= Len( aSwiftToggles )
    oControl = aSwiftToggles[ nIndex ]
    oControl:lOn = lOn
    if oControl:bChange != nil
    Eval( oControl:bChange, lOn )
    endif
    endif

return nil
