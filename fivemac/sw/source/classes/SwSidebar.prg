#include "swfive.ch"

#define SW_TYPE_SIDEBAR 21

CLASS TSwSidebar FROM TSwiftControl

   DATA bAction

   METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, cId, nAutoResize )
   
   METHOD SetSelection( cId ) INLINE ::Apply( "selection", cId )
   METHOD SetWidth( nWidth )   INLINE ::Apply( "width", nWidth )

   METHOD AddItem( cPrompt, cSymbol, cId, bAction )
   METHOD AddSection( cTitle )

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

//----------------------------------------------------------------------------//

METHOD AddItem( cPrompt, cSymbol, cId, bAction ) CLASS TSwSidebar
   local oItem
   
   oItem := TSwSidebarItem():New( 0, 0, Self, cPrompt, cSymbol, cId, bAction )
   
   if !Empty( ::bAction ) .and. Empty( bAction )
       oItem:bAction := { | o | Eval( ::bAction, o:cId, o ) }
   endif
   
return oItem

//----------------------------------------------------------------------------//

METHOD AddSection( cTitle ) CLASS TSwSidebar
   local oItem := TSwSidebarItem():New( 0, 0, Self, cTitle, "", , nil )
   oItem:hState["issection"] := .t.
   oItem:Apply( "issection", .t. )
return oItem
