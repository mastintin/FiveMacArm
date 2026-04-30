#include "FiveMac.ch"

CLASS TSwiftMusic
   
    METHOD New()
    METHOD Play()       INLINE SD_MUSIC_PLAY()
    METHOD Pause()      INLINE SD_MUSIC_PAUSE()
    METHOD Next()       INLINE SD_MUSIC_NEXT()
    METHOD Previous()   INLINE SD_MUSIC_PREV()
    METHOD Stop()       INLINE SD_MUSIC_STOP()
    METHOD Auth()       INLINE SD_MUSIC_AUTH()
    METHOD GetState()   INLINE SD_MUSIC_STATE()
    METHOD GetMetadata() 
    
    METHOD GetArtworkPath() INLINE SD_MUSIC_GET_ARTWORK()
    METHOD GetDuration()    INLINE SD_MUSIC_GET_DURATION()
    METHOD GetPosition()    INLINE SD_MUSIC_GET_POSITION()
    METHOD SetPosition(nSec) INLINE SD_MUSIC_SET_POSITION(nSec)
    METHOD GetVolume()      INLINE SD_MUSIC_GET_VOLUME()
    METHOD SetVolume(nVol)  INLINE SD_MUSIC_SET_VOLUME(nVol)
    
    METHOD GetPlaylists()    INLINE hb_jsonDecode( SD_MUSIC_GET_PLAYLISTS() )
    METHOD PlayPlaylist(cName) INLINE SD_MUSIC_PLAY_PLAYLIST(cName)
    METHOD PlayFirst()       INLINE SD_MUSIC_PLAY_FIRST()

ENDCLASS

METHOD New() CLASS TSwiftMusic
return Self

METHOD GetMetadata() CLASS TSwiftMusic
    local cJson := SD_MUSIC_METADATA()
return cJson
