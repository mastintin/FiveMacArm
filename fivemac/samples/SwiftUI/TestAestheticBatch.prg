#include "FiveMac.ch"

function Main()

    local oWnd, oList, aIds
    local nColor := nRgba( 125,125,125, 125)
    Local nColor2:=  nRgb(125,125,125)
    Local nColor3:= nRgba( 125,125,125,255)

    Local alfa := GetAlphaFromRgba( nColor )   

    Local calculo := nColor -( alfa* 256^3)
    
  
       

    DEFINE WINDOW oWnd TITLE "SwiftUI Aesthetic Batch Test" ;
        SIZE 400, 600


   msginfo( nColor)
     msginfo( nColor2)
     msginfo( nColor3)
     msginfo( "alfa"+str(alfa ))
     msginfo( Calculo ) 
     


    oList := TSwiftList():New( 10, 10, 380, 500, oWnd )
   
    // Test individual aesthetic items in a batch
    oList:AddItem( 0, "Default Text" )
    oList:AddItem( 0, "Red Text", nil, nil, CLR_RED )
    oList:AddItem( 0, "Blue Background Text", nil, nil, CLR_WHITE, CLR_BLUE )
   
    oList:AddItem( 9, "Default Button", {|| MsgInfo( "Default" ) } )
    oList:AddItem( 9, "Green Button", {|| MsgInfo( "Green" ) }, nil, CLR_WHITE, CLR_GREEN )
    oList:AddItem( 9, "Yellow/Black Button", {|| MsgInfo( "Yellow" ) }, nil, CLR_BLACK, CLR_YELLOW )
   
    // NEW: Alpha support testing
    oList:AddItem( 9, "Blue 50% Alpha", {|| MsgInfo( "50% Alpha" ) }, nil, CLR_WHITE, nColor, 1.0, 0.5 )
    oList:AddItem( 0, "Green Text 30% Alpha", nil, nil, CLR_GREEN, nil, 0.3 )
   
    aIds := oList:AddBatch()

    @ 520, 150 BUTTON "Close" SIZE 100, 30 OF oWnd ACTION oWnd:End()

    ACTIVATE WINDOW oWnd CENTERED

return nil


Function nRgba(r,g,b,a)
  Return ((a * 256^3) + (r * 256^2) + (g * 256^1) + (b * 256^0))

FUNCTION GetAlphaFromRgba( nDecimal )  
RETURN Int( nDecimal / 16777216 )