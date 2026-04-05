#include "FiveMac.ch"
#include "SwiftControls.ch"

CLASS TSwiftLabel FROM TSwiftControl

    ACCESS Caption      INLINE ::hState["caption"]
    ASSIGN Caption( c ) INLINE ::SetText( c )

    ACCESS Text         INLINE ::hState["caption"]
    ASSIGN Text( c )    INLINE ::SetText( c )

    METHOD New( nTop, nLeft, nWidth, nHeight, cText, oWnd, nAutoResize, cId )
    METHOD SetText( cText )
    METHOD SetFont( nSize )
    METHOD SetBold( lBold )
    METHOD SetAlignment( nAlign )
    METHOD SetAccentColor( nColor, nAlpha )
    METHOD SetTextColor( nColor, nAlpha )
    METHOD OnAction()
    METHOD End()
      
ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, cText, oWnd, nAutoResize, cId ) CLASS TSwiftLabel

   DEFAULT nWidth := 100, nHeight := 40, oWnd := GetWndDefault(), cText := "Label", nAutoResize := 0

   ::Super:New( nTop, nLeft, nWidth, nHeight, cId )

   ::oWnd    := oWnd
   ::hState["caption"] := cText
   ::hState["alignment"] := 0 // Left por defecto
   ::hState["fontsize"] := 14
   ::hState["isbold"] := .F.

   ::Register( SD_SWIFT_LABEL_CREATE( nTop, nLeft, nWidth, nHeight, hb_JsonEncode( ::hState ), oWnd:hWnd, ::cId ) )

   if nAutoResize != 0
       SWIFTAUTORESIZE( ::hWnd, nAutoResize )
   endif

   oWnd:AddControl( Self )

return Self

//----------------------------------------------------------------------------//

METHOD SetText( cText ) CLASS TSwiftLabel
   ::hState["caption"] := cText
   SD_LBL_SET_TEXT( ::cId, cText )
return nil

//----------------------------------------------------------------------------//

METHOD SetFont( nSize ) CLASS TSwiftLabel
   ::hState["fontsize"] := nSize
   SD_LBL_SET_FONT_SIZE( ::cId, nSize )
return nil

//----------------------------------------------------------------------------//

METHOD SetBold( lBold ) CLASS TSwiftLabel
   ::hState["isbold"] := lBold
   SD_LBL_SET_BOLD( ::cId, lBold )
return nil

//----------------------------------------------------------------------------//

METHOD SetAlignment( nAlign ) CLASS TSwiftLabel
   ::hState["alignment"] := nAlign
   // El alineamiento se gestiona en el constructor vía JSON para el inicio,
   // pero para cambios en caliente, podríamos relanzar el sync o crear un SD_ específico.
   ::Sync() 
return nil

//----------------------------------------------------------------------------//

METHOD SetTextColor( nColor, nAlpha ) CLASS TSwiftLabel
    local cHex := ::InitialColorToHex( nColor, nAlpha )
    ::hState["textcolor"] := cHex
    SD_LBL_SET_TEXT_COLOR( ::cId, cHex )
return self

//----------------------------------------------------------------------------//

METHOD SetAccentColor( nColor, nAlpha ) CLASS TSwiftLabel
    local cHex := ::InitialColorToHex( nColor, nAlpha )
    ::hState["bgcolor"] := cHex
    SD_LBL_SET_ACCENT_COLOR( ::cId, cHex )
return self

//----------------------------------------------------------------------------//

METHOD OnAction() CLASS TSwiftLabel
   if ! Empty( ::bAction )
      Eval( ::bAction, Self )
   endif
return nil

//----------------------------------------------------------------------------//

METHOD End() CLASS TSwiftLabel
    if !Empty( ::hWnd )
        SD_LBL_DESTROY( ::cId, ::hWnd )
    endif
return ::Super:End()
