#include "SwFive.ch"

//----------------------------------------------------------------------------//

function Main()

   local oWnd, oNet
   local oLbl1, oLbl2, oLbl3
   local oBtn
   
   DEFINE WINDOW oWnd TITLE "Test Network Reactivo 2.0" ;
          SIZE 500, 400

      @ 20, 20 LABEL oLbl1 PROMPT "Esperando Google..." OF oWnd SIZE 400, 25
      @ 50, 20 LABEL oLbl2 PROMPT "Esperando GitHub..." OF oWnd SIZE 400, 25
      @ 80, 20 LABEL oLbl3 PROMPT "Esperando Coche..." OF oWnd SIZE 400, 25

      @ 120, 20 BUTTON oBtn PROMPT "Lanzar Peticiones Simultáneas" OF oWnd ;
         ACTION ( oBtn:Disable(), ;
                  LanzarTest( oLbl1, oLbl2, oLbl3, oBtn ) )

   ACTIVATE WINDOW oWnd CENTER
   
return nil

//----------------------------------------------------------------------------//

function LanzarTest( oLbl1, oLbl2, oLbl3, oBtn )

   local oNet := TSwNetwork():New()

   // Petición 1: Google
   oLbl1:SetText( "Cargando Google..." )
   oNet:Get( "https://www.google.com", { |res| oLbl1:SetText( "Google OK: " + Str( Len( res ) ) + " bytes" ) } )

   // Petición 2: GitHub
   oLbl2:SetText( "Cargando GitHub..." )
   oNet:Get( "https://www.github.com", { |res| oLbl2:SetText( "GitHub OK: " + Str( Len( res ) ) + " bytes" ) } )

   // Petición 3: Una imagen (como texto para el test)
   oLbl3:SetText( "Cargando Apple..." )
   oNet:Get( "https://www.apple.com", { |res| oLbl3:SetText( "Apple OK: " + Str( Len( res ) ) + " bytes" ), oBtn:Enable() } )

return nil
