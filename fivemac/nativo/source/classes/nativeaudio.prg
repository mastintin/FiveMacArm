#include "FiveMac.ch"

static aPlayers := {}

CLASS TNativeAudio
    DATA hWnd
    DATA cFile
    DATA nDuration
    DATA cTitle, cArtist, cAlbum
    DATA bOnTime
   
    METHOD New( cFile )
    METHOD Play()       INLINE NativeAudioPlay( ::hWnd )
    METHOD Pause()      INLINE NativeAudioPause( ::hWnd )
    METHOD Stop()       INLINE NativeAudioStop( ::hWnd )
   
    METHOD GetDuration() 
    METHOD GetTime()    INLINE NativeAudioGetTime( ::hWnd )
    METHOD Seek( nSec ) INLINE NativeAudioSeek( ::hWnd, nSec )
    METHOD SetVol( nVol ) INLINE NativeAudioSetVol( ::hWnd, nVol )
   
    METHOD GetMetadata()
    METHOD GetArtwork() INLINE NativeAudioGetArtwork( ::hWnd )
   
    METHOD SetObserver( bAction ) INLINE ( ::bOnTime := bAction, Music_Set_Observer( ::hWnd ) )

    METHOD End()        

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( cFile ) CLASS TNativeAudio

    if ! Empty( cFile )
        ::cFile := cFile
        ::hWnd  := NativeAudioCreate( cFile )
        ::GetMetadata()
        ::nDuration := ::GetDuration()
        AAdd( aPlayers, Self )
    endif

return Self

//----------------------------------------------------------------------------//

METHOD End() CLASS TNativeAudio
    local nAt 
    ::Stop()
    nAt := AScan( aPlayers, { | o | o:hWnd == ::hWnd } )
    if nAt != 0
        ADel( aPlayers, nAt )
        ASize( aPlayers, Len( aPlayers ) - 1 )
    endif
    ::hWnd := nil 
return nil

//----------------------------------------------------------------------------//

METHOD GetDuration() CLASS TNativeAudio
    if ::nDuration == nil .or. ::nDuration == 0
        ::nDuration := NativeAudioGetDuration( ::hWnd )
    endif
return ::nDuration

//----------------------------------------------------------------------------//

METHOD GetMetadata() CLASS TNativeAudio
    local cData := NativeAudioGetMetadata( ::hWnd )
    local aData
   
    if ! Empty( cData )
        aData    := hb_ATokens( cData, "|" )
        ::cTitle  := aData[ 1 ]
        ::cArtist := aData[ 2 ]
        ::cAlbum  := aData[ 3 ]
    endif
   
return nil

//----------------------------------------------------------------------------//

function _FMAudio( pPlayer )
    local nAt := AScan( aPlayers, { | o | o:hWnd == pPlayer } )
    if nAt != 0
        if ! Empty( aPlayers[ nAt ]:bOnTime )
            Eval( aPlayers[ nAt ]:bOnTime, aPlayers[ nAt ] )
        endif
    endif
return nil

//----------------------------------------------------------------------------//
