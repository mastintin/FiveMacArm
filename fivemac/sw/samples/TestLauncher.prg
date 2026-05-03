#include "swfive.ch"

function Main()
   HSW_START_SWIFT( "AppMain" )
return nil

function AppMain()
    local oWnd, oBtn
    
    DEFINE WINDOW oWnd TITLE "Launcher Window" SIZE 400, 300
    
    @ 100, 100 BUTTON oBtn PROMPT "Abrir Ventana Navegación" OF oWnd ;
       ACTION AbrirNavegacion() SIZE 200, 40
    
    ACTIVATE WINDOW oWnd CENTERED
    
return nil

function AbrirNavegacion()
    local oNav
    
    MsgInfo( "Abriendo ventana especializada..." )
    
    DEFINE NAVWINDOW oNav TITLE "Gestión Fivemac" SIZE 1000, 700
    
    oNav:AddItem( "dash",     "Dashboard", "gauge",    "Principal" )
    oNav:AddItem( "users",    "Usuarios",  "person.2", "Principal" )
    oNav:AddItem( "settings", "Ajustes",   "gear",     "Sistema" )
    
    oNav:selectedId := "dash"
    
    ACTIVATE WINDOW oNav CENTERED
    
return nil
