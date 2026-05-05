#include "swfive.ch"

#define SW_TYPE_PANEL 20

CLASS TSwPanel FROM TSwiftControl

   ACCESS lGlass            INLINE hb_HGetDef( ::hState, "isglass", .F. )
   ASSIGN lGlass( l )       INLINE ( ::hState["isglass"] := l, ::Apply( "isglass", l ) )

   METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, cId, nAutoResize, cTitle, cSymbol )
   
   METHOD SetBorderColor( cColor ) INLINE ::Apply( "bordercolor", cColor )
   METHOD SetBorderWidth( nWidth ) INLINE ::Apply( "borderwidth", nWidth )
   METHOD SetShadow( nRadius )     INLINE ::Apply( "shadow", nRadius )
   METHOD SetPadding( nPadding )   INLINE ::Apply( "padding", nPadding )
   METHOD SetBadge( xValue )       INLINE ::Apply( "badge", xValue )

   ACCESS nPadding          INLINE hb_HGetDef( ::hState, "padding", 8 )
   ASSIGN nPadding( n )     INLINE ( ::hState["padding"] := n, ::Apply( "padding", n ) )
   
   ACCESS nSpacing          INLINE hb_HGetDef( ::hState, "spacing", 0 )
   ASSIGN nSpacing( n )     INLINE ( ::hState["spacing"] := n, ::Apply( "spacing", n ) )

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
