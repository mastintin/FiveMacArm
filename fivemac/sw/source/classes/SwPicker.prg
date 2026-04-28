#include "swfive.ch"
 
 #define SW_TYPE_PICKER 18
 
 CLASS TSwPicker FROM TSwiftControl
 
    DATA bChange
    DATA aItems
 
    METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, aItems, bChange, cId, nAutoResize, cPrompt, nStyle )
    METHOD SetItems( aItems )
    METHOD Set( cValue )      INLINE ::Apply( { "selection" => cValue } )
    METHOD OnChange( cValue )
 
 ENDCLASS
 
 //----------------------------------------------------------------------------//
 
 METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, aItems, bChange, cId, nAutoResize, cPrompt, nStyle ) CLASS TSwPicker
 
    DEFAULT nWidth := 150, nHeight := 44, aItems := {}, nStyle := 0
 
    ::Super:New( nTop, nLeft, nWidth, nHeight, cId, nAutoResize )
    ::oWnd    := oWnd
    ::aItems  := aItems
    ::bChange := bChange
 
    if hb_IsObject( oWnd )
       ::hState["parentid"] := oWnd:cId
    endif
 
    ::hState["type"] := SW_TYPE_PICKER
    
    ::Create()
 
    ::SetItems( aItems )
 
    if !Empty( cPrompt )
       ::Apply( { "prompt" => cPrompt } )
    endif
 
    if nStyle != 0
       ::Apply( { "style" => nStyle } )
    endif
 
 return Self
 
 //----------------------------------------------------------------------------//
 
 METHOD SetItems( aItems ) CLASS TSwPicker
    local cJson := "["
    local n
 
    ::aItems := aItems
 
    for n := 1 to Len( aItems )
        if n > 1 ; cJson += "," ; endif
        cJson += '"' + aItems[n] + '"'
    next
    cJson += "]"
 
    ::Apply( { "items" => cJson } )
 
 return nil
 
 //----------------------------------------------------------------------------//
 
 METHOD OnChange( cValue ) CLASS TSwPicker
    if ::bChange != nil
       Eval( ::bChange, cValue, Self )
    endif
 return nil
