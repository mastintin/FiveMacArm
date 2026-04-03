#include "FiveMac.ch"
#include "SwiftControls.ch"

CLASS TSwiftTextField FROM TSwiftControl

    ACCESS Value      INLINE ::hState["Value"]
    ASSIGN Value( c ) INLINE ::SetText( c )

    ACCESS Placeholder       INLINE ::hState["Placeholder"]
    ASSIGN Placeholder( c )  INLINE ::hState["Placeholder"] := c

    ACCESS Caption      INLINE ::hState["Caption"]
    ASSIGN Caption( c ) INLINE ::hState["Caption"] := c
    
    METHOD New( nTop, nLeft, nWidth, nHeight, cText, cPlaceholder, oWnd, bAction, nAutoResize, cId, cCaption )
    METHOD SetText( cText )
    METHOD GetText()     INLINE ::hState["Value"]
    METHOD SetFontSize( nSize )
    
    METHOD OnChange( cNewText )
    METHOD End()

ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, cText, cPlaceholder, oWnd, bAction, nAutoResize, cId, cCaption ) CLASS TSwiftTextField

    DEFAULT nWidth := 200, nHeight := 48, oWnd := GetWndDefault() // Mas alto por el VStack interno
    DEFAULT cText := "", cPlaceholder := "Enter text...", nAutoResize := 0, cCaption := ""

    ::Super:New( nTop, nLeft, nWidth, nHeight, cId )

    ::oWnd       = oWnd
    ::bAction    = bAction
    
    ::hState["Value"]       := cText
    ::hState["Placeholder"] := cPlaceholder
    ::hState["Caption"]     := cCaption

    ::Register( SD_SWIFT_TEXTFIELD_CREATE( nTop, nLeft, nWidth, nHeight, cText, cCaption, cPlaceholder, oWnd:hWnd, ::cId ) )

    if nAutoResize != 0
        SWIFTAUTORESIZE( ::hWnd, nAutoResize )
    endif

    oWnd:AddControl( Self )

return Self

METHOD SetText( cText ) CLASS TSwiftTextField
   ::hState["Value"] := cText
   SD_TF_SET_TEXT( ::cId, cText )
return nil

METHOD SetFontSize( nSize ) CLASS TSwiftTextField
   SD_TF_SET_FONT_SIZE( ::cId, nSize )
return nil

METHOD OnChange( cNewText ) CLASS TSwiftTextField
   ::hState["Value"] := cNewText
   if ::bAction != nil
      Eval( ::bAction, cNewText, Self )
   endif
return nil

METHOD End() CLASS TSwiftTextField
   if !Empty( ::hWnd )
      SD_TF_DESTROY( ::cId, ::hWnd )
   endif
return ::Super:End()

//----------------------------------------------------------------------------//

CLASS TSwiftTextEditor FROM TSwiftTextField

    METHOD New( nTop, nLeft, nWidth, nHeight, cText, oWnd, cId )
    METHOD End()

ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, cText, oWnd, cId ) CLASS TSwiftTextEditor

    DEFAULT nWidth := 300, nHeight := 150, oWnd := GetWndDefault(), cText := ""

    ::Super:New( nTop, nLeft, nWidth, nHeight, cId )

    ::oWnd       = oWnd
    ::Value      = cText
    
    ::Register( SD_SWIFT_TEXTEDITOR_CREATE( ::nTop, ::nLeft, ::nWidth, ::nHeight, cText, oWnd:hWnd, ::cId ) )

    oWnd:AddControl( Self )

return Self

METHOD End() CLASS TSwiftTextEditor
   if !Empty( ::hWnd )
      SD_TF_DESTROY( ::cId, ::hWnd )
   endif
return ::Super:End()
