#include "SwFive.ch"

// ---------------------------------------------------------
// Punto de entrada (Thread 0)
// ---------------------------------------------------------
function Main()
   HSW_START_SWIFT( "AppMain" )
return nil

// ---------------------------------------------------------
// Lógica de la aplicación (Thread 1)
// ---------------------------------------------------------
function AppMain()
   local oWnd
   
   DEFINE WINDOW oWnd TITLE "Isla HSW: Ventana Principal" SIZE 400, 350
   
   @ 30, 20 SAY "Monitor de la Isla HSW" SIZE 300, 20 OF oWnd
   
   @ 70, 20 BUTTON "ACTUALIZAR CONTADOR" ;
            ACTION MsgInfo( "Objetos en Harbour: " + hb_ValToStr( SwiftCountItems() ), "Contador" ) ;
            SIZE 200, 30 OF oWnd
   
   @ 110, 20 BUTTON "ABRIR VENTANA HIJA" ;
            ACTION AbrirHija( oWnd ) ;
            SIZE 200, 30 OF oWnd
             
   @ 160, 20 SAY "Instrucciones:" SIZE 300, 20 OF oWnd
   @ 180, 20 SAY "1. Mira el contador (botón arriba)." SIZE 300, 20 OF oWnd
   @ 200, 20 SAY "2. Abre Hija y Nieta." SIZE 300, 20 OF oWnd
   @ 220, 20 SAY "3. Vuelve a mirar el contador." SIZE 300, 20 OF oWnd
   @ 240, 20 SAY "4. Cierra Hija y comprueba la masacre." SIZE 300, 20 OF oWnd

   ACTIVATE WINDOW oWnd CENTER
   
return nil

//----------------------------------------------------------------------------//

function AbrirHija( oParent )
   local oWndHija
   
   DEFINE WINDOW oWndHija TITLE "Isla HSW: Ventana Hija" SIZE 350, 250
   
   @ 30, 20 SAY "Ventana Hija conectada a " + oParent:cId SIZE 300, 20 OF oWndHija
   
   @ 70, 20 BUTTON "1. ABRIR VENTANA NIETA" ;
            ACTION AbrirNieta( oWndHija ) ;
            SIZE 200, 30 OF oWndHija

   @ 110, 20 BUTTON "2. CONSULTAR VIVOS" ;
            ACTION MsgInfo( "Vivos: " + hb_ValToStr( SwiftCountItems() ) ) ;
            SIZE 200, 30 OF oWndHija

   @ 160, 20 BUTTON "3. CERRAR HIJA" ;
            ACTION oWndHija:Close() ;
            SIZE 200, 30 OF oWndHija

   ACTIVATE WINDOW oWndHija
   
return nil

//----------------------------------------------------------------------------//

function AbrirNieta( oParent )
   local oWndNieta
   
   DEFINE WINDOW oWndNieta TITLE "Isla HSW: Ventana Nieta" SIZE 300, 200
   
   @ 30, 20 SAY "Generación 3 (Nieta)" SIZE 200, 20 OF oWndNieta
   
   @ 70, 20 BUTTON "SALUDAR DESDE NIETA" ;
            ACTION MsgInfo( "¡Hola! La comunicación con la nieta funciona.", "Éxito" ) ;
            SIZE 220, 30 OF oWndNieta
             
   @ 110, 20 BUTTON "CERRAR NIETA" ;
            ACTION oWndNieta:Close() ;
            SIZE 220, 30 OF oWndNieta

   ACTIVATE WINDOW oWndNieta

return nil
