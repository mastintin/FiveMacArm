#include "FiveMac.ch"

function nRGB( nRed, nGreen, nBlue )
return nRed + ( nGreen * 256 ) + ( nBlue * 65536 )

Function nRgba(r,g,b,a)
Return ((a * 256^3) + (b * 256^2) + (g * 256^1) + (r * 256^0))

// Estándar RGBA: Rojo arriba, Alpha al final (Standard web/modern)
Function nRgbaWeb(r,g,b,a)
Return ((r * 256^3) + (g * 256^2) + (b * 256^1) + (a * 256^0))

Function GetAlphaFromRgba( nDecimal )  
RETURN Int( nDecimal / 16777216 )

FUNCTION GetBlueFromRgba( nDecimal )    // Byte 2
RETURN Int( (nDecimal % 16777216) / 65536 )

FUNCTION GetGreenFromRgba( nDecimal )  // Byte 1  
RETURN Int( (nDecimal % 65536) / 256 )

FUNCTION GetRedFromRgba( nDecimal )   // Byte 0 (LSB)
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

// Conversión a Hexadecimal estándar RGBA para Swift (RRGGBBAA)
FUNCTION clrToHex( nVal, nAlpha )
    LOCAL r, g, b, a
    
    hb_default( @nVal, 0 )
    
    // Extraer componentes (Asumiendo formato estándar de Harbour/Windows BGR)
    r := hb_bitAnd( nVal, 255 )
    g := hb_bitAnd( hb_bitShift( nVal, -8 ), 255 )
    b := hb_bitAnd( hb_bitShift( nVal, -16 ), 255 )
    
    // Lógica de Alpha mejorada
    IF nAlpha != NIL
        a := iif( nAlpha <= 1.0 .and. nAlpha > 0, Int( nAlpha * 255 ), nAlpha )
    ELSE
        // Si el número es > 16M, extraemos el 4º byte, si no, opaco (255)
        a := iif( nVal > 16777215, hb_bitAnd( hb_bitShift( nVal, -24 ), 255 ), 255 )
    ENDIF
    
    // Retornamos RRGGBBAA para que Swift lo lea fácil
    RETURN PadL( hb_NumToHex( r ), 2, "0" ) + ;
        PadL( hb_NumToHex( g ), 2, "0" ) + ;
        PadL( hb_NumToHex( b ), 2, "0" ) + ;
        PadL( hb_NumToHex( a ), 2, "0" )


FUNCTION cMacColor( nVal )
    // Dividimos entre 255 para obtener el decimal que espera Apple (0.0 a 1.0)
RETURN hb_ValToStr( nVal / 255 ) 
