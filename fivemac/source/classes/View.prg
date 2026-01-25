#include "FiveMac.ch"

//----------------------------------------------------------------------------//

CLASS TView FROM TControl

   DATA   hWnd
   DATA   oWnd
   DATA   cTitle 

   METHOD New( oWnd )
   METHOD Hide() INLINE ViewHide( ::hWnd )
   METHOD Show() INLINE ViewShow( ::hWnd )   
   METHOD SetGradientColor(nR1, nG1,nB1,nAlpha1, nR2, nG2,nB2,nAlpha2)
   METHOD SetCornerRadius( nRadius )
ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, cTitle ) CLASS TView

   DEFAULT oWnd := GetWndDefault(), cTitle := ""
   DEFAULT nTop := 0, nLeft:= 0, nWidth:= oWnd:nWidth(), nHeight:= oWnd:nHeight()
      
   ::cTitle = cTitle
   ::hWnd   = WndSetSubview( nTop, nLeft, nWidth, nHeight, oWnd:hWnd )
   ::oWnd   = oWnd
 
   oWnd:AddControl( Self )
   
   AAdd( GetAllWin(), Self ) // it receives msgs from its child controls 
 
return Self

//----------------------------------------------------------------------------//

METHOD SetGradientColor(nR1, nG1,nB1,nAlpha1, nR2, nG2,nB2,nAlpha2) CLASS TView
   DEFAULT nR1 := 0, nG1 := 50,nB1 := 150,nAlpha1 := 0.9
   DEFAULT nR2 := 0, nG2 := 0,nB2 := 255,nAlpha2 := 0.6 
   ViewSetGradientColor( ::hWnd, nR1, nG1,nB1,nAlpha1, nR2, nG2,nB2,nAlpha2 )
return Self

//----------------------------------------------------------------------------//

METHOD SetCornerRadius( nRadius ) CLASS TView
   ViewSetCornerRadius( ::hWnd, nRadius )
return nil