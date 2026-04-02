#include "FiveMac.ch"

function Main()

    local oWnd, oMusic
    local cUrl := "https://stream.live.vc.bbc.co.uk/bbc_world_service"

    DEFINE WINDOW oWnd TITLE "Prueba de Streaming Nativo" size 400, 200 NOFLIPPED 

    oMusic := TNativeAudio():New()
   
    @ 20, 20 BUTTON "Play Streaming" ACTION ( oMusic:Stream( cUrl ), oMusic:Play(), MsgInfo( "Cargando Stream..." ) ) SIZE 150, 30
    @ 60, 20 BUTTON "Stop" ACTION oMusic:Stop() SIZE 100, 30
   
    @ 100, 20 SAY "URL: " + cUrl SIZE 350, 20

    ACTIVATE WINDOW oWnd

return nil
