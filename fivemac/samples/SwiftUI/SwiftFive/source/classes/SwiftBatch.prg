#include "FiveMac.ch"

//----------------------------------------------------------------------------//

CLASS TSwiftBatch

    DATA  aControls   INIT {}
    DATA  oWnd

    METHOD New( oWnd )
    METHOD Add( oControl )
    METHOD Create()
   
ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( oWnd ) CLASS TSwiftBatch

    ::oWnd = oWnd
   
return Self

//----------------------------------------------------------------------------//

METHOD Add( oControl ) CLASS TSwiftBatch

    AAdd( ::aControls, oControl )
   
return nil

//----------------------------------------------------------------------------//

METHOD Create() CLASS TSwiftBatch

    local aBatchConfigs := {}
    local oControl
    local cJson, aHandles
    local n 

    for each oControl in ::aControls
    AAdd( aBatchConfigs, oControl:GetConfig() )
    next

    cJson := hb_jsonEncode( aBatchConfigs )
   
    // SWIFTSTANDALONEBATCHCREATE now returns an array of handles (pointers)
    aHandles := SWIFTSTANDALONEBATCHCREATE( ::oWnd:hWnd, cJson )
   
    if ValType( aHandles ) == "A"
    for n := 1 to Len( ::aControls )
    if n <= Len( aHandles )
    ::aControls[ n ]:hWnd = aHandles[ n ]
    endif
    next
    endif

return nil

//----------------------------------------------------------------------------//
