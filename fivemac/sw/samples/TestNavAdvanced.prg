#include "swfive.ch"

function Main()
   HSW_START_SWIFT( "AppMain" )
return nil

function AppMain()
    AbrirNavegacionAvanzada()
return nil

function AbrirNavegacionAvanzada()
    local oNav, oPanel
    local oGauge, oList, oRow
    local lCheck := .T., nVal := 50

    oNav := TSwNavWindow():New( "Fivemac ERP", 1100, 800 )

    oNav:AddItem( "dash",    "Dashboard", "gauge" )
    oNav:AddItem( "sales_module",   "Ventas",    "cart" )
    oNav:AddItem( "users",   "Usuarios",  "person.3" )
    oNav:AddItem( "reports", "Informes",  "chart.bar" )
    oNav:AddItem( "settings","Ajustes",   "gear" )

    oNav:bOnChange := { | cId | MsgInfo( "Seleccionado en Sidebar: " + cId ) }

    // --- Panel para Dashboard ---
    @ 0, 0 PANEL oPanel ID "dash" OF oNav
       @ 50, 50 GAUGE oGauge VALUE 75 RANGE 0, 100 OF oPanel SIZE 300, 300 PROMPT "Ventas del Mes"

    // --- Módulo de Ventas ---
    @ 0, 0 LIST oList ID "sales_module" OF oNav SIZE 350, 800
       
       DEFINE ROW oRow OF oList ID "fact_001"
          oRow:nHeight := 40
          @ 5, 10 SAY "Factura #001 - M. Calero" OF oRow

       DEFINE ROW oRow OF oList ID "fact_002"
          oRow:nHeight := 40
          @ 5, 10 SAY "Factura #002 - M. Gomez" OF oRow

       DEFINE ROW oRow OF oList ID "fact_003"
          oRow:nHeight := 40
          @ 5, 10 SAY "Factura #003 - J. Smith" OF oRow

       // Importante: Redirigimos al panel de detalle correspondiente
       oList:bAction := { | cId | oNav:SetContent( "detail_" + cId ) }

    // --- Módulo de Usuarios ---
    @ 0, 0 PANEL oPanel ID "users" OF oNav
       @ 20, 20 SAY "Gestión de Usuarios" OF oPanel
       @ 60, 20 IMAGE FILE "person.2.fill" OF oPanel SIZE 100, 100
       @ 180, 20 TOGGLE lCheck PROMPT "Usuario Activo" STYLE SW_TOGGLE_CHECKBOX OF oPanel
       @ 220, 20 SLIDER nVal RANGE 0, 100 OF oPanel SIZE 200, 20 PROMPT "Nivel de Acceso"

       @ 260, 20 BUTTON "Nuevo Usuario" OF oPanel SIZE 150, 40 ACTION MsgInfo( "Formulario de nuevo usuario" )

    // --- Módulo de Informes ---
    @ 0, 0 PANEL oPanel ID "reports" OF oNav
       @ 20, 20 SAY "Módulo de Informes" OF oPanel
       @ 60, 20 BUTTON "Ver Detalle Informe" OF oPanel ACTION oNav:Push( "report_detail" ) SIZE 250, 40

    // --- Vista Detalle ---
    @ 0, 0 PANEL oPanel ID "report_detail" OF oNav
       @ 20, 20 BUTTON " < Volver" OF oPanel SIZE 100, 30 ACTION oNav:Pop()
       @ 60, 20 SAY "Detalle Extendido" OF oPanel
       @ 100, 20 IMAGE FILE "chart.pie.fill" OF oPanel SIZE 400, 300

    // --- PANELES DE DETALLE (IDs únicos para no chocar con las filas) ---
    
    @ 0, 0 PANEL oPanel ID "detail_fact_001" OF oNav
       @ 20, 20 SAY "DETALLE DE FACTURA #001" OF oPanel
       @ 60, 20 IMAGE FILE "doc.text.fill" OF oPanel SIZE 100, 100
       @ 180, 20 SAY "Cliente: Manuel Calero" OF oPanel
       @ 210, 20 SAY "Importe: $1,250.00" OF oPanel
       @ 250, 20 BUTTON "Imprimir" OF oPanel ACTION MsgInfo( "Imprimiendo #001..." ) SIZE 150, 40

    @ 0, 0 PANEL oPanel ID "detail_fact_002" OF oNav
       @ 20, 20 SAY "DETALLE DE FACTURA #002" OF oPanel
       @ 60, 20 IMAGE FILE "doc.text.fill" OF oPanel SIZE 100, 100
       @ 180, 20 SAY "Cliente: Marina Gomez" OF oPanel
       @ 210, 20 SAY "Importe: $890.00" OF oPanel

    oNav:Activate( .F. )
return nil
