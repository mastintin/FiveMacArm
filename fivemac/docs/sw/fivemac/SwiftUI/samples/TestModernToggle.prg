#include "FiveMac.ch"

function Main()

   local oWnd, oTgl1, oTgl2, oTgl3

   DEFINE WINDOW oWnd TITLE "SwiftUI Modern Toggle Test" ;
      SIZE 400, 400

   oTgl1 := TSwiftToggle():New( 300, 50, 200, 30, "Checkbox Standard", .F., .F., oWnd, { |lOn| MsgInfo( "Tgl1 is " + iif( lOn, "ON", "OFF" ) ) } )

   oTgl2 := TSwiftToggle():New( 250, 50, 200, 30, "Switch Style (iOS)", .F., .T., oWnd, { |lOn| MsgInfo( "Tgl2 is " + iif( lOn, "ON", "OFF" ) ) } )
   oTgl2:SetAccentColor( "orange" )

   oTgl3 := TSwiftToggle():New( 200, 50, 200, 30, "Purple Custom", .F., .T., oWnd )
   oTgl3:SetAccentColor( "purple" )
   oTgl3:SetTextColor( "blue" )

   @ 50, 150 BUTTON "Close" SIZE 100, 30 OF oWnd ACTION oWnd:End()

   ACTIVATE WINDOW oWnd CENTERED

return nil
