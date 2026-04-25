#include "SwFive.ch"

//----------------------------------------------------------------------------//

CLASS SwProgress FROM TSwiftControl

   METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, nValue )
   
   METHOD SetValue( nValue ) SETGET
   METHOD SetRange( nMin, nMax )

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, nValue ) CLASS SwProgress

   DEFAULT nWidth := 200, nHeight := 20, nValue := 0

   ::Super:New( nTop, nLeft, nWidth, nHeight )
   
   ::oWnd    = oWnd
   ::hState["type"] := 13 // Progress
   ::hState["value"] := nValue
   ::hState["min"] := 0
   ::hState["max"] := 100

   if hb_IsObject( oWnd )
      ::hState["parentid"] := oWnd:cId
   endif

   ::Create()

return Self

//----------------------------------------------------------------------------//

METHOD SetValue( nValue ) CLASS SwProgress
   ::hState["value"] := nValue
   SD:Apply( ::cId, { "value" => nValue } )
return nil

//----------------------------------------------------------------------------//

METHOD SetRange( nMin, nMax ) CLASS SwProgress
   ::hState["min"] := nMin
   ::hState["max"] := nMax
   SD:Apply( ::cId, { "min" => nMin, "max" => nMax } )
return nil

//----------------------------------------------------------------------------//
