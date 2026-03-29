#include "FiveMac.ch"

//----------------------------------------------------------------------------//

CLASS TSplash FROM TControl
   
   DATA hWnd
   DATA bOnClose

   METHOD New( nTop, nLeft, nWidth, nHeight, cFileName )
   
   METHOD SetFile( cFileName ) INLINE SplashSetFile( ::hWnd, cFileName )

   METHOD Run() 
   METHOD Center() INLINE WndCenter( ::hWnd )   
   METHOD Close() INLINE SplashClose(::hWnd)
   METHOD SetImage( cPathImagen ) INLINE SplashSetImage( ::hWnd, cPathImagen )

ENDCLASS   

//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, nWidth, nHeight, cFileName ) CLASS TSplash

   DEFAULT nWidth := 100, nHeight := 100 
   
   ::hWnd = SplashCreate( nTop, nLeft, nWidth, nHeight )
   
   if ! Empty( cFileName ) .and. File( cFileName )
      ::SetFile( cFileName )
   endif   

return Self   

//----------------------------------------------------------------------------//

METHOD run() CLASS TSplash
   LOCAL bBlock := if( ::bOnClose == nil, {|| nil}, ::bOnClose )
   // Pasamos: hWnd, segundos, el bloque y el objeto
   SPLASHRUN( ::hWnd, 5, bBlock, Self )
return nil
