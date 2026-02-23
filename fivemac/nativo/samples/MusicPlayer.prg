#include "FiveMac.ch"

static oMusic, oTimer
static oSaySong, oSayArtist, oSayAlbum, oImg
static oSlideVol, oSlideProg, oSayDur
static cLastSong := ""

function Main()
    local oWnd
    local cFile

    // 1. Selector de archivo inicial
    cFile := ChooseFile( "Selecciona un archivo MP3", "mp3" )
    if Empty( cFile )
    return nil
    endif

    // 2. Inicializar Music y añadir el track
    oMusic := TMusic():New()
    MusicAddTrack( , cFile ) // Usamos la función de bajo nivel para añadir/abrir el archivo

    // 3. Crear Interfaz
    DEFINE WINDOW oWnd TITLE "FiveMac Music Player" ;
        FROM 100, 100 TO 550, 500 FLIPPED

    @ 20, 20 IMAGE oImg SIZE 180, 180 OF oWnd 
    oImg:nAutoResize = 12 // Pin to top-left

    @ 20, 220 SAY "Canción:" OF oWnd
    @ 40, 220 SAY oSaySong PROMPT "Cargando..." SIZE 250, 20 OF oWnd
    oSaySong:SetColor( CLR_BLUE, 0 )

    @ 70, 220 SAY "Artista:" OF oWnd
    @ 90, 220 SAY oSayArtist PROMPT "" SIZE 250, 20 OF oWnd

    @ 120, 220 SAY "Álbum:" OF oWnd
    @ 140, 220 SAY oSayAlbum PROMPT "" SIZE 250, 20 OF oWnd

    // Controles de Reproducción
    @ 220, 20 BUTTON "Play/Pause" SIZE 100, 30 ACTION oMusic:PlayPause() OF oWnd
    @ 220, 130 BUTTON "Stop" SIZE 80, 30 ACTION oMusic:Stop() OF oWnd
    
    // Volumen
    @ 260, 20 SAY "Volumen:" OF oWnd
    @ 260, 90 SLIDER oSlideVol SIZE 150, 20 OF oWnd
    oSlideVol:SetValue( oMusic:GetVol() )
    oSlideVol:bChange := { | nVal | oMusic:SetVol( nVal ) }

    // Progreso
    @ 310, 20 SAY "Progreso:" OF oWnd
    @ 330, 20 SLIDER oSlideProg SIZE 350, 20 OF oWnd
    oSlideProg:bChange := { | nVal | oMusic:SeekToSecond( nVal ) }

    @ 355, 20 SAY oSayDur PROMPT "0:00 / 0:00" SIZE 200, 20 OF oWnd
    oSayDur:SetColor( 0x888888, 0 )

    // Timer de Refresco
    DEFINE TIMER oTimer INTERVAL 1 REPEAT OF oWnd ;
        ACTION UpdateUI()

    ACTIVATE TIMER oTimer

    ACTIVATE WINDOW oWnd

return nil

//----------------------------------------------------------------------------//

function UpdateUI()
    local cSong, nSecs, nProgs

    if ! oMusic:IsRun()
    return nil
    endif

    cSong := oMusic:SongName()
    
    // Si ha cambiado la canción, actualizamos metadatos pesados
    if cSong != cLastSong
    cLastSong := cSong
    oSaySong:SetText( cSong )
    oSayArtist:SetText( oMusic:GetArtist() )
    oSayAlbum:SetText( oMusic:GetAlbum() )
    oImg:SetImage( oMusic:GetArtWork() )
       
    nSecs := oMusic:GetSonDuration()
    oSlideProg:SetMinMaxValue( 0, nSecs )
    endif

    // Actualizamos progreso cada segundo
    nSecs := oMusic:GetSonDuration()
    nProgs := oMusic:GetSonProgress()
    
    oSlideProg:SetValue( nProgs )
    oSayDur:SetText( FormatTime( nProgs ) + " / " + FormatTime( nSecs ) )

return nil

//----------------------------------------------------------------------------//

function FormatTime( nSeconds )
    local nMin, nSec
    nMin := Int( nSeconds / 60 )
    nSec := Int( nSeconds % 60 )
return AllTrim( Str( nMin ) ) + ":" + PadL( AllTrim( Str( nSec ) ), 2, "0" )
