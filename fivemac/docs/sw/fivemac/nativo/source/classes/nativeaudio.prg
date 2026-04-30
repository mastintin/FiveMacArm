#include "FiveMac.ch"

static aPlayers := {}

CLASS TNativeAudio
    DATA hWnd
    DATA cFile
    DATA nDuration
    DATA cTitle, cArtist, cAlbum
    DATA bOnTime
    DATA bOnTrackEnd
    DATA bOnReady
    DATA bOnMetadata
   
    METHOD New( cFile )
    METHOD Play()       INLINE NativeAudioPlay( ::hWnd )
    METHOD Pause()      INLINE NativeAudioPause( ::hWnd )
    METHOD Stop()       INLINE NativeAudioStop( ::hWnd )
   
    METHOD GetDuration() 
    METHOD GetTime()    INLINE NativeAudioGetTime( ::hWnd )
    METHOD Seek( nSec ) INLINE NativeAudioSeek( ::hWnd, nSec )
    METHOD SetVol( nVol ) INLINE NativeAudioSetVol( ::hWnd, nVol )
   
    METHOD GetArtwork() INLINE NativeAudioGetArtwork( ::hWnd )
   
    METHOD SetObserver( bAction )
    
    METHOD Load( cFile )
    
    METHOD Stream( cUrl )
    
    METHOD IsReady() INLINE NativeAudioIsReady( ::hWnd )
    
    METHOD GetStreamMetadata() INLINE Music_Get_Metadata( ::hWnd )
    
    METHOD GetMetadata()
    
    METHOD IsPlaying() INLINE Music_IsPlaying( ::hWnd )
    
    METHOD RemoveObservers()

    METHOD End()        

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( cFile ) CLASS TNativeAudio

    if AScan( aPlayers, { | o | o == Self } ) == 0
        AAdd( aPlayers, Self )
    endif

    if ! Empty( cFile )
        ::Load( cFile )
    endif

return Self

//----------------------------------------------------------------------------//

METHOD Load( cFile ) CLASS TNativeAudio

    if ! Empty( cFile )
        ::RemoveObservers()
        if ! Empty( ::hWnd )
            Music_Release( ::hWnd )
        endif   
        ::cFile := cFile
        ::hWnd  := NativeAudioCreate( cFile )
        ::GetMetadata()
        ::nDuration := ::GetDuration()
        
        // Reinscripción automática de observadores si ya estaban definidos
        if ! Empty( ::bOnTime ) .or. ! Empty( ::bOnTrackEnd ) .or. ! Empty( ::bOnReady )
            ::SetObserver( ::bOnTime )
        endif
    endif

return nil

//----------------------------------------------------------------------------//

METHOD Stream( cUrl ) CLASS TNativeAudio

    if ! Empty( cUrl )
        ::RemoveObservers()
        if ! Empty( ::hWnd )
            Music_Release( ::hWnd )
        endif   
        ::cFile := cUrl
        ::hWnd  := Music_Load_Stream( cUrl )
        ::GetMetadata()
        ::nDuration := ::GetDuration()
        
        // Reinscripción automática de observadores si ya estaban definidos
        if ! Empty( ::bOnTime ) .or. ! Empty( ::bOnTrackEnd ) .or. ! Empty( ::bOnReady )
            ::SetObserver( ::bOnTime )
        endif
    endif

return nil

//----------------------------------------------------------------------------//

//----------------------------------------------------------------------------//

METHOD SetObserver( bAction ) CLASS TNativeAudio
    ::bOnTime := bAction
    ::RemoveObservers()
    if ! Empty( ::hWnd )
        Music_Set_Observer( ::hWnd )
    endif
return nil

//----------------------------------------------------------------------------//

METHOD RemoveObservers() CLASS TNativeAudio
    if ! Empty( ::hWnd )
        Music_Remove_Observers( ::hWnd )
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

            case nMsg == 3 // Ready to play
                if ! Empty( aPlayers[ nAt ]:bOnReady )
                    Eval( aPlayers[ nAt ]:bOnReady, aPlayers[ nAt ] )
                endif

            case nMsg == 4 // Metadata updated
                if ! Empty( aPlayers[ nAt ]:bOnMetadata )
                    Eval( aPlayers[ nAt ]:bOnMetadata, aPlayers[ nAt ] )
                endif
        endcase
    endif
    return nil

return nil

//----------------------------------------------------------------------------//
