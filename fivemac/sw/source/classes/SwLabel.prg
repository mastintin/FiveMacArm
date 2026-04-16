#include "FiveMac.ch"

#define SW_TYPE_TEXT 0

CLASS TSwLabel FROM TSwiftControl

    ACCESS Caption    INLINE ::hState["text"]
    ASSIGN Caption(c) INLINE ::SetText(c)

    METHOD New( nTop, nLeft, nWidth, nHeight, cText, oWnd, cId ) CONSTRUCTOR
    METHOD SetText( cText, lSync )

ENDCLASS

// -------------------------------------------------------------------------------- //

METHOD New( nTop, nLeft, nWidth, nHeight, cText, oWnd, cId ) CLASS TSwLabel

    default nWidth := 300, nHeight := 20, cText := ""
    if Empty( cId ) ; cId := hb_UUID() ; endif

    ::nTop := nTop ; ::nLeft := nLeft ; ::nWidth := nWidth ; ::nHeight := nHeight ; ::cId := cId

    ::hState["text"]   := cText
    ::hState["type"]   := SW_TYPE_TEXT

    SW_LABEL_CREATE( ::cId, hb_jsonEncode( ::hState ) )

    if oWnd != nil ; oWnd:AddControl( Self, nTop, nLeft ) ; endif

    SwiftRegisterItem( ::cId, Self )

return self

METHOD SetText( cText, lSync ) CLASS TSwLabel
    DEFAULT lSync := .f.
    ::hState["text"] := cText
    if ( lSync == .T. )
       SDS:Apply( ::cId, { "text" => cText } )
    else
       SD:Apply( ::cId, { "text" => cText } )
    endif
return nil
