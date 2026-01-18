#include "FiveMac.ch"

static s_hRegistry := {=>}

// -------------------------------------------------------------------------------- //

function SwiftRegisterItem( cId, oItem )

    if s_hRegistry == nil
    s_hRegistry = {=>}
    endif

    cId = AllTrim( cId ) // Clean key - CRITICAL FIX
    // MsgAlert( "DEBUG: [Harbour] Registering Item: '" + cId + "' Len: " + Str(Len(cId)) + " Type: " + ValType(oItem) )
    // SysWait( 0.1 ) // Validate Timing Hypothesis
    // LogFile( "swift_debug.log", { "Registering", cId, ValType(oItem) } )
    s_hRegistry[ cId ] := oItem
   
return nil

// -------------------------------------------------------------------------------- //

function SwiftGetItem( cId )
    if s_hRegistry == nil
    return nil 
    endif 
return If( hb_HHasKey( s_hRegistry, cId ), s_hRegistry[ cId ], nil )

// -------------------------------------------------------------------------------- //

function SwiftOnAction( nControlIndex, cItemId )
    local oItem

    // MsgAlert( "DEBUG: [Harbour] SwiftOnAction Called! Item: " + hb_ValToExp(cItemId) )

    if s_hRegistry == nil
    // MsgAlert( "DEBUG: Registry is NIL" )
    return nil 
    endif

    cItemId = AllTrim( cItemId ) // Clean key - CRITICAL FIX
    // MsgAlert( "DEBUG: [Harbour] Querying Item: '" + cItemId + "' Len: " + Str(Len(cItemId)) )

    oItem = SwiftGetItem( cItemId )
    
    if oItem == nil
    // MsgAlert( "DEBUG: Item NOT Found in Registry!" )
    return nil
    endif

    // MsgAlert( "DEBUG: Item Found! Type: " + ValType(oItem) )

    if oItem != nil 
      
    // Case 1: Array { Parent, Index } - Standard Child Item
    if ValType( oItem ) == "A" .and. Len( oItem ) >= 2
    if __ObjHasMsg( oItem[1], "BACTION" ) .and. oItem[1]:bAction != nil
    Eval( oItem[1]:bAction, oItem[2] )
    endif 
         
    // Case 2: Object (TSwiftStackItem) - Direct Item
    elseif ValType( oItem ) == "O"
    if __ObjHasMsg( oItem, "BACTION" ) .and. oItem:bAction != nil
    Eval( oItem:bAction, oItem ) 
    endif 
    endif 
      
    endif 

return nil
