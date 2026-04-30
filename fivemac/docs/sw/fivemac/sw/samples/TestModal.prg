#include "SwFive.ch"
 
function Main()
   local oWnd
    
   DEFINE WINDOW oWnd TITLE "Ventana Principal" SIZE 400, 300
    
   @ 50, 50 BUTTON "ABRIR LISTA MODAL" ;
      ACTION AbrirListaModal( oWnd ) ;
      SIZE 200, 40 OF oWnd
             
   ACTIVATE WINDOW oWnd CENTER
    
return nil
 
//----------------------------------------------------------------------------//
 
function AbrirListaModal( oParent )
   local oDlg, oList
   local nItems := 5
   local nSelected := 0
    
   DEFINE WINDOW oDlg TITLE "Selector de Ítems" SIZE 400, 500 OF oParent
   
   @ 20, 20 LIST oList OF oDlg SIZE 360, 380 ANCHOR SW_RESIZE_WIDTH + SW_RESIZE_HEIGHT
   
   for n := 1 to nItems
      AddFila( oList, n, { |nVal| nSelected := nVal, oDlg:End() } )
   next
   
   @ 420, 100 BUTTON "CANCELAR" ACTION oDlg:End() SIZE 200, 30 OF oDlg
             
   ACTIVATE WINDOW oDlg CENTER MODAL
   
   if nSelected > 0
      MsgInfo( "Has seleccionado el ítem número: " + hb_ntos( nSelected ), "Resultado" )
   else
      MsgInfo( "Has cancelado la selección", "Aviso" )
   endif
    
return nSelected

//----------------------------------------------------------------------------//
 
function AddFila( oList, n, bAction )
   local oRow
    
   DEFINE ROW oRow OF oList
    
   @ 0, 0 SAY "Ítem número: " + hb_ntos( n ) OF oRow SIZE 200, 25
   @ 0, 250 BUTTON "SELECCIONAR" ACTION Eval( bAction, n ) SIZE 100, 25 OF oRow
    
return nil
