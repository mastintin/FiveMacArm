#include "FiveMac.ch"
#include "SwFive.ch"

function Main()
   local oWnd
   
   DEFINE SWWINDOW oWnd TITLE "Isla: Ventana Principal" SIZE 400, 350
   
   @ 30, 20 SWLABEL "Monitor de la Isla" SIZE 300, 20 OF oWnd
   
   @ 70, 20 SWBUTTON "ACTUALIZAR CONTADOR" ;
            ACTION SwMsgInfo( "Objetos en Harbour: " + hb_ValToStr( SwiftCountItems() ), "Contador" ) ;
            SIZE 200, 30 OF oWnd
   
   @ 110, 20 SWBUTTON "ABRIR VENTANA HIJA" ;
            ACTION AbrirHija( oWnd ) ;
            SIZE 200, 30 OF oWnd
             
   @ 160, 20 SWLABEL "Instrucciones:" SIZE 300, 20 OF oWnd
   @ 180, 20 SWLABEL "1. Mira el contador (botón arriba)." SIZE 300, 20 OF oWnd
   @ 200, 20 SWLABEL "2. Abre Hija y Nieta." SIZE 300, 20 OF oWnd
   @ 220, 20 SWLABEL "3. Vuelve a mirar el contador." SIZE 300, 20 OF oWnd
   @ 240, 20 SWLABEL "4. Cierra Hija y comprueba la masacre." SIZE 300, 20 OF oWnd

   ACTIVATE SWWINDOW oWnd CENTER
   
return nil

//----------------------------------------------------------------------------//

function AbrirHija( oParent )
   local oWndHija
   
   DEFINE SWWINDOW oWndHija TITLE "Isla: Ventana Hija" SIZE 350, 250
   
   @ 30, 20 SWLABEL "Ventana Hija conectada a " + oParent:cId SIZE 300, 20 OF oWndHija
   
   @ 70, 20 SWBUTTON "1. ABRIR VENTANA NIETA" ;
            ACTION AbrirNieta( oWndHija ) ;
            SIZE 200, 30 OF oWndHija

   @ 110, 20 SWBUTTON "2. CONSULTAR VIVOS" ;
            ACTION SwMsgInfo( "Vivos: " + hb_ValToStr( SwiftCountItems() ) ) ;
            SIZE 200, 30 OF oWndHija

   @ 160, 20 SWBUTTON "3. CERRAR HIJA" ;
            ACTION oWndHija:Close() ;
            SIZE 200, 30 OF oWndHija

   ACTIVATE SWWINDOW oWndHija
   
return nil

//----------------------------------------------------------------------------//

function AbrirNieta( oParent )
   local oWndNieta
   
   DEFINE SWWINDOW oWndNieta TITLE "Isla: Ventana Nieta" SIZE 300, 200
   
   @ 30, 20 SWLABEL "Generación 3 (Nieta)" SIZE 200, 20 OF oWndNieta
   
   @ 70, 20 SWBUTTON "SALUDAR DESDE NIETA" ;
            ACTION SwMsgInfo( "¡Hola! La comunicación con la nieta funciona.", "Éxito" ) ;
            SIZE 220, 30 OF oWndNieta
             
   @ 110, 20 SWBUTTON "CERRAR NIETA" ;
            ACTION oWndNieta:Close() ;
            SIZE 220, 30 OF oWndNieta

   ACTIVATE SWWINDOW oWndNieta

return nil
