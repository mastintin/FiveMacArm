#include "FiveMac.ch"
#include "SwFive.ch"

function Main()
   local oWnd
   
   DEFINE WINDOW oWnd TITLE "Isla: Ventana Principal" SIZE 400, 350
   
   @ 20, 20 LABEL "Monitor de la Isla" SIZE 300, 20 OF oWnd
   
   @ 60, 20 BUTTON "ACTUALIZAR CONTADOR" ;
            ACTION SwMsgInfo( "Objetos en Harbour: " + hb_ValToStr( SwiftCountItems() ), "Contador" ) ;
            SIZE 200, 30 OF oWnd
   
   @ 100, 20 BUTTON "ABRIR VENTANA HIJA" ;
            ACTION AbrirHija( oWnd ) ;
            SIZE 200, 30 OF oWnd
            
   @ 150, 20 SAY "Instrucciones:" SIZE 300, 20 OF oWnd
   @ 170, 20 SAY "1. Mira el contador (botón arriba)." SIZE 300, 20 OF oWnd
   @ 190, 20 SAY "2. Abre Hija y Nieta." SIZE 300, 20 OF oWnd
   @ 210, 20 SAY "3. Vuelve a mirar el contador." SIZE 300, 20 OF oWnd
   @ 230, 20 SAY "4. Cierra Hija y comprueba la masacre." SIZE 300, 20 OF oWnd

   ACTIVATE WINDOW oWnd CENTER
   
return nil

//----------------------------------------------------------------------------//

function AbrirHija( oParent )
   local oWndHija
   
   DEFINE WINDOW oWndHija TITLE "Isla: Ventana Hija" SIZE 350, 250 OF oParent
   
   @ 20, 20 LABEL "Ventana Hija conectada a " + oParent:cId SIZE 300, 20 OF oWndHija
   
   @ 60, 20 BUTTON "1. ABRIR VENTANA NIETA" ;
            ACTION AbrirNieta( oWndHija ) ;
            SIZE 200, 30 OF oWndHija

   @ 100, 20 BUTTON "2. CONSULTAR VIVOS" ;
            ACTION SwMsgInfo( "Vivos: " + hb_ValToStr( SwiftCountItems() ) ) ;
            SIZE 200, 30 OF oWndHija

   @ 150, 20 BUTTON "3. CERRAR HIJA" ;
            ACTION oWndHija:End() ;
            SIZE 200, 30 OF oWndHija

   ACTIVATE WINDOW oWndHija
   
return nil

//----------------------------------------------------------------------------//

function AbrirNieta( oParent )
   local oWndNieta
   
   DEFINE WINDOW oWndNieta TITLE "Isla: Ventana Nieta" SIZE 300, 200 OF oParent
   
   @ 20, 20 LABEL "Generación 3 (Nieta)" SIZE 200, 20 OF oWndNieta
   
   @ 60, 20 BUTTON "SALUDAR DESDE NIETA" ;
            ACTION SwMsgInfo( "¡Hola! La comunicación con la nieta funciona.", "Éxito" ) ;
            SIZE 220, 30 OF oWndNieta
            
   @ 100, 20 BUTTON "CERRAR NIETA" ;
            ACTION oWndNieta:End() ;
            SIZE 220, 30 OF oWndNieta

   ACTIVATE WINDOW oWndNieta

return nil
