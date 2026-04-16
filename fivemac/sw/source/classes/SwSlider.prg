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

    METHOD New( nTop, nLeft, nWidth, nHeight, nValue, nMin, nMax, oWnd, cId, bAction )
    METHOD SetValue( nVal, lSync )
    METHOD Update( hNewState )

ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, nValue, nMin, nMax, oWnd, cId, bAction ) CLASS TSwSlider

    default nWidth := 200, nHeight := 30, nValue := 0, nMin := 0, nMax := 100
    if Empty( cId ) ; cId := hb_UUID() ; endif

    ::nTop := nTop ; ::nLeft := nLeft ; ::nWidth := nWidth ; ::nHeight := nHeight ; ::cId := cId ; ::bAction := bAction
    
    ::hState["value"]     := nValue
    ::hState["min"]       := nMin
    ::hState["max"]       := nMax
    ::hState["showValue"] := .T.
    ::hState["type"]      := SW_TYPE_SLIDER

    SW_SLIDER_CREATE( ::cId, hb_jsonEncode( ::hState ) )

    if oWnd != nil ; oWnd:AddControl( Self, nTop, nLeft ) ; endif

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
