#include "swfive.ch"

#define SW_TYPE_SIDEBAR 21

CLASS TSwSidebar FROM TSwiftControl

   METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, cId, nAutoResize )
   
   METHOD SetSelection( cId ) INLINE ::Apply( "selection", cId )
   METHOD SetWidth( nWidth )   INLINE ::Apply( "width", nWidth )

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, cId, nAutoResize ) CLASS TSwSidebar

   ::Super:New( nTop, nLeft, nWidth, nHeight, cId, nAutoResize )
   ::oWnd := oWnd
   
   if hb_IsObject( oWnd )
      ::hState["parentid"] := oWnd:cId
   endif
   
   ::hState["type"]  := SW_TYPE_SIDEBAR
   
   ::Create()

return Self
