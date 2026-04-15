#include "FiveMac.ch"

// -------------------------------------------------------------------------- //
// Test de Invocación Dinámica de Funciones
// Demuestra cómo Harbour puede llamar a CUALQUIER función de Swift por nombre.
// -------------------------------------------------------------------------- //

function Main()
   local oWnd, oBtn, oStack
   
   oWnd := TSwWindow():New( "Test Dynamic Dispatch - Swift", 400, 300 )

   oBtn := TSwButton():New( 120, 100, 200, 50, "LLAMADA DINÁMICA", oWnd, ;
      { || oStack := TSwActionStack():New(), ;
           oStack:AddCall( "alert", { "text" => "¡EXITO! Llamada dinámica por nombre." } ), ;
           oStack:Execute() } )

   ACTIVATE WINDOW oWnd CENTERED
   
return nil
