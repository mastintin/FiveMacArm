#include "swfive.ch"

#define SW_TYPE_PANEL 20

CLASS TSwPanel FROM TSwiftControl

   METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, cId, nAutoResize, cTitle, cSymbol )
   
   METHOD SetBorderColor( cColor ) INLINE ::Apply( "bordercolor", cColor )
   METHOD SetBorderWidth( nWidth ) INLINE ::Apply( "borderwidth", nWidth )
   METHOD SetShadow( nRadius )     INLINE ::Apply( "shadow", nRadius )
   METHOD SetPadding( nPadding )   INLINE ::Apply( "padding", nPadding )
   METHOD SetBadge( xValue )       INLINE ::Apply( "badge", xValue )

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, cId, nAutoResize, cTitle, cSymbol ) CLASS TSwPanel

   ::Super:New( nTop, nLeft, nWidth, nHeight, cId, nAutoResize )
   ::oWnd := oWnd
   
   if hb_IsObject( oWnd )
      ::hState["parentid"] := oWnd:cId
   endif
   
   ::hState["type"]    := SW_TYPE_PANEL
   ::hState["title"]   := hb_defaultValue( cTitle, "" )
   ::hState["caption"] := hb_defaultValue( cSymbol, "" )
   
   ::Create()

return Self
