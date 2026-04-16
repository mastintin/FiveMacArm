#include "SwFive.ch"

function Main()

    local oWnd, oWeb, oSay
    local cUrl := "https://www.google.com"

    DEFINE WINDOW oWnd TITLE "Swift Island: WebView Test" SIZE 800, 600

    @ 10, 20 SAY oSay PROMPT "Navegador Reactivo" OF oWnd SIZE 300, 30

    @ 50, 20 WEBVIEW oWeb URL cUrl OF oWnd SIZE 760, 480

    @ 540, 20 BUTTON "Google" OF oWnd SIZE 100, 40 ;
        ACTION oWeb:Url := "https://www.google.com"

    @ 540, 130 BUTTON "Bing" OF oWnd SIZE 100, 40 ;
        ACTION oWeb:Url := "https://www.bing.com"

    @ 540, 240 BUTTON "< Volver" OF oWnd SIZE 100, 40 ;
        ACTION oWeb:GoBack()

    @ 540, 350 BUTTON "Subir 20px" OF oWnd SIZE 120, 40 ;
        ACTION oWeb:nTop -= 20

    @ 540, 480 BUTTON "Bajar 20px" OF oWnd SIZE 120, 40 ;
        ACTION oWeb:nTop += 20

    ACTIVATE WINDOW oWnd CENTER

return nil
