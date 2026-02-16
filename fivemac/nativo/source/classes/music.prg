#include "FiveMac.ch"

//----------------------------------------------------------------------------//

CLASS TMusic 
    DATA hWnd

    METHOD New(nVolume)
    METHOD SetVol(nVol) INLINE MusicSetVol(::hWnd,nVol)
    METHOD GetVol() INLINE MusicGetVol(::hWnd)
    METHOD isRun() INLINE MusicIsRun(::hWnd)
    METHOD Run()   INLINE MusicRun(::hWnd)
    METHOD Quit()  INLINE MusicQuit(::hWnd)
    METHOD Stop()  INLINE MusicStop(::hWnd)
    METHOD Play()  INLINE MusicPlay(::hWnd) 
    METHOD SongName()  INLINE MusicSongName(::hWnd)
    METHOD PlayPause() INLINE MusicPlayPause(::hWnd)
    METHOD NextTrack() INLINE MusicNextTrack(::hWnd)
    METHOD PreviousTrack() INLINE MusicPreviousTrack(::hWnd)
    METHOD backTrack() INLINE MusicbackTrack(::hWnd)
    METHOD GetTracks(cLibrary) 
    METHOD GetArtist()   INLINE MusicGetArtist(::hWnd)
    METHOD GetAlbum()    INLINE MusicGetAlbum(::hWnd)
    METHOD GetState()    INLINE MusicGetState(::hWnd)
    METHOD Debug()       INLINE MusicDebug(::hWnd)
    METHOD GetArtWork()  INLINE MusicGetArtWork()    
    METHOD GetTrackArtwork() INLINE MusicGetTrackArtwork()  
    METHOD GetSonProGress()
    METHOD GetSonDuration()
    METHOD GetSonLyrics() INLINE  MUSICGETSONGLYRICS()
    METHOD SeekToSecond( nSecond ) INLINE MUSICSEEKTOSECOND( nSecond )    
    METHOD GetCurrentTrackNumber() INLINE MUSICGETCURRENTTRACKNUMBER()
    METHOD GetCurrentTrackIndex() INLINE MUSICGETCURRENTTRACKINDEX()  
    METHOD PlaybyIndex(nIndex ) INLINE   MUSICPLAYBYINDEX( nIndex )  
ENDCLASS   

//----------------------------------------------------------------------------//

METHOD New(nVolume) CLASS TMusic
   
    ::hWnd = MusicCreate()
    if !Empty(nVolume)
        ::setVol(nVolume)
    endif
      
return Self

//----------------------------------------------------------------------------//

METHOD GetTracks(cLibrary) CLASS TMusic
    
    local nLen, i 
    local aTracks
  
    if UPPER (cLibrary) == "LIBRARY"
        cLibrary :=  "Library"
    endif
    
    aTracks := MusicGetTracks(::hWnd, cLibrary)
   
Return aTracks 
//----------------------------------------------------------------------------//
METHOD GetSonDuration() CLASS TMusic
    local nSeconds:=  MUSICGETSONGDURATION()
    if nSeconds == nil
        nSeconds := 0 
    endif  
return nSeconds
//----------------------------------------------------------------------------//
METHOD GetSonProGress() CLASS TMusic
    local nSeconds:=  MUSICGETSONGPROGRESS()
    if nSeconds == nil
        nSeconds := 0 
    endif  
return nSeconds
