#include "Fivemac.ch"

//----------------------------------------------------------------------------//

CLASS TColorWell FROM TControl

   DATA   nRGBColor
   DATA   bChange

   METHOD New( nTop, nLeft, nSize, nHeight, oWnd, bChange, nRGBColor )

   METHOD GetColor() INLINE ClrWGetColor( ::hWnd )
   
   METHOD SetColor( nRGBColor ) INLINE ( ::nRGBColor := nRGBColor,;
                                       ClrWSetColor( ::hWnd, nRGBColor ) )

   METHOD Change() INLINE ::nRGBColor := ::GetColor(),;
                          If( ! Empty( ::bChange ), Eval( ::bChange, Self ),)

   METHOD close() INLINE CLOSECOLORWELL( ::hWnd )

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, bChange, nRGBColor ) CLASS TColorWell

   DEFAULT nTop := 10, nLeft := 10, nWidth := 100, nHeight := 30,;
           oWnd := GetWndDefault() 

   ::hWnd = CreateColorWell( nTop, nLeft, nWidth, nHeight, oWnd:hWnd )
   ::oWnd = oWnd
   ::bChange = bChange
   ::SetRGBColor( nRGBColor )
   oWnd:AddControl( Self )
   
return Self

//----------------------------------------------------------------------------//
