#include "FiveMac.ch"
#include "SwiftControls.ch"

//----------------------------------------------------------------------------//

function Main()

   local oWnd, oDate1, oDate2, oLabel

   SET DATE TO BRITISH
   SET CENTURY ON

   DEFINE WINDOW oWnd TITLE "SwiftUI DatePicker Demo"  NOFLIPPED ;
      FROM 100, 100 TO 500, 650

   @ 30, 30 SWIFTLABEL "Fecha estándar (Stepper):" OF oWnd SIZE 300, 20
   
   @ 60, 30 SWIFTDATEPICKER oDate1 dDATE Date() OF oWnd SIZE 150, 25 ;
      ON CHANGE MsgInfo( "Fecha 1: " + DToC( oDate1:GetDate() ), "Información" )

   @ 110, 30 SWIFTLABEL "DatePicker con título y colores:" OF oWnd SIZE 300, 20

   @ 140, 30 SWIFTDATEPICKER oDate2 dDATE Date() OF oWnd SIZE 250, 25 ;
      TITLE "Nacimiento" ;
      ON CHANGE ( oLabel:SetText( "Selección: " + DToC( oDate2:GetDate() ) ) )

   oDate2:SetColor( CLR_HRED, CLR_BLACK )

   @ 200, 30 SWIFTLABEL oLabel PROMPT "Esperando cambios..." OF oWnd SIZE 300, 25
   oLabel:SetFont( 16 )

   @ 300, 30  BUTTON "Valor Fecha 2" OF oWnd SIZE 150, 30 ACTION MsgInfo( DToC( oDate2:GetDate() ) )
   @ 300, 200 BUTTON "Hoy en Fecha 1" OF oWnd SIZE 150, 30 ACTION oDate1:SetDate( Date() )

   ACTIVATE WINDOW oWnd CENTERED

return nil

//----------------------------------------------------------------------------//
