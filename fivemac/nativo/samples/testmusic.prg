#include "FiveMac.ch"

//#define CLR_BLUE  8388608

static oTimer, nSecs, nProgs
static cSongName

function Main()
    local oWnd, oMusic, oSaySong, oSayVol, oSayArtist, oSayRun, oImg
    local oSlide, oSlide2, oSaydur
    local oSayTracks, oSayAlbum
    local oBrowse
    local aTracks := {}

    oMusic := TMusic():New()
    cSongName := ""

    aTracks := oMusic:GetTracks("Library")
    MsgInfo( "Tracks found: " + Str( Len( aTracks ) ) )
    
    

    DEFINE WINDOW oWnd TITLE "FiveMac Music Test" ;
        FROM 200, 200 TO 700, 870 FLIPPED

    @ 20, 20 BUTTON "Play/Pause" SIZE 100, 30 ACTION ( oMusic:PlayPause() ) OF oWnd
    @ 20, 130 BUTTON "Next" SIZE 80, 30 ACTION ( oMusic:NextTrack() ) OF oWnd
    @ 20, 220 BUTTON "Prev" SIZE 80, 30 ACTION ( oMusic:PreviousTrack() ) OF oWnd

    //   @ 20, 20 BUTTON "Play/Pause" SIZE 100, 30 ACTION ( oMusic:PlayPause(), oSaySong:SetText( oMusic:SongName() ), oImg:SetImage( oMusic:GetArtWork() ) ) OF oWnd
    //    @ 20, 130 BUTTON "Next" SIZE 80, 30 ACTION ( oMusic:NextTrack(), oSaySong:SetText( oMusic:SongName() ), oImg:SetImage( oMusic:GetArtWork() ) ) OF oWnd
    //    @ 20, 220 BUTTON "Prev" SIZE 80, 30 ACTION ( oMusic:PreviousTrack(), oSaySong:SetText( oMusic:SongName() ), oImg:SetImage( oMusic:GetArtWork() ) ) OF oWnd

  
    @ 20, 400 BROWSE oBrowse ;
        FIELDS  ""  ;
        HEADERS "Track"  ;
        OF oWnd SIZE 260, 190

    
    oBrowse:bLine = { | nRow | { aTracks[ nRow ] } }
    oBrowse:SetColWidth( 1, 226 )
    oBrowse:SetArray( aTracks )
    oBrowse:setRowPos(oMusic:GetCurrentTrackIndex())
    oBrowse:bChange    := { || oMusic:PlaybyIndex( oBrowse:nRowPos() ) }
    
  

    @ 70, 20 SAY "Volume:" OF oWnd
    @ 70, 80 SLIDER oSlide SIZE 150, 20 OF oWnd
    oSlide:SetValue( oMusic:GetVol() )
    oSlide:bChange := { | nVal | oMusic:SetVol( nVal ), oSayVol:SetText( AllTrim(Str(Int( nVal ))) ) }

    @ 75, 240 SAY oSayVol PROMPT AllTrim(Str(Int(oMusic:GetVol()))) SIZE 40, 20 OF oWnd

    @ 120, 20 SAY "Current Song:" OF oWnd
    @ 140, 20 SAY oSaySong PROMPT oMusic:SongName() SIZE 350, 20 OF oWnd
    oSaySong:SetColor( CLR_BLUE, 0 )

    @ 170, 20 SAY "Is Running:" OF oWnd
    @ 170, 100 SAY oSayRun PROMPT IF( oMusic:IsRun(), "YES", "NO" ) SIZE 50, 20 OF oWnd

    // @ 170, 150 SAY "Tracks:" OF oWnd
    // @ 170, 200 SAY oSayTracks PROMPT oMusic:GetTracks("Movies") SIZE 50, 20 OF oWnd
    // oSayTracks:SetColor( CLR_BLUE, 0 )
    
    @ 170, 150 SAY "Artist:" OF oWnd
    @ 170, 200 SAY oSayArtist PROMPT oMusic:GetArtist() SIZE 50, 20 OF oWnd
    oSayArtist:SetColor( CLR_BLUE, 0 )
    
    @ 170, 250 SAY "Album:" OF oWnd
    @ 170, 300 SAY oSayAlbum PROMPT oMusic:GetAlbum() SIZE 50, 20 OF oWnd
    oSayAlbum:SetColor( CLR_BLUE, 0 )

    nSecs:=oMusic:GetSonDuration() 
    nProgs:=oMusic:GetSonProgress()
    
   
    @ 230, 70 IMAGE oImg SIZE 200, 200 OF oWnd 
    oImg:nAutoResize = 12

    @ 470, 140 SAY oSayDur PROMPT AllTrim(cValtochar( nProgs )) +;
        "/"+AllTrim(cValtochar( nSecs))  SIZE 140, 20 OF oWnd
    oSayDur:nAutoResize = 12
    oSayDur:SetColor( CLR_BLUE, 0 )

    //msginfo(cValtochar(oMusic:GetCurrentTrackIndex() ))

    @ 450, 80 SLIDER oSlide2 SIZE 150, 20 OF oWnd
    oSlide2:SetMinMaxValue( 0, nSecs )
    oSlide2:SetValue( nProgs )
    oSlide2:bChange := { | nVal |  oMusic:SeekToSecond(nVal)  }
   
    oSlide2:nAutoResize = 10
   
 
    DEFINE TIMER oTimer INTERVAL 1 REPEAT OF oWnd ;
        ACTION ( Refresca( oMusic, oSaySong, oSayRun, oImg, oBrowse, oSlide2, oSayDur ))     
   
    ACTIVATE TIMER oTimer 

  

    ACTIVATE WINDOW oWnd

return nil

Function Refresca( oMusic, oSaySong, oSayRun, oImg, oBrowse, oSlide2, oSayDur )
   
      
    if  oMusic:IsRun()
        oSayRun:SetText( "YES" )
      
        if cSongName <> oMusic:SongName()
            cSongName := oMusic:SongName()
            oSaySong:SetText( cSongName )
            oImg:SetImage( oMusic:GetArtWork() ) 
            oBrowse:setRowPos(oMusic:GetCurrentTrackIndex())
            nSecs:=  oMusic:GetSonDuration() 
            oSlide2:SetMinMaxValue( 0, nSecs )
        endif
        nProgs:= oMusic:GetSonProgress() 
        oSlide2:SetValue( nProgs )
        oSayDur:SetText( AllTrim(cValtochar( nProgs)) +"/"+AllTrim(cValtochar( nSecs )) )
    else
        oSayRun:SetText( "NO" )
    endif
    
return nil