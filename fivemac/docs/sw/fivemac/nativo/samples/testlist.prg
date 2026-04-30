#include "FiveMac.ch"

//----------------------------------------------------------------------------//

function Main()

   LOCAL oWnd, oList, oSearch, cSearch := ""
   local aNombres := { "Manuel Expoito", "Antonio Linares", "Carlos Vargas", "Daniel Garcia", "Zacarias Gomez" }
   
   DEFINE WINDOW oWnd ;
      TITLE "Prueba de ListBox y MsgSelectList" ;
      FROM 100, 100 TO 500, 650
      
   @ 360, 20 SAY " Standalone Listbox with Live Search " SIZE 300, 25 OF oWnd
   
   @ 330, 20 GET oSearch VAR cSearch SIZE 400, 24 OF oWnd SEARCH 
   oSearch:cCueText := "Escriba para filtrar la lista..."

   @ 60, 20 LISTBOX oList ITEMS { "Mercedes", "Ferrari", "Red Bull", "Aston Martin", "Alpine", "McLaren", "Williams", "Haas", "Toro Rosso", "Sauber" } ;
      SIZE 400, 260 OF oWnd ;
      ACTION MsgInfo( oList:Value() )

   oList:SetSearch( oSearch )
   
   @ 20, 20 BUTTON "Probar MsgSelectList" SIZE 180, 30 OF oWnd ;
      ACTION MsgInfo( "Resultado: " + Str( MsgSelectList( "Seleccione Escudería", { "Red Bull", "Mercedes", "Ferrari", "Aston Martin" } ) ) )

   ACTIVATE WINDOW oWnd CENTERED

return nil
