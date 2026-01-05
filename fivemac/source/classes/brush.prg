#include "FiveMac.ch"

#define GRADIENT_VERTICAL   270
#define GRADIENT_HORIZONTAL   0

#define nRgbRed( n )    ( n % 256 )
#define nRgbGreen( n )  ( Int( n / 256 ) % 256 )
#define nRgbBlue( n )   ( Int( n / 65536 ) % 256 )

CLASS TBrush

   DATA   hBrush // Handle to NSColor
   DATA   cImage
   DATA   aGradient // { nColor1, nColor2, nAngle }
   DATA   nColor

   METHOD New( cImage, nColor, aGradient )
   METHOD End() INLINE ( If( ! Empty( ::hBrush ), BrushRelease( ::hBrush ),), ::hBrush := nil )
   DESTRUCTOR  Destroy()

ENDCLASS

METHOD New( cImage, nColor, aGradient ) CLASS TBrush

   if cImage != nil
      if valtype( cImage ) == "N"
         nColor = cImage
         cImage = nil
      endif
   endif

   if cImage != nil
      if File( cImage )
         ::cImage = cImage
         ::hBrush = BrushCreatePattern( cImage )
      endif
   elseif nColor != nil
      ::nColor = nColor
      if valtype( nColor ) = "A"
         if len( nColor ) = 4
            ::hBrush = BrushCreateSolid( nColor[ 1 ], nColor[ 2 ], nColor[ 3 ], nColor[ 4 ] )
         elseif len( nColor ) = 3
            ::hBrush = BrushCreateSolid( nColor[ 1 ], nColor[ 2 ], nColor[ 3 ], 255 )
         endif
      else
         ::hBrush = BrushCreateSolid( nRgbRed( nColor ), nRgbGreen( nColor ), nRgbBlue( nColor ), 255 )
      endif
   elseif aGradient != nil
      ::aGradient = aGradient

      // Default size for gradient pattern? Maybe 2000x2000 to cover most? Or small?
      // Small implies tiling. Large implies memory.
      // Let's use a "reasonable" generic size or require window size.
      // Since TBrush doesn't know window, we might create a generic one.

      if len( aGradient ) = 7
         DEFAULT ::aGradient[ 7 ] := GRADIENT_VERTICAL
         ::hBrush = BrushCreateGradient( aGradient[ 1 ], aGradient[ 2 ], aGradient[ 3 ],;
                                        aGradient[ 4 ], aGradient[ 5 ], aGradient[ 6 ],;
                                        aGradient[ 7 ], 500, 500 ) 
      elseif len( aGradient ) = 3
         DEFAULT ::aGradient[ 3 ] := GRADIENT_VERTICAL
         ::hBrush = BrushCreateGradient( nRgbRed( aGradient[ 1 ] ), nRgbGreen( aGradient[ 1 ] ), nRgbBlue( aGradient[ 1 ] ),;
                                      nRgbRed( aGradient[ 2 ] ), nRgbGreen( aGradient[ 2 ] ), nRgbBlue( aGradient[ 2 ] ),;
                                      aGradient[ 3 ], 500, 500 ) 

      endif
     
   endif

return Self

//----------------------------------------------------------------------------//

METHOD Destroy() CLASS TBrush

   ::End()

return nil
