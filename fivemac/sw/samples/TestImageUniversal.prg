#include "swfive.ch"
#include "SwFive.ch"

function Main()
   local oWnd, oImg
   local cUrl := "https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png"
   
   DEFINE WINDOW oWnd TITLE "La Isla: Imagen Universal" SIZE 600, 500
   
   @ 20, 20 SAY "Probando los 3 orígenes en un solo objeto:" SIZE 400, 20 OF oWnd
   
   // Empezamos con un Symbol
   @ 60, 20 IMAGE oImg SYMBOL "globe.europe.africa.fill" SIZE 200, 200 OF oWnd
   oImg:SetColor( CLR_BLUE )
   
   @ 280, 20 BUTTON "PONER SF SYMBOL" ;
             ACTION ( oImg:cSymbol := "star.fill", oImg:nColor := CLR_YELLOW ) ;
             SIZE 180, 30 OF oWnd

   @ 320, 20 BUTTON "CARGAR DE INTERNET" ;
             ACTION ( oImg:cUrl := cUrl ) ;
             SIZE 180, 30 OF oWnd

   @ 360, 20 BUTTON "FORZAR ERROR (FILE)" ;
             ACTION ( oImg:cFile := "/non/existent/path.png" ) ;
             SIZE 180, 30 OF oWnd

   @ 400, 20 SAY "Nota: La descarga de internet es asíncrona." SIZE 400, 20 OF oWnd
   @ 420, 20 SAY "El objeto oImg muta su origen dinámicamente." SIZE 400, 20 OF oWnd

   ACTIVATE WINDOW oWnd CENTER
   
return nil
