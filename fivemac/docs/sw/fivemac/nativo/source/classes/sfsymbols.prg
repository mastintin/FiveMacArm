#include "FiveMac.ch"

#define NSFontWeightThin        -0.6
#define NSFontWeightLight       -0.4
#define NSFontWeightRegular      0.0
#define NSFontWeightMedium       0.23
#define NSFontWeightSemibold     0.3
#define NSFontWeightBold         0.4
#define NSFontWeightHeavy        0.56
#define NSFontWeightBlack        0.62

#define NSImageSymbolScaleSmall  1
#define NSImageSymbolScaleMedium 2
#define NSImageSymbolScaleLarge  3

//----------------------------------------------------------------------------//

CLASS TSFSymbol

    DATA cName
    DATA nValue
    DATA nPointSize
    DATA nWeight
    DATA nScale
    DATA nColor
    DATA lMulticolor INIT .f.
    DATA aPalette
    DATA hConfig

    METHOD New( cName, nValue )
   
    METHOD SetWeight( nWeight )
    METHOD SetScale( nScale )
    METHOD SetPointSize( nPointSize )
    METHOD SetColor( nColor )
    METHOD SetMulticolor( lOnOff )
    METHOD SetPalette( nCol1, nCol2, nCol3 )
   
    METHOD Handle() // Returns NSImage handle

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( cName, nValue ) CLASS TSFSymbol

    ::cName      := cName
    ::nValue     := nValue
    ::nPointSize := 0
    ::nWeight    := NSFontWeightRegular
    ::nScale     := NSImageSymbolScaleMedium
    ::nColor     := nil
    ::lMulticolor := .f.

return Self

//----------------------------------------------------------------------------//

METHOD SetWeight( nWeight ) CLASS TSFSymbol
    ::nWeight := nWeight
return Self

//----------------------------------------------------------------------------//

METHOD SetScale( nScale ) CLASS TSFSymbol
    ::nScale := nScale
return Self

//----------------------------------------------------------------------------//

METHOD SetPointSize( nPointSize ) CLASS TSFSymbol
    ::nPointSize := nPointSize
return Self

//----------------------------------------------------------------------------//

METHOD SetColor( nColor ) CLASS TSFSymbol
    ::nColor := nColor
return Self

//----------------------------------------------------------------------------//

METHOD SetMulticolor( lOnOff ) CLASS TSFSymbol
    ::lMulticolor := lOnOff
return Self

//----------------------------------------------------------------------------//

METHOD SetPalette( nCol1, nCol2, nCol3 ) CLASS TSFSymbol
    ::aPalette := { nCol1, nCol2, nCol3 }
return Self

//----------------------------------------------------------------------------//

METHOD Handle() CLASS TSFSymbol

    local hConfig := IMGSYMBOLCONFIG( ::nPointSize, ::nWeight, ::nScale )
    local hImage
   
    if ::lMulticolor
    hConfig := IMGSYMBOLMULTICOLOR( hConfig )
    endif

    if ::aPalette != nil
    hConfig := IMGSYMBOLPALETTE( hConfig, ::aPalette[1], ::aPalette[2], ::aPalette[3] )
    elseif ::nColor != nil
    hConfig := IMGSYMBOLHIERARCHICAL( hConfig, ::nColor )
    endif
   
    hImage := IMGSYMBOLWITHVARIABLE( ::cName, ::nValue, hConfig )

return hImage

//----------------------------------------------------------------------------//
