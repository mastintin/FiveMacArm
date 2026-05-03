#include "swfive.ch"

//----------------------------------------------------------------------------//

CLASS TSwStepper FROM TSwiftControl

   ACCESS Value      INLINE hb_HGetDef( ::hState, "value", 0 )
   ASSIGN Value( n ) INLINE ( ::hState["value"] := n, ::Apply( "value", n ) )

   ACCESS Min        INLINE hb_HGetDef( ::hState, "min", 0 )
   ASSIGN Min( n )   INLINE ( ::hState["min"] := n, ::Apply( "min", n ) )

   ACCESS Max        INLINE hb_HGetDef( ::hState, "max", 100 )
   ASSIGN Max( n )   INLINE ( ::hState["max"] := n, ::Apply( "max", n ) )

   ACCESS Step       INLINE hb_HGetDef( ::hState, "step", 1 )
   ASSIGN Step( n )  INLINE ( ::hState["step"] := n, ::Apply( "step", n ) )

   ACCESS cText      INLINE hb_HGetDef( ::hState, "text", "" )
   ASSIGN cText( c ) INLINE ( ::hState["text"] := c, ::Apply( "text", c ) )

   DATA bAction

   METHOD New( nTop, nLeft, nWidth, nHeight, nValue, nMin, nMax, nStep, cText, oWnd, bAction )
   METHOD Update( hNewState )
   METHOD OnAction( nNewValue )
   
ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, nWidth, nHeight, nValue, nMin, nMax, nStep, cText, oWnd, bAction ) CLASS TSwStepper

   DEFAULT nWidth := 120, nHeight := 30
   DEFAULT nValue := 0, nMin := 0, nMax := 100, nStep := 1, cText := ""

   ::Super:New( nTop, nLeft, nWidth, nHeight )
   
   ::oWnd   := oWnd
   ::bAction := bAction

   ::hState["value"] := nValue
   ::hState["min"]   := nMin
   ::hState["max"]   := nMax
   ::hState["step"]  := nStep
   ::hState["text"]  := cText
   ::hState["type"]  := 30  // Stepper
   
   if hb_IsObject( oWnd )
      ::hState["parentid"] := oWnd:cId
   endif

   ::Create()

return Self

//----------------------------------------------------------------------------//

METHOD Update( hNewState ) CLASS TSwStepper
   local nOldVal := ::Value
   
   ::Super:Update( hNewState )
   
   if ::Value != nOldVal
      ::OnAction( ::Value )
   endif
return nil

//----------------------------------------------------------------------------//

METHOD OnAction( nNewValue ) CLASS TSwStepper
   ::hState["value"] := nNewValue
   if !Empty( ::bAction )
      Eval( ::bAction, nNewValue, Self )
   endif
return nil
