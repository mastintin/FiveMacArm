#include "FiveMac.ch"

// -------------------------------------------------------------------------------- //
// NEW: Private dispatcher for Sw (Pure Swift) components
// -------------------------------------------------------------------------------- //
function SW_FMH( cId, nMsg )
    local oItem := SwiftGetItem( cId )

    // MsgInfo( "SW_FMH Arrived! ID: " + cId + " Msg: " + AllTrim( Str( nMsg ) ) )

    if oItem != nil 
        do case
           case nMsg == 9 // WM_BTNCLICK
                if __ObjHasMsg( oItem, "BACTION" ) .and. oItem:bAction != nil
                   Eval( oItem:bAction, oItem:cId, oItem )
                endif
        endcase
    endif
return nil
