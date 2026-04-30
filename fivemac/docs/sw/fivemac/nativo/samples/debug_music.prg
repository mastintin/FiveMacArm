#include "FiveMac.ch"

function Main()
    local oMusic := TMusic():New()
    if ! oMusic:IsRun()
    MsgInfo( "Starting Music app..." )
    oMusic:Run()
    inkey(2)
    endif

    // Wait for library to load
    aTracks := {}
    nAttempts := 0
    while Len(aTracks) == 0 .and. nAttempts < 20
    aTracks := oMusic:GetTracks( "Music" )
    if Len(aTracks) == 0
    SysWait(0.5)
    nAttempts++
    endif
    end
    
    // Refresh volume and play
    oMusic:SetVol( 70 )
    oMusic:Play()
    oMusic:Play()
    oMusic:Debug()

    MsgInfo( "Tracks found: " + AllTrim(Str(Len(aTracks))) )
   
    MsgInfo( "Song: " + oMusic:SongName() + CRLF + ;
        "Current Volume: " + AllTrim(Str(oMusic:GetVol())) + CRLF + ;
        "State: " + AllTrim(Str(oMusic:GetState())) )

return nil
