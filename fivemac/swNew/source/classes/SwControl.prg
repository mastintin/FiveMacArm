#include "FiveMac.ch"

//----------------------------------------------------------------------------//

CLASS TSwControl

   DATA nTop, nLeft, nWidth, nHeight
   DATA cId
   DATA oWnd
   DATA hWnd

   METHOD New( nTop, nLeft, nWidth, nHeight, cId )
   METHOD End()
   METHOD HasMethod( cMethod )

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, nWidth, nHeight, cId ) CLASS TSwControl

   ::nTop    := nTop
   ::nLeft   := nLeft
   ::nWidth  := nWidth
   ::nHeight := nHeight
   ::cId     := cId

   SwRegisterItem( ::cId, Self )

return Self

//----------------------------------------------------------------------------//

METHOD End() CLASS TSwControl

   SwUnregisterItem( ::cId )

return nil

//----------------------------------------------------------------------------//

METHOD HasMethod( cMethod ) CLASS TSwControl
return ( __objHasMethod( Self, cMethod ) )

//----------------------------------------------------------------------------//
