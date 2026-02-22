#include "FiveMac.ch"

//----------------------------------------------------------------------------//
// Real-Time Object Inspector helper function
//----------------------------------------------------------------------------//

static oInsp

function Inspector()

    if oInsp == nil .or. ( ValType( oInsp ) == "O" .and. Empty( oInsp:hWnd ) )
    oInsp := TObjInspector():New()
    endif
   
    oInsp:Show()
    oInsp:SetFocus()

return oInsp

//----------------------------------------------------------------------------//
