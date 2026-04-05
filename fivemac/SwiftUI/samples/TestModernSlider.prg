#include "FiveMac.ch"
#include "SwiftControls.ch"

function Main()

   local oWnd, oSld1, oSld2, oSld3, oSay

   DEFINE WINDOW oWnd TITLE "SwiftUI Modern Slider Test" ;
      SIZE 450, 500

   @ 400, 50 SWIFTSLIDER oSld1 VAR 50 ;
      OF oWnd SIZE 300, 60 ;
      SHOWVALUE .T. ;
      ON CHANGE { |n| oSay:SetText( "Val1: " + AllTrim(Str(n)) ) }

   oSld1:SetAccentColor( "orange" )

   @ 320, 50 SWIFTSLIDER oSld2 VAR 20 ;
      OF oWnd SIZE 300, 80 ;
      GLASS .T. ;
      ON CHANGE { |n| oSay:SetText( "Val2: " + AllTrim(Str(n)) ) }
   
   oSld2:SetAccentColor( "purple" )

   @ 220, 50 SWIFTSLIDER oSld3 VAR 80 ;
      OF oWnd SIZE 300, 60 ;
      ON CHANGE { |n| oSay:SetText( "Val3: " + AllTrim(Str(n)) ) }

   oSld3:SetAccentColor( "mint" )
   oSld3:SetTextColor( "red" )

   @ 150, 50 SWIFTSAY oSay PROMPT "Value: 0" OF oWnd SIZE 300, 30

   @ 50, 150 BUTTON "Close" SIZE 100, 30 OF oWnd ACTION oWnd:End()

   ACTIVATE WINDOW oWnd CENTERED

return nil
