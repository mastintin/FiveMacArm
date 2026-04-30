#include "SwFive.ch"

function Main()
   HSW_START_SWIFT( "AppMain" )
return nil

function AppMain()
   local oWnd
   local aFrutas := { "Manzana", "Pera", "Plátano", "Fresa", "Naranja", "Kiwi", "Melón" }
   local cSelected
   
   DEFINE WINDOW oWnd TITLE "Test MsgList HSW" SIZE 400, 300
   
   @ 50, 50 BUTTON "Seleccionar Fruta" SIZE 200, 40 OF oWnd ;
      ACTION ( cSelected := MsgList( aFrutas, "Elija su fruta favorita" ), ;
               if( !Empty( cSelected ), MsgInfo( "Has elegido: " + cSelected ), MsgAlert( "No has elegido nada" ) ) )

   @ 120, 50 BUTTON "Lista de Números" SIZE 200, 40 OF oWnd ;
      ACTION ( cSelected := MsgList( { 1, 2, 3, 4, 5, 10, 20, 50, 100 }, "Elija un número" ), ;
               MsgInfo( "Número seleccionado: " + hb_ValToStr( cSelected ) ) )

   ACTIVATE WINDOW oWnd CENTER
   
return nil
