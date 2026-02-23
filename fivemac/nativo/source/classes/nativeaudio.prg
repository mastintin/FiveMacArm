#include "FiveMac.ch"

static aPlayers := {}

CLASS TNativeAudio
    DATA hWnd
    DATA cFile
    DATA nDuration
    DATA cTitle, cArtist, cAlbum
    DATA bOnTime
    DATA bOnTrackEnd
    DATA hTimeObs, hEndObs
   
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
   
    METHOD SetObserver( bAction )
    
    METHOD Load( cFile )
    
    METHOD RemoveObservers()

    METHOD End()        

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( cFile ) CLASS TNativeAudio

    if ! Empty( cFile )
        ::Load( cFile )
        if AScan( aPlayers, { | o | o == Self } ) == 0
            AAdd( aPlayers, Self )
        endif
    endif

return Self

//----------------------------------------------------------------------------//

METHOD Load( cFile ) CLASS TNativeAudio

    if ! Empty( cFile )
        ::RemoveObservers()
        ::cFile := cFile
        ::hWnd  := NativeAudioCreate( cFile )
        ::GetMetadata()
        ::nDuration := ::GetDuration()
        
        // Reinscripción automática de observadores si ya estaban definidos
        if ! Empty( ::bOnTime ) .or. ! Empty( ::bOnTrackEnd )
            ::SetObserver( ::bOnTime )
        endif
    endif

return nil

//----------------------------------------------------------------------------//

METHOD SetObserver( bAction ) CLASS TNativeAudio
    local aTokens
    ::bOnTime := bAction
    ::RemoveObservers()
    if ! Empty( ::hWnd )
        aTokens := Music_Set_Observer( ::hWnd )
        ::hTimeObs := aTokens[ 1 ]
        ::hEndObs  := aTokens[ 2 ]
    endif
return nil

//----------------------------------------------------------------------------//

METHOD RemoveObservers() CLASS TNativeAudio
    if ! Empty( ::hTimeObs ) .or. ! Empty( ::hEndObs )
        Music_Remove_Observers( ::hWnd, ::hTimeObs, ::hEndObs )
        ::hTimeObs := nil
        ::hEndObs  := nil
    endif
return nil

//----------------------------------------------------------------------------//

METHOD End() CLASS TNativeAudio
    local nAt 
    ::RemoveObservers()
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

function _FMAudio( pPlayer, nMsg )
    local nAt := AScan( aPlayers, { | o | o:hWnd == pPlayer } )
    
    if nAt != 0
        do case
            case nMsg == 1 // Time change
                if ! Empty( aPlayers[ nAt ]:bOnTime )
                    Eval( aPlayers[ nAt ]:bOnTime, aPlayers[ nAt ] )
                endif
            
            case nMsg == 2 // End of playback
                if ! Empty( aPlayers[ nAt ]:bOnTrackEnd )
                    Eval( aPlayers[ nAt ]:bOnTrackEnd, aPlayers[ nAt ] )
                endif
        endcase
    endif
return nil

//----------------------------------------------------------------------------//
