#include "swfive.ch"
 
 function Main()
    HSW_START_SWIFT( "AppMain" )
 return nil
 
 function AppMain()
 
    local oWnd, oPkr1, oPkr2, oPkr3, oPkr4
    local aFruits := { "Apple|apple.logo", "Orange|orange", "Banana|leaf", "Strawberry|heart.fill" }
 
    DEFINE WINDOW oWnd TITLE "Fivemac Premium Pickers" SIZE 400, 600
 
    @ 20, 20 SAY "Modern SwiftUI Pickers" OF oWnd SIZE 300, 30
 
    // Style 0: Menu (Default) con Iconos
    @ 60, 20 PICKER oPkr1 ITEMS aFruits OF oWnd SIZE 300, 50 ;
       PROMPT "FRUIT SELECTOR (MENU):" ;
       ON CHANGE MsgInfo( "Selected: " + cVal )
 
    // Style 1: Segmented con Iconos
    @ 140, 20 PICKER oPkr2 ITEMS { "Day|sun.max", "Week|calendar", "Month|calendar.badge.clock" } OF oWnd SIZE 300, 50 ;
       PROMPT "VIEW MODE (SEGMENTED):" STYLE 1 ;
       ON CHANGE oWnd:SetTitle( "View: " + cVal )
 
    // Style 2: Radio Group
    @ 240, 20 PICKER oPkr3 ITEMS { "Easy|gauge.with.needle", "Normal|gauge.with.dots.needle", "Hard|bolt.fill" } OF oWnd SIZE 300, 110 ;
       PROMPT "DIFFICULTY (RADIO):" STYLE 2
 
    // Style 3: Palette (Solo macOS 12+)
    @ 370, 20 PICKER oPkr4 ITEMS { "Red|paintpalette.fill", "Green|paintpalette.fill", "Blue|paintpalette.fill" } OF oWnd SIZE 300, 60 ;
       PROMPT "COLOR THEME (PALETTE):" STYLE 3
 
    ACTIVATE WINDOW oWnd CENTERED
 
 return nil
