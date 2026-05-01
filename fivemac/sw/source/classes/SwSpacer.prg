#include "swfive.ch"

#define SW_TYPE_SPACER 5

CLASS TSwSpacer FROM TSwiftControl

   METHOD New( oParent )

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( oParent ) CLASS TSwSpacer

   ::Super:New( 0, 0, 0, 0 )
   
   if hb_IsObject( oParent )
      ::oParent := oParent
      ::oWnd    := if( __ObjHasData( oParent, "oWnd" ), oParent:oWnd, oParent )
      ::hState["parentid"] := oParent:cId
   endif

   ::hState["type"] := SW_TYPE_SPACER
   
   ::Create()

return Self
