#include "FiveMac.ch"

function nRGB( nRed, nGreen, nBlue )
return nRed + ( nGreen * 256 ) + ( nBlue * 65536 )

Function nRgba(r,g,b,a)
Return ((a * 256^3) + (r * 256^2) + (g * 256^1) + (b * 256^0))

Function GetAlphaFromRgba( nDecimal )  
RETURN Int( nDecimal / 16777216 )

FUNCTION GetRedFromRgba( nDecimal )    // Byte 2
RETURN Int( (nDecimal % 16777216) / 65536 )

FUNCTION GetGreenFromRgba( nDecimal )  // Byte 1  
RETURN Int( (nDecimal % 65536) / 256 )

FUNCTION GetBlueFromRgba( nDecimal )   // Byte 0 (LSB)
RETURN Int( nDecimal % 256 )

FUNCTION GetRgbaAll( nDecimal )
    RETURN { ;
        GetRedFromRgba(nDecimal),   ;
        GetGreenFromRgba(nDecimal), ;
        GetBlueFromRgba(nDecimal),  ;
        GetAlphaFromRgba(nDecimal) ;
        }   

Function nRGBAFromRGB( nRgb, nAlpha )  
    DEFAULT nAlpha := 255 
return nRgb + ( nAlpha * 16777216 )

// max nColor Blanco 16777215
// numeros superiores tienen Alpha 
