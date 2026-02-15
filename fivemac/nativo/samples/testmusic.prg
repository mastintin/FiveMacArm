#include "FiveMac.ch"

//#define CLR_BLUE  8388608

static oTimer, nSecs, nProgs

function Main()
    local oWnd, oMusic, oSaySong, oSayVol, oSayArtist, oSayRun, oImg
    local oSlide, oSlide2, oSaydur

    oMusic := TMusic():New()

    DEFINE WINDOW oWnd TITLE "FiveMac Music Test" ;
        FROM 200, 200 TO 700, 540 FLIPPED

    @ 20, 20 BUTTON "Play/Pause" SIZE 100, 30 ACTION ( oMusic:PlayPause(), oTimer:Activate()  ) OF oWnd
    @ 20, 130 BUTTON "Next" SIZE 80, 30 ACTION ( oMusic:NextTrack(), oTimer:Activate() ) OF oWnd
    @ 20, 220 BUTTON "Prev" SIZE 80, 30 ACTION ( oMusic:PreviousTrack(), oTimer:Activate() ) OF oWnd

    //   @ 20, 20 BUTTON "Play/Pause" SIZE 100, 30 ACTION ( oMusic:PlayPause(), oSaySong:SetText( oMusic:SongName() ), oImg:SetImage( oMusic:GetArtWork() ) ) OF oWnd
    //    @ 20, 130 BUTTON "Next" SIZE 80, 30 ACTION ( oMusic:NextTrack(), oSaySong:SetText( oMusic:SongName() ), oImg:SetImage( oMusic:GetArtWork() ) ) OF oWnd
    //    @ 20, 220 BUTTON "Prev" SIZE 80, 30 ACTION ( oMusic:PreviousTrack(), oSaySong:SetText( oMusic:SongName() ), oImg:SetImage( oMusic:GetArtWork() ) ) OF oWnd



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

    @ 190, 80 SLIDER oSlide2 SIZE 150, 20 OF oWnd
    oSlide2:SetMinMaxValue( 0, oMusic:GetSonDuration() )
    oSlide2:SetValue( oMusic:GetSonProGress() )
    oSlide2:bChange := { | nVal |  oMusic:SeekToSecond(nVal)  }
   
    nSecs:=GetSonDuration() 
    nProgs:=GetSonProgress() 
   
    @ 195, 240 SAY oSayDur PROMPT AllTrim(Str( nProgs )) +;
        "/"+AllTrim(Str( nSecs))  SIZE 140, 20 OF oWnd

    @ 230, 70 IMAGE oImg SIZE 200, 200 OF oWnd 
    oImg:nAutoResize = 18

 
    DEFINE TIMER oTimer INTERVAL 1 REPEAT OF oWnd ;
        ACTION ( oSaySong:SetText( oMusic:SongName() ), ;
        oSayVol:SetText( AllTrim(Str(Int(oMusic:GetVol()))) ), ;
        oSayRun:SetText( IF( oMusic:IsRun(), "YES", "NO" ) ), ;
        oImg:SetImage( oMusic:GetArtWork() ) ,;
        nSecs:=GetSonDuration() ,;  
        nProgs:=GetSonProgress() ,;  
        oSlide2:SetMinMaxValue( 0, nSecs ) ,;
        oSlide2:SetValue( nProgs ), ;
        oSayDur:SetText( AllTrim(Str( nProgs)) +"/"+AllTrim(Str( nSecs )) ) )     
   
    ACTIVATE TIMER oTimer 

    ACTIVATE WINDOW oWnd

return nil

Function GetSonDuration()
    local nSeconds:=  MUSICGETSONGDURATION()
    if nSeconds == nil
        nSeconds := 0 
    endif  
return nSeconds

Function GetSonProGress()
    local nSeconds:=  MUSICGETSONGPROGRESS()
    if nSeconds == nil
        nSeconds := 0 
    endif  
return nSeconds