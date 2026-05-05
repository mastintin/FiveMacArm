#include "SwFive.ch"

//----------------------------------------------------------------------------//
// Clase especializada para ventanas con navegación nativa (SplitView)
//----------------------------------------------------------------------------//

CLASS TSwNavWindow FROM TSwWindow

   DATA bOnChange

   ACCESS selectedId          INLINE hb_HGetDef( ::hState, "selectedid", "" )
   ASSIGN selectedId( cTag )  INLINE ( ::hState["selectedid"] := cTag, ::Apply( "selectedid", cTag ) )

   ACCESS selectedContentId          INLINE hb_HGetDef( ::hState, "selectedcontentid", "" )
   ASSIGN selectedContentId( cTag )  INLINE ( ::hState["selectedcontentid"] := cTag, ::Apply( "selectedcontentid", cTag ) )

   METHOD AddItem( cId, cLabel, cIcon, cSection ) INLINE ;
      ::Apply( "additem", { "id" => cId, "label" => cLabel, "icon" => cIcon, "section" => cSection } )

   METHOD Push( cId ) INLINE ::Apply( "push", cId )
   METHOD Pop()      INLINE ::Apply( "pop", .t. )
   
   METHOD SetContent( cId ) INLINE ::selectedContentId := cId
   METHOD ClearContent()   INLINE ::selectedContentId := ""

   METHOD New( cTitle, nWidth, nHeight, cId, oParent ) CONSTRUCTOR

   METHOD Update( hProps )
   
ENDCLASS

//----------------------------------------------------------------------------//

METHOD Update( hProps ) CLASS TSwNavWindow
   local cEvent := hb_HGetDef( hProps, "event", "" )
   local uValue := hb_HGetDef( hProps, "value", "" )

   if cEvent == "change"
      if !Empty( ::bOnChange )
         Eval( ::bOnChange, uValue, Self )
      endif
   else
      ::Super:Update( hProps )
   endif
return nil

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
