#include "FiveMac.ch"

//----------------------------------------------------------------------------//

function cTimeMINSEC( nSeconds )
    local nMin, nSec
    hb_default( @nSeconds, 0 )
    nMin := Int( nSeconds / 60 )
    nSec := Int( nSeconds % 60 )
return AllTrim( Str( nMin ) ) + ":" + PadL( AllTrim( Str( nSec ) ), 2, "0" )

//----------------------------------------------------------------------------//

FUNCTION MsgInfo( uMsg, cTitle )
    hb_default( @cTitle, "Atención" )
   
    // Harbour realiza la conversion de tipos de forma segura
    MsgInfoNative( cValToChar( uMsg ), cTitle )
   
RETURN nil

//----------------------------------------------------------------------------//

FUNCTION cValToChar( uVal )

    LOCAL cType := ValType( uVal )

    DO CASE
        CASE cType == "C" .OR. cType == "M"
            RETURN uVal

        CASE cType == "N"
            RETURN hb_ntos( uVal ) // O AllTrim( Str( uVal ) )

        CASE cType == "D"
            RETURN DToC( uVal )

        CASE cType == "L"
            RETURN If( uVal, ".T.", ".F." )

        CASE cType == "A"
            RETURN "{...}" // Indica que es un Array

        CASE cType == "O"
            RETURN "[Object]"

        CASE cType == "NIL"
            RETURN ""

    ENDCASE

RETURN ""
