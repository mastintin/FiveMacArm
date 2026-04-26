#include "SwFive.ch"

function Main()
    HSW_START_SWIFT( "AppMain" )
return nil

function AppMain()
    local oWnd, oSld, oSay

    DEFINE WINDOW oWnd TITLE "Test: Swift Native Slider" SIZE 400, 350

    @ 230, 20 SAY oSay PROMPT "Volumen de la Radio: 50" OF oWnd 
    oSay:SetFontSize( 20 )

    @ 160, 20 SLIDER oSld VALUE 50 RANGE 0, 100 OF oWnd SIZE 200, 40 ;
        ACTION ( oSay:SetText( "Volumen de la Radio: " + AllTrim( Str( oSld:Value ) ) ) )
    
    @ 20, 20 BUTTON "Set bAction with MsgInfo" OF oWnd SIZE 200, 40 ;
        ACTION oSld:bAction := { | n | MsgInfo( "Valor actual: " + str(n) ) }

    @ 70, 20 BUTTON "Restore Label Sync" OF oWnd SIZE 200, 40 ;
        ACTION oSld:bAction := { | n | oSay:SetText( "Volumen Restaurado: " + AllTrim( Str( n ) ) ) }

    @ 120, 20 BUTTON "Mover Abajo" OF oWnd SIZE 140, 40 ;
        ACTION oSld:nTop += 10

    @ 120, 180 BUTTON "Mover Derecha" OF oWnd SIZE 140, 40 ;
        ACTION oSld:nLeft += 10

    ACTIVATE WINDOW oWnd CENTER
return nil

