#include "fivemac.ch"
#include "swfive.ch"

function Main()

   local oWnd, oSay, oGet1, oGet2
   local cName := "manuel exposito"
   local nImport := 1234.56

   DEFINE SWWINDOW oWnd TITLE "FiveMac - Test de Pictures Síncronas" ;
      SIZE 600, 450

      @ 30, 40 SWLABEL "Nombre (@!):" OF oWnd SIZE 120, 20
      @ 30, 160 SWGET oGet1 VAR cName OF oWnd SIZE 300, 30 ;
          PICTURE "@!" ;
          ACTION ( oSay:SetText( "Nombre actualizado (mayúsculas): " + cName ) )

      @ 80, 40 SWLABEL "Importe (@E):" OF oWnd SIZE 120, 20
      @ 80, 160 SWGET oGet2 VAR nImport OF oWnd SIZE 150, 30 ;
          PICTURE "@E 99,999.99" ;
          ACTION ( oSay:SetText( "Importe actualizado: " + Transform( nImport, "@E 99,999.99" ) ) )

      @ 150, 40 SWLABEL oSay PROMPT "Esperando interacción con la Isla..." OF oWnd SIZE 400, 25

      @ 220, 160 SWBUTTON "Limpiar Datos" OF oWnd ;
          ACTION ( cName := "", nImport := 0, oGet1:SetText(""), oGet2:SetText("0"), oSay:SetText( "Campos reseteados" ) ) ;
          SIZE 150, 40

      @ 220, 320 SWBUTTON "Cerrar" OF oWnd ;
          ACTION ( oWnd:Close() ) ;
          SIZE 100, 40

   ACTIVATE SWWINDOW oWnd

return nil
