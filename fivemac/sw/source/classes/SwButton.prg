#include "FiveMac.ch"

CLASS TSwButton FROM TSwiftControl

    DATA bAction
    DATA bPipeline    // NUEVO: Puntero de autopista directa para Lotes

    ACCESS Caption      INLINE ::hState["caption"]
    ASSIGN Caption( c ) INLINE ::SetText( c )

    METHOD New( nTop, nLeft, nWidth, nHeight, cPrompt, oWnd, bAction, nAutoResize, cId )
    METHOD OnAction()
    METHOD SetText( cText )
    METHOD End()
      
ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, cPrompt, oWnd, bAction, nAutoResize, cId ) CLASS TSwButton

    DEFAULT nWidth := 90, nHeight := 30, cPrompt := "SwBtn", nAutoResize := 0
    
    if Empty( cId ) ; cId := hb_UUID() ; endif

    ::Super:New( nTop, nLeft, nWidth, nHeight, cId )
    
    ::bAction  := bAction
    ::oWnd     := oWnd
    ::hState["caption"] := cPrompt
    ::hState["type"]    := 9
   
    // 1. Crear el estado y el item en Swift
    SW_BUTTON_CREATE( ::cId, hb_jsonEncode( ::hState ) )
    
    // 2. Registrar en Harbour
    SwiftRegisterItem( ::cId, Self )
    
    // 3. Añadir a la ventana
    if oWnd != nil
        oWnd:AddControl( Self, nTop, nLeft )
    endif

return Self

METHOD SetText( cText ) CLASS TSwButton
    SD:Text( ::cId, cText )
return nil

METHOD OnAction() CLASS TSwButton
    if ::bPipeline != nil
        // Autopista Transaccional: Empaqueta y ejecuta el lote de Swift de forma garantizada
        WITH OBJECT Sw_GetProxy()
            :Pipeline( ::bPipeline )
        END
    elseif ::bAction != nil
        Eval( ::bAction, Self )
    endif
return nil

METHOD End() CLASS TSwButton
    SwiftUnregisterItem( ::cId )
return ::Super:End()
