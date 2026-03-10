#include "FiveMac.ch"

CLASS TSwiftMusic
   
    METHOD New()
    METHOD Play()       INLINE SwiftMusicPlay()
    METHOD Pause()      INLINE SwiftMusicPause()
    METHOD Next()       INLINE SwiftMusicNext()
    METHOD Previous()   INLINE SwiftMusicPrev()
    METHOD Stop()       INLINE SwiftMusicStop()
    METHOD Auth()       INLINE SwiftMusicAuth()
    METHOD GetState()   INLINE SwiftMusicState()
    METHOD GetMetadata() 
    
    METHOD GetArtworkPath() INLINE SwiftMusicGetArtwork()
    METHOD GetDuration()    INLINE SwiftMusicGetDuration()
    METHOD GetPosition()    INLINE SwiftMusicGetPosition()
    METHOD SetPosition(nSec) INLINE SwiftMusicSetPosition(nSec)
    METHOD GetVolume()      INLINE SwiftMusicGetVolume()
    METHOD SetVolume(nVol)  INLINE SwiftMusicSetVolume(nVol)
    
    METHOD GetPlaylists()    INLINE hb_jsonDecode( SwiftMusicGetPlaylists() )
    METHOD PlayPlaylist(cName) INLINE SwiftMusicPlayPlaylist(cName)
    METHOD PlayFirst()       INLINE SwiftMusicPlayFirst()

ENDCLASS

METHOD New() CLASS TSwiftMusic
return Self

METHOD GetMetadata() CLASS TSwiftMusic
    local cJson := SwiftMusicMetadata()
    // Returns JSON string, can be parsed if needed or returned as is
return cJson
