#include "swfive.ch"

//----------------------------------------------------------------------------//

CLASS TSwColorPicker FROM TSwiftControl

   ACCESS Value      INLINE hb_HGetDef( ::hState, "value", "#0000FF" )
   ASSIGN Value( c ) INLINE ( ::hState["value"] := c, ::Apply( "value", c ) )

   ACCESS Prompt        INLINE hb_HGetDef( ::hState, "prompt", "" )
   ASSIGN Prompt( c )   INLINE ( ::hState["prompt"] := c, ::Apply( "prompt", c ) )

   DATA bAction

   METHOD New( nTop, nLeft, nWidth, nHeight, cValue, cPrompt, oWnd, bAction )
   METHOD Update( hNewState )
   METHOD OnAction( cNewValue )
   
ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, nWidth, nHeight, cValue, cPrompt, oWnd, bAction ) CLASS TSwColorPicker

   DEFAULT nWidth := 200, nHeight := 35
   DEFAULT cValue := "#0000FF", cPrompt := "Select Color"

   ::Super:New( nTop, nLeft, nWidth, nHeight )
   
   ::oWnd   := oWnd
   ::bAction := bAction

   ::hState["value"] := cValue
   ::hState["prompt"] := cPrompt
   ::hState["type"]  := 31  // ColorPicker
   
   if hb_IsObject( oWnd )
      ::hState["parentid"] := oWnd:cId
   endif

   ::Create()

return Self

//----------------------------------------------------------------------------//

METHOD Update( hNewState ) CLASS TSwColorPicker
   local cOldVal := ::Value
   
   ::Super:Update( hNewState )
   
   if ::Value != cOldVal
      ::OnAction( ::Value )
   endif
return nil

//----------------------------------------------------------------------------//

METHOD OnAction( cNewValue ) CLASS TSwColorPicker
   ::hState["value"] := cNewValue
   if !Empty( ::bAction )
      Eval( ::bAction, cNewValue, Self )
   endif
return nil
