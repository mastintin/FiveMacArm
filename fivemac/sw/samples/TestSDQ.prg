#include "swfive.ch"
 
 function Main()
    local oWnd, oSay
    local cIP := "Iniciando consulta..."
 
    DEFINE WINDOW oWnd TITLE "Isla - Test de Diálogo (SDQ)" SIZE 500, 300
 
       @ 50, 40 SAY oSay PROMPT "Pulsa el botón para interrogar a la Isla" OF oWnd SIZE 420, 30
 
       @ 120, 150 BUTTON "Consultar IP Local" OF oWnd ;
          ACTION ( ConsultarIP( oSay ) ) ;
          SIZE 200, 40
 
       @ 180, 150 BUTTON "Estado de la App" OF oWnd ;
          ACTION ( ConsultarEstado() ) ;
          SIZE 200, 40
 
    ACTIVATE WINDOW oWnd
 
 return nil
 
 function ConsultarIP( oSay )
    local cIP
    oSay:SetText( "Consultando a Swift..." )
    cIP := SDQ:getIP()
    oSay:SetText( "Tu IP detectada es: " + cIP )
    MsgInfo( "Swift ha respondido de forma síncrona: " + cIP, "Resultado SDQ" )
 return nil
 
 function ConsultarEstado()
    if SDQ:isRunning()
       MsgInfo( "Swift confirma: La App está en ejecución", "Query OK" )
    else
       MsgInfo( "La App informa de un estado inesperado", "Query Error" )
    endif
 return nil
