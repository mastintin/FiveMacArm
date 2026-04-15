#include "FiveMac.ch"

function Main()
   local oWnd, oBtn1, oBtn2
   
   oWnd := TSwWindow():New( "Test Puente Inteligente", 500, 400 )
   
   // En nuestro sistema flipped:
   // - y: 50 es cerca de la parte superior
   // - x: 50 es cerca de la izquierda
   
   // Etiqueta de título
   TSwLabel():New( 50, 50, 400, 30, "DIAGNÓSTICO DE POSICIONAMIENTO ABSOLUTO", oWnd )

   // Botón en el origen (0, 0)
   TSwButton():New( 0, 0, 150, 40, "ORIGEN (0,0)", oWnd, ;
      { || nil } )

   // Misma fila (Y=100), distintas columnas (X=50 y X=250)
   oBtn1 := TSwButton():New( 100, 50, 180, 40, "BOTÓN IZQ", oWnd, ;
      { || nil } )

   oBtn2 := TSwButton():New( 100, 250, 180, 40, "BOTÓN DER", oWnd, ;
      { || nil } )

   ACTIVATE WINDOW oWnd CENTERED
   
return nil
