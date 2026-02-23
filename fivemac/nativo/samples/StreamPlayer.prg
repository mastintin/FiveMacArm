#include "FiveMac.ch"

static oMusic, oSayStation, oSayStatus, oSayLoading, oTmr
static oSayArtist, oSaySong

//----------------------------------------------------------------------------//

function Main()

    local oWnd, oCbx, nPos, oSld
    local cStation := ""
    local aStations := { ;
        { "SomaFM Groove Salad", "https://ice1.somafm.com/groovesalad-128-mp3" }, ;
        { "BBC World Service", "https://stream.live.vc.bbc.co.uk/bbc_world_service" }, ;
        { "Jazz Radio (Paris)", "http://jazzradio.ice.infomaniak.ch/jazzradio-high.mp3" }, ;
        { "Classic FM (UK)", "http://ice-the.musicradio.com/ClassicFMMP3" }, ;
        { "RTVE (España)", "https://shoutcast.rtve.es" } ,;
        { "Kiss FM (España)", "https://bbkissfm.kissfmradio.cires21.com:8443/bbkissfm/mp3/icecast.audio?wmsAuthSign=c2VydmVyX3RpbWU9MDIvMjMvMjAyNiAwNjozMDoxMCBQTSZoYXNoX3ZhbHVlPVloVkNPaTJQckdycUV0YnNWV2pmaXc9PSZ2YWxpZG1pbnV0ZXM9MTQ0MCZpZD05Nzk1NjIzOA==" } ;
        }

    DEFINE WINDOW oWnd TITLE "FiveMac Streaming Player" SIZE 500, 350 FLIPPED

    oMusic := TNativeAudio():New()

    @ 20, 20 SAY "Selecciona una emisora:" SIZE 200, 20
   
    @ 50, 20 COMBOBOX oCbx VAR cStation PROMPTS ArrayColumn( aStations, 1 ) ;
        OF oWnd SIZE 300, 25 ;
        ON CHANGE ( nPos := oCbx:nItemSelected(), ;
        oSayStation:SetText( aStations[ nPos ][ 1 ] ), ;
        oMusic:Stream( aStations[ nPos ][ 2 ] ), ;
        oSayStatus:SetText( "Estado: Conectando..." ), ;
        oSayArtist:SetText( "" ), ;
        oSaySong:SetText( "" ), ;
        oSayLoading:Show(), ;
        oTmr:Activate() )

    @ 90, 20 SAY oSayStation PROMPT "Ninguna seleccionada" SIZE 400, 30 
   
    @ 130, 20 SAY "Artista:" SIZE 80, 20
    @ 130, 100 SAY oSayArtist PROMPT "" SIZE 380, 20
   
    @ 160, 20 SAY "Canción:" SIZE 80, 20
    @ 160, 100 SAY oSaySong PROMPT "" SIZE 380, 20

    @ 190, 20 SAY oSayStatus PROMPT "Estado: Detenido" SIZE 400, 20

    // Mensaje de Buffering
    @ 80, 350 SAY oSayLoading PROMPT "CARGANDO..." SIZE 200, 30
    oSayLoading:Hide()
   
    @ 230, 20 BUTTON "Play" SIZE 100, 30 ;
        ACTION ( oMusic:Play(), oSayStatus:SetText( "Estado: Reproduciendo..." ) )

    @ 230, 130 BUTTON "Stop" SIZE 100, 30 ;
        ACTION ( oMusic:Stop(), oSayStatus:SetText( "Estado: Detenido" ), oSayLoading:Hide(), oTmr:DeActivate() )

    @ 270, 20 SAY "Volumen:" SIZE 100, 20
    @ 270, 100 SLIDER oSld SIZE 350, 25 OF oWnd ;
        ON CHANGE oMusic:SetVol( oSld:GetValue() )
    oSld:SetValue( 100 )

    // Definimos el timer (1 segundo para monitorizar buffer y metadatos)
    DEFINE TIMER oTmr INTERVAL 1 ACTION MonitorPlayer() OF oWnd
    oTmr:DeActivate()

    ACTIVATE WINDOW oWnd ;
        ON INIT oSayLoading:Hide() ;
        CENTERED

return nil

//----------------------------------------------------------------------------//

function MonitorPlayer()
    local cMetadata, aMeta
   
    if oMusic:IsReady() 
        oSayLoading:Hide()
      
        // Intentamos obtener metadatos del stream
        cMetadata := oMusic:GetStreamMetadata()
      
        if ! Empty( cMetadata ) .and. " - " $ cMetadata
            aMeta := hb_ATokens( cMetadata, " - " )
            if Len( aMeta ) >= 2
                if ! "Unknown" $ aMeta[ 1 ]
                    oSayArtist:SetText( aMeta[ 1 ] )
                endif
                if ! "Unknown" $ aMeta[ 2 ]
                    oSaySong:SetText( aMeta[ 2 ] )
                endif
            endif
            oSayStatus:SetText( "Estado: Reproduciendo (con metadatos)" )
        else
            oSayStatus:SetText( "Estado: Reproduciendo..." )
        endif
      
        if ! oMusic:IsPlaying()
            oMusic:Play()
        endif

    else
        oSayStatus:SetText( "Estado: Conectando..." )
    endif
   
return nil

//----------------------------------------------------------------------------//

function ArrayColumn( aArray, nCol )
    local aRes := {}
    local n
    for n := 1 to Len( aArray )
        AAdd( aRes, aArray[ n ][ nCol ] )
    next
return aRes

//----------------------------------------------------------------------------//
