#include "FiveMac.ch"

//----------------------------------------------------------------------------//

function Main()

   local oWnd

   DEFINE WINDOW oWnd TITLE "FiveMac: Banco de Pruebas" SIZE 550, 550

   @ 230, 200 BUTTON "Llamar Ventana 2" OF oWnd SIZE 150, 40 ;
      ACTION Ventana2()

   ACTIVATE WINDOW oWnd CENTERED

return nil

//----------------------------------------------------------------------------//

function Ventana2()

   local oWnd2, oBrw
   local aData := { { "Manuel", 1500, Date() }, ;
                    { "Antonio", 2200, Date() - 1 }, ;
                    { "Carles", 1850, Date() - 2 }, ;
                    { "Linares", 3000, Date() + 5 } }

   DEFINE WINDOW oWnd2 TITLE "Browse y Leaks" SIZE 600, 500

   // Sintaxis de exito del testbrw
   @ 150, 20 BROWSE oBrw OF oWnd2 SIZE 560, 280 ;
      HEADERS "Nombre", "Salario", "Fecha" ;
      COLSIZES 150, 100, 150

   oBrw:SetArray( aData )
   // El truco es usar el parametro 'n' que pasa FiveMac al bLine
   oBrw:bLine = { |n| { aData[n][1], AllTrim( Str( aData[n][2] ) ), DToC( aData[n][3] ) } }

   @ 100, 20 SAY "Clica en los botones para probar Leaks de MsgInfo:" OF oWnd2 SIZE 400, 20

   @ 50, 30 BUTTON "MsgInfo: STRING" OF oWnd2 SIZE 140, 35 ;
      ACTION ( MsgInfo( "Texto de Prueba", "Info" ), oBrw:Refresh() )

   @ 50, 180 BUTTON "MsgInfo: NUMERO" OF oWnd2 SIZE 140, 35 ;
      ACTION ( MsgInfo( 9876.54, "Info" ), oBrw:Refresh() )

   @ 50, 330 BUTTON "MsgInfo: FECHA" OF oWnd2 SIZE 140, 35 ;
      ACTION ( MsgInfo( Date(), "Info" ), oBrw:Refresh() )

   @ 410, 250 BUTTON "Cerrar" OF oWnd2 SIZE 100, 30 ;
      ACTION oWnd2:End()

   ACTIVATE WINDOW oWnd2 CENTERED

return nil

//----------------------------------------------------------------------------//
