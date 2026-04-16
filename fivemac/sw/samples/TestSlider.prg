#include "SwFive.ch"

function Main()

    local oWnd, oSld, oSay

    DEFINE WINDOW oWnd TITLE "Test: Swift Native Slider" SIZE 400, 300

    @ 20, 20 SAY oSay PROMPT "Volumen de la Radio: 50" OF oWnd 

    @ 60, 20 SLIDER oSld VALUE 50 RANGE 0, 100 OF oWnd ;
        ON CHANGE ( oSay:Caption := "Volumen de la Radio: " + AllTrim( Str( nVal ) ) )
    
    @ 110, 20 BUTTON "Set bAction with MsgInfo" OF oWnd SIZE 200, 40 ;
        ACTION oSld:bAction := { | n | MsgInfo( "Valor actual: " + str(n) ) }

    @ 160, 20 BUTTON "Restore Label Sync" OF oWnd SIZE 200, 40 ;
        ACTION oSld:bAction := { | n | oSay:Caption := "Volumen Restaurado: " + AllTrim( Str( n ) ) }

    @ 210, 20 BUTTON "Mover Abajo" OF oWnd SIZE 140, 40 ;
        ACTION oSld:nTop += 10

    @ 210, 180 BUTTON "Mover Derecha" OF oWnd SIZE 140, 40 ;
        ACTION oSld:nLeft += 10

    ACTIVATE WINDOW oWnd CENTER

return nil
