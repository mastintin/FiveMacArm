#include "FiveMac.ch"
#include "SwiftControls.ch"

CLASS TSwiftTextField FROM TSwiftControl

    ACCESS Value      INLINE ::hState["text"]
    ASSIGN Value( c ) INLINE ::SetText( c )

    ACCESS Placeholder       INLINE ::hState["placeholder"]
    ASSIGN Placeholder( c )  INLINE ::hState["placeholder"] := c

    ACCESS Caption      INLINE ::hState["caption"]
    ASSIGN Caption( c ) INLINE ::hState["caption"] := c
    
    METHOD New( nTop, nLeft, nWidth, nHeight, cText, cPlaceholder, oWnd, bAction, nAutoResize, cId, cCaption, lSecure )
    METHOD SetText( cText )
    METHOD GetText()     INLINE ::hState["text"]
    METHOD SetFontSize( nSize )
    METHOD SetTextColor( nColor, nAlpha )
    METHOD SetAccentColor( nColor, nAlpha )
    
    METHOD OnChange( cNewText )
    METHOD End()

ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, cText, cPlaceholder, oWnd, bAction, nAutoResize, cId, cCaption, lSecure ) CLASS TSwiftTextField

    DEFAULT nWidth := 200, nHeight := 48, oWnd := GetWndDefault() 
    DEFAULT cText := "", cPlaceholder := "Enter text...", nAutoResize := 0, cCaption := "", lSecure := .F.

    ::Super:New( nTop, nLeft, nWidth, nHeight, cId )

    ::oWnd       = oWnd
    ::bAction    = bAction
    
    ::hState["text"]        := cText
    ::hState["placeholder"] := cPlaceholder
    ::hState["caption"]     := cCaption
    ::hState["issecure"]    := lSecure
    ::hState["fontsize"]    := 13

    ::Register( SD_SWIFT_TEXTFIELD_CREATE( nTop, nLeft, nWidth, nHeight, hb_JsonEncode( ::hState ), oWnd:hWnd, ::cId ) )

    if nAutoResize != 0
        SWIFTAUTORESIZE( ::hWnd, nAutoResize )
    endif

    oWnd:AddControl( Self )

return Self

//----------------------------------------------------------------------------//

METHOD SetText( cText ) CLASS TSwiftTextField
   ::hState["text"] := cText
   SD_TF_SET_TEXT( ::cId, cText )
return nil

//----------------------------------------------------------------------------//

METHOD SetFontSize( nSize ) CLASS TSwiftTextField
   ::hState["fontsize"] := nSize
   SD_TF_SET_FONT_SIZE( ::cId, nSize )
return nil

//----------------------------------------------------------------------------//

METHOD SetTextColor( nColor, nAlpha ) CLASS TSwiftTextField
    local cHex := ::InitialColorToHex( nColor, nAlpha )
    ::hState["textcolor"] := cHex
    SD_TF_SET_TEXT_COLOR( ::cId, cHex )
return self

//----------------------------------------------------------------------------//

METHOD SetAccentColor( nColor, nAlpha ) CLASS TSwiftTextField
    local cHex := ::InitialColorToHex( nColor, nAlpha )
    ::hState["bgcolor"] := cHex
    SD_TF_SET_ACCENT_COLOR( ::cId, cHex )
return self

//----------------------------------------------------------------------------//

METHOD OnChange( cNewText ) CLASS TSwiftTextField
   ::hState["text"] := cNewText
   if ::bAction != nil
      Eval( ::bAction, cNewText, Self )
   endif
return nil

//----------------------------------------------------------------------------//

METHOD End() CLASS TSwiftTextField
   if !Empty( ::hWnd )
      SD_TF_DESTROY( ::cId, ::hWnd )
   endif
return ::Super:End()

//----------------------------------------------------------------------------//

CLASS TSwiftTextEditor FROM TSwiftTextField

    METHOD New( nTop, nLeft, nWidth, nHeight, cText, oWnd, cId, bAction )
    METHOD End()

ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, cText, oWnd, cId, bAction ) CLASS TSwiftTextEditor

    DEFAULT nWidth := 300, nHeight := 150, oWnd := GetWndDefault(), cText := ""

    ::Super:New( nTop, nLeft, nWidth, nHeight, cId )

    ::oWnd       = oWnd
    ::bAction    = bAction
    ::hState["text"] := cText
    ::hState["fontsize"] := 13
    
    ::Register( SD_SWIFT_TEXTEDITOR_CREATE( nTop, nLeft, nWidth, nHeight, hb_JsonEncode( ::hState ), oWnd:hWnd, ::cId ) )

    oWnd:AddControl( Self )

return Self

METHOD End() CLASS TSwiftTextEditor
   if !Empty( ::hWnd )
      SD_TF_DESTROY( ::cId, ::hWnd )
   endif
return ::Super:End()
