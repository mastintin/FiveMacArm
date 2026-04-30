#include "swfive.ch"
 
 function Main()
    HSW_START_SWIFT( "mainApp" )
 return nil
 
 function mainApp()
 
    local oWnd, oTgl1, oTgl2, oTgl3, oTgl4
 
    DEFINE WINDOW oWnd TITLE "Fivemac Premium Toggles" ;
       SIZE 400, 500
 
    @ 50, 50 TOGGLE oTgl1 ;
       PROMPT "Modo Avión" ;
       SUBTITLE "Desactiva todas las conexiones" ;
       ICON "airplane" ;
       OF oWnd 
    oTgl1:Color := "#FF9500"
 
    @ 110, 50 TOGGLE oTgl2 ;
       VALUE .T. ;
       PROMPT "Notificaciones" ;
       SUBTITLE "Recibe alertas en tiempo real" ;
       ICON "bell.badge.fill" ;
       OF oWnd ;
       STYLE SW_TOGGLE_SWITCH
    oTgl2:Color := "#FF2D55"
 
    @ 170, 50 TOGGLE oTgl3 ;
       PROMPT "Bluetooth" ;
       SUBTITLE "Conecta tus dispositivos" ;
       ICON "wave.3.right.circle.fill" ;
       OF oWnd ;
       SIZE 300, 40 ;
       STYLE SW_TOGGLE_BUTTON
    oTgl3:Color := "#007AFF"
 
    @ 230, 50 TOGGLE oTgl4 ;
       PROMPT "Aceptar términos" ;
       SUBTITLE "Debes leer el contrato" ;
       OF oWnd ;
       STYLE SW_TOGGLE_CHECKBOX
 
    @ 350, 150 BUTTON "Cerrar" OF oWnd ACTION oWnd:End()
 
    ACTIVATE WINDOW oWnd CENTER
 
 return nil
