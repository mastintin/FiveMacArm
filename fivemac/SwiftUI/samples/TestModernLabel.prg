#include "FiveMac.ch"
#include "SwiftControls.ch"

function Main()

   local oWnd, oLbl1, oLbl2, oLbl3, oLbl4

   DEFINE WINDOW oWnd TITLE "SwiftUI Modern Label Test (Flipped Order)" ;
      SIZE 500, 450

   // PRIMERO ARRIBA (Flipped: 0 is top)
   @ 50, 50 SWIFTSAY oLbl1 PROMPT "1. Left Aligned (Top 50)" ;
      OF oWnd SIZE 400, 40 
   
   oLbl1:SetTextColor( "blue" )
   oLbl1:SetFont( 24 )

   @ 120, 50 SWIFTSAY oLbl2 PROMPT "2. Center Aligned Bold (Top 120)" ;
      OF oWnd SIZE 400, 40 
   
   oLbl2:SetAlignment( 1 ) // Center
   oLbl2:SetBold( .T. )
   oLbl2:SetTextColor( "red" )
   oLbl2:SetFont( 20 )

   @ 190, 50 SWIFTSAY oLbl3 PROMPT "3. Right Aligned Orange (Top 190)" ;
      OF oWnd SIZE 400, 40 
   
   oLbl3:SetAlignment( 2 ) // Right
   oLbl3:SetTextColor( "orange" )
   oLbl3:SetFont( 18 )

   @ 260, 50 SWIFTSAY oLbl4 PROMPT "4. Label with Mint Background (Top 260)" ;
      OF oWnd SIZE 400, 40
   
   oLbl4:SetAccentColor( "mint" )
   oLbl4:SetTextColor( "white" )
   oLbl4:SetAlignment( 1 )
   oLbl4:SetBold( .T. )

   @ 380, 200 BUTTON "Close" SIZE 100, 30 OF oWnd ACTION oWnd:End()

   ACTIVATE WINDOW oWnd CENTERED

return nil
