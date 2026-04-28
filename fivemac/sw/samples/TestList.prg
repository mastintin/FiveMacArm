#include "swfive.ch"

function Main()
    HSW_START_SWIFT( "AppMain" )
return nil

function AppMain()

   local oWnd, oList, oBtn, oRow
   local aItems := { "Apple", "Microsoft", "Google", "Amazon", "Tesla", "Meta", "Netflix" }
   local n

   DEFINE WINDOW oWnd TITLE "Fivemac: Modern ListBox Test" SIZE 600, 500

   @ 20, 20 SAY "Seleccione una compañía de la lista:" OF oWnd SIZE 300, 20

   // Creación del LISTBOX con estilo Premium (3) y barra de búsqueda nativa
   @ 50, 20 LIST oList OF oWnd SIZE 560, 350 STYLE 3 SEARCH
   
   // Poner el buscador en la parte superior dentro de la tarjeta (estilo 1)
   oList:nSearchStyle := 1
   
   // Dándole una acción a la lista para que se note que responde al clic
   oList:bAction := { | cRowId, oObj | MsgInfo( "¡Lista clicada! Has seleccionado el índice: " + hb_ValToStr( oObj:SelectedIndex ), "Evento de Lista" ) }
      // Añadiendo filas dinámicamente
    for n := 1 to Len( aItems )
       DEFINE ROW oRow OF oList
          @ 5, 10 SAY aItems[n] OF oRow SIZE 200, 25
          @ 5, 250 BUTTON oBtn PROMPT "Info" OF oRow SIZE 60, 25
          oBtn:bAction := MakeAction( aItems[n] )
    next

   // Botón para consultar el estado desde Harbour
   @ 420, 20 BUTTON oBtn PROMPT "Consultar Selección" OF oWnd SIZE 180, 30 ;
      ACTION MsgInfo( "ID: " + hb_ValToStr( oList:cSelectedId ) + CRLF + "Index: " + hb_ValToStr( oList:SelectedIndex ), "Estado de la Lista" )

   @ 420, 220 BUTTON "Limpiar Lista" OF oWnd SIZE 140, 30 ;
      ACTION oList:Clear()

   ACTIVATE WINDOW oWnd CENTER

return nil

function MakeAction( cItem )
return {|| MsgInfo( "Has pulsado en " + cItem ) }
