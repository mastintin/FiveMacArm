#include "swfive.ch"
 
 function Main()
    HSW_START_SWIFT( "AppMain" )
 return nil
 
 function AppMain()
 
    local oWnd, oPkr1, oPkr2, oPkr3
    local aItems := { "Apple", "Orange", "Banana", "Strawberry", "Pineapple" }
 
    DEFINE WINDOW oWnd TITLE "SwiftUI Picker Test" SIZE 400, 500
 
    @ 20, 20 SAY "Modern SwiftUI Pickers" OF oWnd SIZE 300, 30
 
    // Style 0: Menu (Default)
    @ 60, 20 PICKER oPkr1 ITEMS aItems OF oWnd SIZE 300, 44 ;
       PROMPT "Fruit Selector (Menu):" ;
       ON CHANGE MsgInfo( "Selected: " + cVal )
 
    // Style 1: Segmented
    @ 140, 20 PICKER oPkr2 ITEMS { "Daily", "Weekly", "Monthly" } OF oWnd SIZE 300, 44 ;
       PROMPT "View Mode (Segmented):" STYLE 1 ;
       ON CHANGE oWnd:SetTitle( "View: " + cVal )
 
    // Style 2: Radio Group
    @ 250, 20 PICKER oPkr3 ITEMS { "Easy", "Normal", "Hard" } OF oWnd SIZE 300, 100 ;
       PROMPT "Difficulty (Radio):" STYLE 2
 
    ACTIVATE WINDOW oWnd CENTERED
 
 return nil
