#include "SwFive.ch"
 
function Main()
   HSW_START_SWIFT( "AppMain" )
return nil

function AppMain()
   local oWnd, oList, oBtn
   static nItems := 0
    
   DEFINE WINDOW oWnd TITLE "Isla HSW: Consulta de Índices" SIZE 400, 500
    
   @ 20, 20 LIST oList OF oWnd SIZE 360, 380 ANCHOR SW_RESIZE_WIDTH + SW_RESIZE_HEIGHT
   
   // Usamos el nuevo método GetIndex( cId ) para obtener la posición real
   oList:bAction := { |cId, oList| msginfo( "Has pulsado la fila número: " + hb_ntos( oList:GetIndex( cId ) ) ) }
    
   @ 420, 20 BUTTON "AÑADIR FILA AL VUELO" ;
      ACTION ( nItems++, AddFila( oList, nItems ) ) ;
      SIZE 200, 30 OF oWnd
             
   @ 460, 20 SAY "Pulsa el botón para añadir a la lista" SIZE 300, 20 OF oWnd
 
   ACTIVATE WINDOW oWnd CENTER
    
return nil
 
//----------------------------------------------------------------------------//
 
function AddFila( oList, n )
   local oRow
    
   DEFINE ROW oRow OF oList
    
   @ 0, 0 SAY "Ítem número: " + hb_ntos( n ) OF oRow SIZE 150, 25
   @ 0, 160 BUTTON "X" ACTION oRow:End() SIZE 30, 25 OF oRow
    
return nil
