#include "FiveMac.ch"
#include "SwFive.ch"

function Main()
   local oWnd, oList, oBtn
   static nItems := 0
   
   DEFINE WINDOW oWnd TITLE "Isla: Filas Dinámicas" SIZE 400, 500
   
   @ 20, 20 LIST oList OF oWnd SIZE 360, 350 ANCHOR SW_RESIZE_WIDTH + SW_RESIZE_HEIGHT
   
   @ 380, 20 BUTTON "AÑADIR FILA AL VUELO" ;
            ACTION ( nItems++, AddFila( oList, nItems ) ) ;
            SIZE 200, 30 OF oWnd
            
   @ 420, 20 SAY "Pulsa el botón para añadir a la lista" SIZE 300, 20 OF oWnd

   ACTIVATE WINDOW oWnd CENTER
   
return nil

//----------------------------------------------------------------------------//

function AddFila( oList, n )
   local oRow
   
   // Exactamente la misma sintaxis que al principio
   DEFINE ROW oRow OF oList
   
   @ 0, 0 SAY "Ítem número: " + hb_ntos( n ) OF oRow SIZE 150, 25
   @ 0, 160 BUTTON "X" ACTION oRow:End() SIZE 30, 25 OF oRow
   
return nil
