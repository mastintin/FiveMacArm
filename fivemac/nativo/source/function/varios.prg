#include "FiveMac.ch"


function cTimeMINSEC( nSeconds )
    local nMin, nSec
    hb_default( @nSeconds, 0 )
    nMin := Int( nSeconds / 60 )
    nSec := Int( nSeconds % 60 )
return AllTrim( Str( nMin ) ) + ":" + PadL( AllTrim( Str( nSec ) ), 2, "0" )
