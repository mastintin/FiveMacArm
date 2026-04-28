#include "swfive.ch"

#define SW_TYPE_SIDEBARITEM 22

CLASS TSwSidebarItem FROM TSwiftControl

   ACCESS bAction          INLINE hb_HGetDef( ::hState, "action", nil )
   ASSIGN bAction( u )     INLINE ( ::hState["action"] := u,;
                                    ::hState["interactive"] := iif( !Empty( u ), 1, 0 ),;
                                    ::Apply( "interactive", ::hState["interactive"] ) )
    
   METHOD Select()    INLINE ::Apply( "selected", 1 )
   METHOD Unselect()  INLINE ::Apply( "selected", 0 )

   METHOD New( nTop, nLeft, oWnd, cPrompt, cSymbol, cId, bAction )
   
   METHOD OnAction()  INLINE iif( !Empty( ::bAction ), Eval( ::bAction, Self ), nil )

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, oWnd, cPrompt, cSymbol, cId, bAction ) CLASS TSwSidebarItem

   ::Super:New( nTop, nLeft, 180, 30, cId )
   ::oWnd := oWnd
   
   if hb_IsObject( oWnd )
      ::hState["parentid"] := oWnd:cId
   endif
   
   ::hState["type"]    := SW_TYPE_SIDEBARITEM
   ::hState["title"]   := cPrompt
   ::hState["caption"] := cSymbol
   
   ::bAction := bAction

   ::Create()

return Self
