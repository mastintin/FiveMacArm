#include "FiveMac.ch"
#include "SwiftControls.ch"

CLASS TSwiftLabel FROM TSwiftControl

    ACCESS Caption      INLINE ::hState["Caption"]
    ASSIGN Caption( c ) INLINE ::SetText( c )

    ACCESS Text         INLINE ::hState["Caption"]
    ASSIGN Text( c )    INLINE ::SetText( c )

    METHOD New( nTop, nLeft, nWidth, nHeight, cText, oWnd, cId )
    METHOD SetText( cText )
    METHOD SetFont( nSize )
    METHOD SetFont_Style( cStyle )
    METHOD SetAlignment( nAlign )
    METHOD OnAction()
    METHOD End()
      
ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, cText, oWnd, cId ) CLASS TSwiftLabel

   DEFAULT nWidth := 100, nHeight := 40, oWnd := GetWndDefault(), cText := "Label"

   ::Super:New( nTop, nLeft, nWidth, nHeight, cId )

   ::oWnd    := oWnd
   ::hState["Caption"] := cText

   ::Register( SD_SWIFT_LABEL_CREATE( nTop, nLeft, nWidth, nHeight, cText, oWnd:hWnd, ::cId ) )

   oWnd:AddControl( Self )

return Self

METHOD SetText( cText ) CLASS TSwiftLabel
   ::hState["Caption"] := cText
   SD_LBL_SET_TEXT( ::cId, cText )
return nil

METHOD SetFont( nSize ) CLASS TSwiftLabel
   SD_LBL_SET_FONT( ::cId, nSize )
return nil

METHOD SetFont_Style( cStyle ) CLASS TSwiftLabel
   SD_LBL_SET_FONT_STYLE( ::cId, cStyle )
return nil

METHOD SetAlignment( nAlign ) CLASS TSwiftLabel
   SD_LBL_SET_ALIGN( ::cId, nAlign )
return nil

METHOD OnAction() CLASS TSwiftLabel
   if ! Empty( ::bAction )
      Eval( ::bAction, Self )
   endif
return nil

METHOD End() CLASS TSwiftLabel
    if !Empty( ::hWnd )
        SD_LBL_DESTROY( ::cId, ::hWnd )
    endif
return ::Super:End()
