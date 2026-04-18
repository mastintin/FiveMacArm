#include "FiveMac.ch"

FUNCTION Main()
   local oWnd, oBtn, oStack
   
   DEFINE WINDOW oWnd TITLE "Test ActionStack Universal" ;
          FROM 100, 100 TO 500, 600
   
   @ 100, 100 BUTTON oBtn PROMPT "Botón de Prueba" OF oWnd
   
   ACTIVATE WINDOW oWnd ON INIT ( TestUniversal( oBtn ) )
   
return nil

FUNCTION TestUniversal( oBtn )
   local oStack := TSwActionStack():New()
   
   SW_LOG( ">>> Iniciando Grabación Universal <<<" )
   
   oStack:Begin()
      
      // 1. Llamada a método (Captura automática via OnError/AddControlCall)
      oBtn:SetText( "Cambiado por Stack!" )
      
      // 2. Asignación de propiedad (Captura automática via SD:Apply interceptado)
      oBtn:nTop  := 200
      oBtn:nLeft := 200
      
      // 3. Llamada directa al dispatcher global
      SD:Alert( "Esta alerta viajará dentro del stack" )
      
   oStack:End()
   
   SW_LOG( ">>> Grabación finalizada. Ejecutando Lote... <<<" )
   
   oStack:Execute()
   
return nil
