#include "FiveMac.ch"

static s_hRegistry := {=>}
static s_aControls := {}

// -------------------------------------------------------------------------------- //

function SwiftRegisterItem( cId, oItem )

    if s_hRegistry == nil
    s_hRegistry = {=>}
    endif

    if Empty( cId ) 
       return nil
    endif

    if ValType( cId ) == "C"
       cId = AllTrim( cId )
    endif

    s_hRegistry[ cId ] := oItem
   
return nil

// -------------------------------------------------------------------------------- //

function SwiftUnregisterItem( cId )

    if s_hRegistry == nil ; return nil ; endif

    if !Empty( cId ) .and. ValType( cId ) == "C"
       cId = AllTrim( cId )
       if hb_HHasKey( s_hRegistry, cId )
          hb_HDel( s_hRegistry, cId )
       endif
    endif

return nil

// -------------------------------------------------------------------------------- //

function SwiftGetItem( cId )
    if ValType( cId ) == "C"
       cId = AllTrim( cId )
    endif
return If( hb_HHasKey( s_hRegistry, cId ), s_hRegistry[ cId ], nil )

// -------------------------------------------------------------------------------- //

function SwiftRegisterControl( oControl )
    AAdd( s_aControls, oControl )
return Len( s_aControls )

// -------------------------------------------------------------------------------- //

function SwiftGetControl( nIndex )
    if nIndex > 0 .and. nIndex <= Len( s_aControls )
    return s_aControls[ nIndex ]
    endif
return nil

// -------------------------------------------------------------------------------- //

function SwiftOnAction( nControlIndex, cItemId )
    local oItem, oControl

    if s_hRegistry == nil
    s_hRegistry = {=>}
    endif

    cItemId = AllTrim( cItemId )
    // 1. Try global registry (for individual items registered with SwiftRegisterItem)
    oItem = SwiftGetItem( cItemId )
    
    if oItem != nil 
    if ValType( oItem ) == "A" .and. Len( oItem ) >= 2
    // Legacy array-based registration
    if __ObjHasMsg( oItem[1], "BACTION" ) .and. oItem[1]:bAction != nil
    Eval( oItem[1]:bAction, oItem[2], oItem )
    endif 
    elseif ValType( oItem ) == "O"
    // New TSwiftStackItem or TControl based registration
    if __ObjHasMsg( oItem, "BACTION" ) .and. oItem:bAction != nil
    Eval( oItem:bAction, oItem:cId, oItem ) 
    endif 
    endif 
    // Note: we don't return here yet, we still want to call control-level bAction if it exists
    endif

    // 2. Fallback: Check if it's a control level action
    if nControlIndex > 0
    oControl = SwiftGetControl( nControlIndex )
    if oControl != nil .and. oControl:bAction != nil
    // Pass both Id and the object (if found)
    Eval( oControl:bAction, cItemId, oItem )
    endif
    endif

return nil

// -------------------------------------------------------------------------------- //

function SW_ONACTION( cId, uParam1, uParam2 )
    local oItem := SwiftGetItem( cId )
    if oItem != nil .and. __ObjHasMsg( oItem, "ONACTION" )
       oItem:OnAction( uParam1, uParam2 )
    endif
return nil

// -------------------------------------------------------------------------------- //

function SW_ONCHANGE( cId, uValue )
    local oItem := SwiftGetItem( cId )
    if oItem != nil .and. __ObjHasMsg( oItem, "ONCHANGE" )
       oItem:OnChange( uValue )
    endif
return nil

// -------------------------------------------------------------------------------- //

function SW_ONVALIDATE( cId, uValue )
    local oItem := SwiftGetItem( cId )
    local lValid := .T.
    if oItem != nil .and. __ObjHasMsg( oItem, "BVALID" ) .and. oItem:bValid != nil
       lValid := Eval( oItem:bValid, uValue, oItem )
    endif
return lValid
