#include "SwFive.ch"

//----------------------------------------------------------------------------//

CLASS SwProgress FROM TSwiftControl

   METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, nValue, nMin, nMax, cPrompt, cSubtitle, cIcon, cColor, lIndeterminate, nStyle, lShowValue )
   
   ACCESS nValue          INLINE ::hState["value"]
   ASSIGN nValue( n )     INLINE ( ::hState["value"] := n, ::Apply( "value", n ) )
   
   ACCESS nMin            INLINE ::hState["min"]
   ASSIGN nMin( n )       INLINE ( ::hState["min"] := n, ::Apply( "min", n ) )
   
   ACCESS nMax            INLINE ::hState["max"]
   ASSIGN nMax( n )       INLINE ( ::hState["max"] := n, ::Apply( "max", n ) )
   
   ACCESS cPrompt         INLINE ::hState["prompt"]
   ASSIGN cPrompt( c )    INLINE ( ::hState["prompt"] := c, ::Apply( "prompt", c ) )
   
   ACCESS cSubtitle       INLINE ::hState["subtitle"]
   ASSIGN cSubtitle( c )  INLINE ( ::hState["subtitle"] := c, ::Apply( "subtitle", c ) )
   
   ACCESS cIcon           INLINE ::hState["icon"]
   ASSIGN cIcon( c )      INLINE ( ::hState["icon"] := c, ::Apply( "icon", c ) )
   
   ACCESS cColor          INLINE ::hState["tintcolor"]
   ASSIGN cColor( c )     INLINE ( ::hState["tintcolor"] := c, ::Apply( "color", c ) )
   
   ACCESS lIndeterminate  INLINE ::hState["indeterminate"]
   ASSIGN lIndeterminate( l ) INLINE ( ::hState["indeterminate"] := l, ::Apply( "indeterminate", l ) )
   
   ACCESS nStyle          INLINE ::hState["style"]
   ASSIGN nStyle( n )     INLINE ( ::hState["style"] := n, ::Apply( "style", n ) )
   
   ACCESS lShowValue      INLINE ::hState["showvalue"]
   ASSIGN lShowValue( l ) INLINE ( ::hState["showvalue"] := l, ::Apply( "showvalue", l ) )

   METHOD SetRange( nMin, nMax )

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, nValue, nMin, nMax, cPrompt, cSubtitle, cIcon, cColor, lIndeterminate, nStyle, lShowValue ) CLASS SwProgress

   DEFAULT nWidth := 200, nHeight := 40
   DEFAULT nValue := 0, nMin := 0, nMax := 100
   DEFAULT cPrompt := "", cSubtitle := "", cIcon := "", cColor := ""
   DEFAULT lIndeterminate := .F., nStyle := 0, lShowValue := .T.

   ::Super:New( nTop, nLeft, nWidth, nHeight )
   
   ::oWnd             := oWnd
   ::hState["type"]   := 13 // Progress
   ::hState["value"]  := nValue
   ::hState["min"]    := nMin
   ::hState["max"]    := nMax
   ::hState["prompt"] := cPrompt
   ::hState["subtitle"] := cSubtitle
   ::hState["icon"]   := cIcon
   ::hState["tintcolor"] := cColor
   ::hState["indeterminate"] := lIndeterminate
   ::hState["style"]  := nStyle
   ::hState["showvalue"] := lShowValue

   if hb_IsObject( oWnd )
      ::hState["parentid"] := oWnd:cId
   endif

   ::Create()

return Self

//----------------------------------------------------------------------------//

METHOD SetRange( nMin, nMax ) CLASS SwProgress
   ::hState["min"] := nMin
   ::hState["max"] := nMax
   ::Apply( { "min" => nMin, "max" => nMax } )
return nil

//----------------------------------------------------------------------------//
