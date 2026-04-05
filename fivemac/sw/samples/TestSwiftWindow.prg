#include "FiveMac.ch"
#include "SwiftControls.ch"

function Main()
   local oWnd, oBtn0, oBtn1, oBtn2
   
   oWnd := TSwWindow():New( "Ventana Sw (Pure SwiftUI)", 600, 400 )
   
   oBtn0 := TSwButton():New( 0, 0, 150, 40, "ESQUINA 0,0", oWnd, {|| MsgInfo( "0,0!" ) } )
   
   oBtn1 := TSwButton():New( 50, 50, 150, 40, "Pure Swift 1", oWnd, ;
      { || MsgInfo( "Hola 1" ) } )
      
   oBtn2 := TSwButton():New( 150, 200, 180, 45, "Pure Swift 2", oWnd, ;
      { || MsgInfo( "Hola 2" ) } )

   ACTIVATE WINDOW oWnd
return nil
