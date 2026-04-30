// Sample showing MusicKit Integration via SwiftUI Bridge
#include "FiveMac.ch"
#include "SwiftControls.ch"

Static cSongName
Static nDur, nPos
static nState

function Main()

    local oWnd
    local oImg, oSaySong, oSayArtist, oSayTime
    local oBtnPlay, oBtnPrev, oBtnNext
    local oVol, oProg, oVolIcon
    local oTimer
    local oMusic := TSwiftMusic():New()
    
    // Auth on startup (async)
    oMusic:Auth()

    cSongName := ""
    nDur := 0
    nPos := 0
    
    // Proactive: If nothing playing, try to find ANY playlist with music
    if Empty( oMusic:GetMetadata() ) .or. oMusic:GetMetadata() == "{}"
        oMusic:PlayFirst() 
    endif

    DEFINE WINDOW oWnd TITLE "FiveMac Music"  NOFLIPPED ;
        FROM 100, 100 TO 800, 500 FLIPPED
    

    // --- Artwork (Top, Centered) ---
    // Window Width ~400. Center 200. Image 300x300. 
    // Left = (400-300)/2 = 50.
    @ 40, 50 SWIFTIMAGE oImg NAME "music.note" SIZE 300, 300 OF oWnd
    oImg:SetAutoResize( 0 ) // Fixed
    oImg:SetImage( "music.note" ) // System placeholder
    oImg:SetColor( 0xDDDDDD ) // Light gray placeholder

    // --- Metadata ---
    @ 360, 50 SWIFTLABEL oSaySong PROMPT "Not Playing" SIZE 300, 30 OF oWnd
    oSaySong:SetFont( 24 ) 
    oSaySong:SetColor( 0x000000 ) 

    @ 395, 50 SWIFTLABEL oSayArtist PROMPT "Artist" SIZE 300, 25 OF oWnd
    oSayArtist:SetFont( 16 )
    oSayArtist:SetColor( 0x888888 )

    // --- Progress ---
    // Slider
    @ 440, 50 SLIDER oProg SIZE 300, 20 OF oWnd
    oProg:SetMinMaxValue(0, 100)
    oProg:bChange := { |nVal| oMusic:SetPosition(nVal) }
    
    // Time Label
    @ 465, 50 SWIFTLABEL oSayTime PROMPT "--:-- / --:--" SIZE 300, 20 OF oWnd
    oSayTime:SetFont( 12 )
    oSayTime:SetColor( 0x666666 )

    // --- Controls ---
    // Width 400. Center 200.
    // Play: 60x60 -> at 170 (200 - 30)
    // Prev: 50x50 -> at 100 (170 - 20 - 50)
    // Next: 50x50 -> at 250 (170 + 60 + 20)
    
    // Prev
    @ 510, 100 SWIFTBUTTON oBtnPrev PROMPT "" SIZE 50, 50 OF oWnd ACTION oMusic:Previous()
    oBtnPrev:SetImage( "backward.fill" )
    oBtnPrev:SetRadius( 25 )
    
    // Play/Pause
    @ 505, 170 SWIFTBUTTON oBtnPlay PROMPT "" SIZE 60, 60 OF oWnd ;
        ACTION CheckStateAndToggle( oMusic, oImg, oVol, oProg, oSayTime, oSaySong, oSayArtist, oBtnPlay )
    oBtnPlay:SetImage( "play.fill" )
    oBtnPlay:SetRadius( 30 )
    oBtnPlay:SetColor( 0xFFFFFF, 0x007AFF ) // White on Blue

    // Next
    @ 510, 250 SWIFTBUTTON oBtnNext PROMPT "" SIZE 50, 50 OF oWnd ACTION oMusic:Next()
    oBtnNext:SetImage( "forward.fill" )
    oBtnNext:SetRadius( 25 )

    @ 570, 50 BUTTON "Playlists" SIZE 100, 20 OF oWnd ACTION MsgInfo( hb_ValToExp( oMusic:GetPlaylists() ) )

    // --- Volume ---
    @ 600, 100 SLIDER oVol SIZE 200, 20 OF oWnd
    oVol:SetMinMaxValue(0, 100)
    oVol:SetValue( oMusic:GetVolume() )
    oVol:bChange := { |nVal| oMusic:SetVolume(nVal) }
    
    // Volume Icon
    @ 600, 70 SWIFTIMAGE oVolIcon NAME "speaker.fill" SIZE 20, 20 OF oWnd


    // --- Timer ---
    // Change interval to 2 seconds to avoid saturating AppleScript bridge
    DEFINE TIMER oTimer INTERVAL 2 REPEAT OF oWnd ;
        ACTION UpdateUI( oMusic, oImg, oVol, oProg, oSayTime, oSaySong, oSayArtist, oBtnPlay )
    
    ACTIVATE TIMER oTimer

    ACTIVATE WINDOW oWnd ON INIT WndSetResizable( oWnd:hWnd, .f. )

return nil

FUNCTION CheckStateAndToggle( oMusic, oImg, oVol, oProg, oSayTime, oSaySong, oSayArtist, oBtnPlay )
   
     
    if nState == 1 // Playing
        oMusic:Pause()
        nState := 0
    else
        oMusic:Play()
        nState := 1 
    endif
    
    UpdateUI( oMusic, oImg, oVol, oProg, oSayTime, oSaySong, oSayArtist, oBtnPlay )
return nil

FUNCTION UpdateUI( oMusic, oImg, oVol, oProg, oSayTime, oSaySong, oSayArtist, oBtnPlay )
    local cArt   
    local hDatos := {=>} 
       
    // Update Play/Pause Icon dynamically
    if nState == 1
        oBtnPlay:SetImage( "pause.fill" )
    else
        oBtnPlay:SetImage( "play.fill" )
    endif

    hb_jsonDecode( oMusic:GetMetadata(), @hDatos )

    if Len(hDatos) > 0 .and. hb_HHasKey(hDatos, "title") .and. !Empty(hDatos["title"]) 
        if cSongName <> hDatos["title"]
            cSongName := hDatos["title"]
            
            // Text Updates
            oSaySong:SetText( cSongName )
            if hb_HHasKey(hDatos, "artist")
                oSayArtist:SetText( hDatos["artist"] )
            endif
            
            // Artwork Update
            cArt := oMusic:GetArtworkPath()
            if !Empty(cArt)
                oImg:SetFile( cArt )
            else
                oImg:SetImage( "music.note" ) 
            endif
            
            nDur := oMusic:GetDuration()
        endif
    endif
   
    nPos := oMusic:GetPosition()   
   
    if nDur > 0
        oProg:SetMinMaxValue(0, nDur)
        oProg:SetValue(nPos)
        oSayTime:SetText( Tiempos() )
    endif
   
return nil

Function Tiempos()
    local cPos := FormatSegundos(nPos)
    local cDur := FormatSegundos(nDur)
return cPos + " / " + cDur

STATIC FUNCTION FormatSegundos(nTotalSeg)
    LOCAL nMinutos  := Int(nTotalSeg / 60)
    LOCAL nSegundos := Int(nTotalSeg % 60)
return StrZero(nMinutos, 2) + ":" + StrZero(nSegundos, 2)