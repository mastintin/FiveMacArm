#include "swfive.ch"

function Main()
   // Arrancamos el motor de Swift indicando la función de entrada
   HSW_START_SWIFT( "AppMain" )
return nil

// -------------------------------------------------------------------------------- //

function AppMain()
   local oWnd, oQl, oBtn

   DEFINE WINDOW oWnd TITLE "SwiftUI QuickLook & GetFile Demo" SIZE 1000, 800

   // Contenedor superior para el botón
   @ 20, 20 BUTTON oBtn PROMPT "📂 Cargar Archivo (Swift Native)" ;
      SIZE 250, 40 ;
      OF oWnd ;
      ACTION {|| SelectAndLoad( oQl ) }

   @ 20, 300 SLIDER oSld VAR 1.0 RANGE 0.5, 3.0 ;
      SIZE 300, 30 ;
      OF oWnd ;
      PROMPT "Zoom" ;
      ACTION {|n| oQl:nZoom := n }

   // El visor de QuickLook
   @ 80, 10 QUICKLOOK oQl ;
      FILE "" ;
      SIZE 980, 710 ;
      OF oWnd ;
      AUTORESIZE AnchoMovil + AltoMovil

   ACTIVATE WINDOW oWnd CENTER

return nil

// -------------------------------------------------------------------------------- //

function SelectAndLoad( oQl )
   local cFile := GetFile( "Seleccione un archivo para previsualizar", "pdf,jpg,png,txt,zip,xlsx,xls,docx,doc,pptx", "Cargar" )

   if ! Empty( cFile )
      // Actualizamos la propiedad reactiva del control Swift
      oQl:FileName := cFile
   endif

return nil
