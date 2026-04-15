#include "FiveMac.ch"

// -------------------------------------------------------------------------- //
// Test de Action Stacking (Pila de Acciones)
// Demostración de cómo enviar múltiples comandos de UI en un solo lote.
// -------------------------------------------------------------------------- //

function Main()
   local oWnd, oBtn1, oBtn2, oBtnBatch, oLabel, oStack
   
   oWnd := TSwWindow():New( "Test Action Stacking - Swift", 600, 500 )
   
   // Etiqueta de título
   oLabel := TSwLabel():New( 50, 100, 400, 30, "LISTO PARA LA ACCIÓN MÚLTIPLE", oWnd )

   // Botones que se moverán
   oBtn1 := TSwButton():New( 150, 100, 180, 40, "ESTÁTICO A", oWnd )
   oBtn2 := TSwButton():New( 150, 320, 180, 40, "ESTÁTICO B", oWnd )

   // Botón disparador del Batch
   oBtnBatch := TSwButton():New( 350, 200, 200, 50, "¡LANZAR BATCH!", oWnd, ;
      { || ;
         oStack := TSwActionStack():New(), ;
         oStack:AddUpdate( oLabel, "¡EXPLOSIÓN VISUAL COMPLETADA!" ), ;
         oStack:AddColor( oLabel, 255, 20, 20 ), ;
         oStack:AddMove( oBtn1, 250, 50 ), ;
         oStack:AddMove( oBtn2, 250, 370 ), ;
         oStack:Execute(), ;
         SwMsgInfo( "Harbour: Pila de acciones enviada a Swift. Todo debería haber cambiado de golpe." ) ;
      } )

   ACTIVATE WINDOW oWnd CENTERED
   
return nil
