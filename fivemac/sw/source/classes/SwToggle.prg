#include "FiveMac.ch"

#define SW_TYPE_TOGGLE 10

CLASS TSwToggle FROM TSwiftControl

    ACCESS Value      INLINE ::hState["value"]
    ASSIGN Value( l ) INLINE ::SetValue( l )

    ACCESS Prompt     INLINE ::hState["prompt"]
    ASSIGN Prompt( c ) INLINE ( ::hState["prompt"] := c, SD:Apply( ::cId, { "prompt" => c } ) )

    ACCESS Switch     INLINE ::hState["isSwitch"]
    ASSIGN Switch( l ) INLINE ::hState["isSwitch"] := l

   METHOD New( nTop, nLeft, nWidth, nHeight, lValue, cPrompt, oWnd, cId, lSwitch ) CONSTRUCTOR
   METHOD SetValue( lValue, lSync )

ENDCLASS

// -------------------------------------------------------------------------------- //

METHOD New( nTop, nLeft, nWidth, nHeight, lValue, cPrompt, oWnd, cId, lSwitch, nAutoResize ) CLASS TSwToggle
    
    DEFAULT nWidth := 200, nHeight := 30, lValue := .F., cPrompt := "", lSwitch := .F.
    if Empty( cId ) ; cId := hb_UUID() ; endif

    ::Super:New( nTop, nLeft, nWidth, nHeight, cId, nAutoResize )
    
    ::hState["value"]    := lValue
    ::hState["prompt"]   := cPrompt
    ::hState["isSwitch"] := lSwitch
    ::hState["type"]     := SW_TYPE_TOGGLE

    SW_TOGGLE_CREATE( ::cId, hb_jsonEncode( ::hState ) )

    if oWnd != nil ; oWnd:AddControl( Self, nTop, nLeft ) ; endif

    SwiftRegisterItem( ::cId, Self )

return self

METHOD SetValue( lValue, lSync ) CLASS TSwToggle
    DEFAULT lSync := .f.
    ::hState["value"] := lValue
    if ( lSync == .T. )
       SDS:Apply( ::cId, { "value" => lValue } )
    else
       SD:Apply( ::cId, { "value" => lValue } )
    endif
return nil
