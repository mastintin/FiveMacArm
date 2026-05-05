#include "swfive.ch"

function Main()
    HSW_START_SWIFT( "AppMain" )
return nil

function AppMain()
    local oNav, oPanel, oBtn
    
    DEFINE NAVWINDOW oNav TITLE "Test Simple" SIZE 800, 600
    
    @ 0, 0 PANEL oPanel ID "dash" OF oNav
       @ 50, 50 BUTTON "Click Me" OF oPanel
    
    ACTIVATE WINDOW oNav CENTERED
return nil
