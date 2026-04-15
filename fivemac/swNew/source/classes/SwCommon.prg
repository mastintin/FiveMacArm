#include "FiveMac.ch"

//----------------------------------------------------------------------------//
// Gestión de Registro Local para la Isla 'sw'
//----------------------------------------------------------------------------//

static shObjects := {=>}

function SwRegisterItem( cId, oObj )
   shObjects[ cId ] = oObj
return nil

function SwUnregisterItem( cId )
   if hb_HHasKey( shObjects, cId )
      hb_HDel( shObjects, cId )
   endif
return nil

function SwGetItem( cId )
   if hb_HHasKey( shObjects, cId )
      return shObjects[ cId ]
   endif
return nil

//----------------------------------------------------------------------------//
// Despachador de Eventos para la Isla 'sw'
//----------------------------------------------------------------------------//

function SW_ONACTION( cId )
   local oObj := SwGetItem( cId )
   if ! Empty( oObj ) .and. oObj:HasMethod( "Click" )
      oObj:Click()
   endif
return nil

function SW_ONCHANGE( cId, value )
   local oObj := SwGetItem( cId )
   if ! Empty( oObj ) .and. oObj:HasMethod( "OnChange" )
      oObj:OnChange( value )
   endif
return nil
