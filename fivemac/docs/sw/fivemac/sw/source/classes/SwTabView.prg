#include "swfive.ch"

#define SW_TYPE_TABVIEW 23

CLASS TSwTabView FROM TSwiftControl

   METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, cId, nAutoResize, nStyle )
   
   METHOD SetSelection( cId ) INLINE ::Apply( "selection", cId )

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, cId, nAutoResize, nStyle ) CLASS TSwTabView

   ::Super:New( nTop, nLeft, nWidth, nHeight, cId, nAutoResize )
   ::oWnd := oWnd
   
   if hb_IsObject( oWnd )
      ::hState["parentid"] := oWnd:cId
   endif
   
   ::hState["type"]  := SW_TYPE_TABVIEW
   ::hState["style"] := hb_defaultValue( nStyle, 0 )
   
   ::Create()

return Self
