#include "FiveMac.ch"

#define SW_TYPE_SLIDER 11

CLASS TSwSlider FROM TSwiftControl

    DATA bAction

    ACCESS Value      INLINE ::hState["value"]
    ASSIGN Value( n ) INLINE ::SetValue( n )

    ACCESS Min        INLINE ::hState["min"]
    ASSIGN Min( n )   INLINE ( ::hState["min"] := n, SD:Apply( ::cId, { "min" => n } ) )

    ACCESS Max        INLINE ::hState["max"]
    ASSIGN Max( n )   INLINE ( ::hState["max"] := n, SD:Apply( ::cId, { "max" => n } ) )

    METHOD New( nTop, nLeft, nWidth, nHeight, nValue, nMin, nMax, oWnd, cId, bAction, nAutoResize )
    METHOD SetValue( nVal, lSync )
    METHOD Update( hNewState )

ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, nValue, nMin, nMax, oWnd, cId, bAction, nAutoResize ) CLASS TSwSlider
   
   DEFAULT nWidth := 200, nHeight := 30
   
   if Empty( cId ) ; cId := hb_UUID() ; endif
   
   ::Super:New( nTop, nLeft, nWidth, nHeight, cId, nAutoResize )
   
   ::bAction := bAction
    
   ::hState["value"]     := nValue
   ::hState["min"]       := nMin
   ::hState["max"]       := nMax
   ::hState["showValue"] := .T.
   ::hState["type"]      := 11
   
   ::oWnd    := oWnd
   ::Create()


    SwiftRegisterItem( ::cId, Self )

return self

METHOD SetValue( nVal, lSync ) CLASS TSwSlider
    DEFAULT lSync := .f.
    ::hState["value"] := nVal
    if ( lSync == .T. )
       SDS:Apply( ::cId, { "value" => nVal } )
    else
       SD:Apply( ::cId, { "value" => nVal } )
    endif
    if ::bAction != nil ; Eval( ::bAction, nVal, Self ) ; endif
return nil

METHOD Update( hNewState ) CLASS TSwSlider
    local cKey, nOldVal := ::Value
    
    ::Super:Update( hNewState )
    
    if ::Value != nOldVal .and. ::bAction != nil
        Eval( ::bAction, ::Value, Self )
    endif
return nil
