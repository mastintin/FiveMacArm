#include "swfive.ch"

#define SW_TYPE_CARD 25

CLASS TSwCard FROM TSwVStack

   ACCESS cTitle           INLINE hb_HGetDef( ::hState, "title", "" )
   ASSIGN cTitle( c )      INLINE ( ::hState["title"] := c, ::Apply( "title", c ) )

   ACCESS cIcon            INLINE hb_HGetDef( ::hState, "icon", "" )
   ASSIGN cIcon( c )       INLINE ( ::hState["icon"] := c, ::Apply( "icon", c ) )

   ACCESS nShadow          INLINE hb_HGetDef( ::hState, "shadow", 5 )
   ASSIGN nShadow( n )     INLINE ( ::hState["shadow"] := n, ::Apply( "shadow", n ) )

   ACCESS nCorner          INLINE hb_HGetDef( ::hState, "corner", 12 )
   ASSIGN nCorner( n )     INLINE ( ::hState["corner"] := n, ::Apply( "corner", n ) )

   METHOD New( nTop, nLeft, nWidth, nHeight, oParent, cId, nAutoResize, cTitle, cIcon )

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, nWidth, nHeight, oParent, cId, nAutoResize, cTitle, cIcon ) CLASS TSwCard

   ::Super:New( nTop, nLeft, nWidth, nHeight, oParent, cId, nAutoResize )

   ::hState["type"]   := SW_TYPE_CARD
   ::hState["title"]  := hb_DefaultValue( cTitle, "" )
   ::hState["icon"]   := hb_DefaultValue( cIcon, "" )
   ::hState["shadow"] := 5
   ::hState["corner"] := 12
   ::hState["padding"] := .T.

   ::Create()

return Self
