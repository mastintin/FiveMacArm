#include "SwFive.ch"
 
function Main()
 
    local oWnd, oList, oRow, oBtn, oLabel
    local n
 
    DEFINE WINDOW oWnd TITLE "Test: SwList Selectores" SIZE 600, 500
 
    // El List tiene coordenadas absolutas en la ventana (@)
    @ 20, 20 LIST oList OF oWnd SIZE 560, 400 ANCHOR SW_RESIZE_WIDTH + SW_RESIZE_HEIGHT
 
    for n := 1 to 20
        
        // Creamos una fila específica para la lista
        DEFINE ROW oRow OF oList
        // Acción específica para la FILA
        oRow:bAction := GenRowAction( n )
           
        if n % 2 != 0
           // El botón tiene su propia acción distinta
           @ 0, 0 BUTTON oBtn PROMPT "Click Item " + hb_ntos( n ) OF oRow SIZE 150, 25 
           oBtn:bAction := GenBtnAction( n )
        else
            @ 0, 0 LABEL "Fila de Texto: " + hb_ntos( n ) OF oRow SIZE 150, 25
        endif
 
        @ 0, 0 LABEL oLabel PROMPT " - Detalle " + hb_ntos(n) OF oRow SIZE 200, 25
        oLabel:bAction := GenDetailAction( n )
 
    next
 
    @ 430, 20 BUTTON "Vaciar Lista" OF oWnd ACTION ( oList:apply( "clear", .T. ) )
 
    ACTIVATE WINDOW oWnd CENTER
 
 return nil
 
//----------------------------------------------------------------------------//
// Funciones auxiliares para distinguir el origen del click
//----------------------------------------------------------------------------//
 
function GenRowAction( n )
return { || MsgInfo( "Has pulsado LA FILA número " + hb_ntos( n ) ) }
 
function GenBtnAction( n )
return { || MsgInfo( "Has pulsado el BOTÓN del ítem " + hb_ntos( n ) ) }
 
function GenDetailAction( n )
return { || MsgInfo( "Has pulsado el TEXTO-DETALLE de la fila " + hb_ntos( n ) ) }
