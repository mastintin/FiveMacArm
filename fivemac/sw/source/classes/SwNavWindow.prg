#include "SwFive.ch"

//----------------------------------------------------------------------------//
// Clase especializada para ventanas con navegación nativa (SplitView)
//----------------------------------------------------------------------------//

CLASS TSwNavWindow FROM TSwWindow

   ACCESS selectedId          INLINE hb_HGetDef( ::hState, "selectedid", "" )
   ASSIGN selectedId( cTag )  INLINE ( ::hState["selectedid"] := cTag, ::Apply( "selectedid", cTag ) )

   METHOD AddItem( cId, cLabel, cIcon, cSection ) INLINE ;
      ::Apply( "additem", { "id" => cId, "label" => cLabel, "icon" => cIcon, "section" => cSection } )

   METHOD New( cTitle, nWidth, nHeight, cId, oParent ) CONSTRUCTOR
   
ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( cTitle, nWidth, nHeight, cId, oParent ) CLASS TSwNavWindow

   ::cId      := If( Empty( cId ), Lower( hb_uuid() ), cId )
   ::hState   := { "type" => 101, "id" => ::cId, "title" => cTitle, "width" => nWidth, "height" => nHeight }
   
   If ! Empty( oParent )
      ::oParent := oParent
      ::hState["parentid"] := oParent:cId
   Endif

   SDS:Create( ::hState )

return Self
