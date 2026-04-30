#include "FiveMac.ch"

static oMusic, oTimer
static oSaySong, oSayArtist, oSayAlbum, oImg
static oSlideVol, oSlideProg, oSayDur
static cLastSong := ""
static aPlaylist := {}
static nCurrentPos := 1


function Main()
    local oWnd
    local cFile

    // 1. Selector de archivo inicial (Nativo)
    cFile := ChooseFile( "Selecciona un MP3 (Autónomo)", "mp3" )
    if Empty( cFile )
        return nil
    endif
    
    AAdd( aPlaylist, cFile )

    // 2. Inicializar NativeAudio (Nativo AVPlayer, SIN App Música)
    oMusic := TNativeAudio():New( aPlaylist[ nCurrentPos ] )
    
    oMusic:bOnTrackEnd := { || 
    if nCurrentPos < Len( aPlaylist )
        nCurrentPos++
        oMusic:Stop()
        oMusic:Load( aPlaylist[ nCurrentPos ] )
        oMusic:Play()
        UpdateUI()
    else
        oMusic:Seek(0)
        oMusic:Play()
    endif
    }
    
    if Empty( oMusic:hWnd )
        MsgAlert( "No se pudo cargar el archivo: " + aPlaylist[ nCurrentPos ] )
        return nil
    endif

    oMusic:Play()

    // 3. Crear Interfaz (Nativa AppKit)
    DEFINE WINDOW oWnd TITLE "FiveMac Independent Player (AVFoundation)"  NOFLIPPED ;
        FROM 100, 100 TO 520, 600 FLIPPED

    ownd:SetReSizable( .F. )

    @ 20, 20 IMAGE oImg SIZE 180, 180 OF oWnd 
    //oImg:nAutoResize = 12 

    @ 20, 220 SAY "Título:" OF oWnd
    @ 40, 220 SAY oSaySong PROMPT oMusic:cTitle SIZE 250, 40 OF oWnd
    oSaySong:SetColor( CLR_BLUE, 0 )
    oSaySong:SetSizeFont( 16 )

    @ 85, 220 SAY "Artista:" OF oWnd
    @ 105, 220 SAY oSayArtist PROMPT oMusic:cArtist SIZE 250, 20 OF oWnd

    @ 135, 220 SAY "Álbum:" OF oWnd
    @ 155, 220 SAY oSayAlbum PROMPT oMusic:cAlbum SIZE 250, 20 OF oWnd

    // Controles de Reproducción
    @ 210, 20 BUTTON "Play" SIZE 60, 30 ACTION oMusic:Play() OF oWnd
    @ 210, 90 BUTTON "Pause" SIZE 60, 30 ACTION oMusic:Pause() OF oWnd
    @ 210, 160 BUTTON "Stop" SIZE 60, 30 ACTION oMusic:Stop() OF oWnd
    @ 210, 260 BUTTON "Abrir..." SIZE 110, 30 ACTION LoadNew( oMusic ) OF oWnd
    
    // Volumen
    @ 260, 20 SAY "Volumen:" OF oWnd
    @ 260, 90 SLIDER oSlideVol SIZE 380, 20 OF oWnd
    oSlideVol:SetValue( 80 )
    oMusic:SetVol( 80 )
    oSlideVol:bChange := { | nVal | oMusic:SetVol( nVal ) }

    // Progreso
    @ 305, 20 SAY "Posición playback:" OF oWnd
    @ 325, 20 SLIDER oSlideProg SIZE 460, 20 OF oWnd
    oSlideProg:SetMinMaxValue( 0, oMusic:GetDuration() )
    oSlideProg:bChange := { | nVal | oMusic:Seek( nVal ) }

    @ 350, 20 SAY oSayDur PROMPT "0:00 / 0:00" SIZE 200, 20 OF oWnd
    oSayDur:SetColor( 0x555555, 0 )

    // Observer de Refresco (Nativo, SIN Timer externo)
    oMusic:SetObserver( { || UpdateUI() } )

    ACTIVATE WINDOW oWnd

return nil

//----------------------------------------------------------------------------//

function LoadNew( oMusic )
    local cFile := ChooseFile( "Selecciona otro archivo MP3", "mp3" )
    if ! Empty( cFile )
        AAdd( aPlaylist, cFile )
        if Len( aPlaylist ) == 1
            nCurrentPos := 1
            oMusic:Stop()
            oMusic:Load( aPlaylist[ nCurrentPos ] )
            oMusic:Play()
           
            // Actualizar UI inmediata
            oSaySong:SetText( oMusic:cTitle )
            oSayArtist:SetText( oMusic:cArtist )
            oSayAlbum:SetText( oMusic:cAlbum )
            oImg:SetImage( oMusic:GetArtwork() )
            oSlideProg:SetMinMaxValue( 0, oMusic:GetDuration() )
        else
            MsgInfo( "Añadido a la cola de reproducción: " + cFile )
        endif
    endif
return nil

//----------------------------------------------------------------------------//

function UpdateUI()
    local nSecs, nPos

    if Empty( oMusic:hWnd )
        return nil
    endif
    

    if Empty( cLastSong ) .or. cLastSong != oMusic:cTitle
        cLastSong := oMusic:cTitle
        oSaySong:SetText( oMusic:cTitle )
        oSayArtist:SetText( oMusic:cArtist )
        oSayAlbum:SetText( oMusic:cAlbum )
        oImg:SetImage( oMusic:GetArtwork() )
        oSlideProg:SetMinMaxValue( 0, oMusic:GetDuration() )
    endif 

    nPos  := oMusic:GetTime()
    nSecs := oMusic:GetDuration()
    
    hb_default( @nPos, 0 )
    hb_default( @nSecs, 0 )

    oSlideProg:SetValue( nPos )
    oSayDur:SetText( cTimeMINSEC(nPos) + " / " + cTimeMINSEC(nSecs) )
    
  
return nil

//----------------------------------------------------------------------------//
