#include "swfive.ch"

function Main()

   local oWnd, oList, oBtn, oRow
   local aItems := { "Apple", "Microsoft", "Google", "Amazon", "Tesla", "Meta", "Netflix" }
   local n

   DEFINE WINDOW oWnd TITLE "Fivemac: Modern ListBox Test" SIZE 600, 500

   @ 20, 20 SAY "Seleccione una compañía de la lista:" OF oWnd SIZE 300, 20

   // Creación del LISTBOX
   @ 50, 20 LIST oList OF oWnd SIZE 560, 350
   
   // Añadiendo filas dinámicamente
   for n := 1 to Len( aItems )
      DEFINE ROW oRow OF oList
         @ 5, 10 SAY aItems[n] OF oRow SIZE 200, 20
         @ 5, 250 BUTTON "Info" OF oRow SIZE 60, 22 ACTION MsgInfo( "Has pulsado en " + aItems[n] )
   next

   // Botón para consultar el estado desde Harbour
   @ 420, 20 BUTTON oBtn PROMPT "Consultar Selección" OF oWnd SIZE 180, 30 ;
      ACTION MsgInfo( "ID: " + hb_ValToStr( oList:cSelectedId ) + CRLF + ;
                     "Index: " + hb_ValToStr( oList:SelectedIndex ), "Estado de la Lista" )

   @ 420, 220 BUTTON "Limpiar Lista" OF oWnd SIZE 140, 30 ;
      ACTION oList:Clear()

   ACTIVATE WINDOW oWnd CENTER

return nil
