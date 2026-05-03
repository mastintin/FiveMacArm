#include "swfive.ch"

static oDash, oSettings, oUserView

function Main()
    HSW_START_SWIFT( "AppMain" )
return nil

function AppMain()
    local oWnd, oSbr
    
    DEFINE NAVWINDOW oWnd TITLE "Fivemac SW: Specialized Navigation" SIZE 1000, 700
    
    /* 
    // --- SIDEBAR ---
    DEFINE SIDEBAR oSbr OF oWnd 
       
       NAVSECTION "APP" OF oSbr
          NAVITEM "Dashboard" ICON "chart.bar.fill"    ID "dash" OF oSbr
          NAVITEM "Reports"   ICON "doc.append.fill"   ID "rpt"  OF oSbr
       
       NAVSECTION "PREFERENCES" OF oSbr
          NAVITEM "Settings"  ICON "gearshape.fill"    ID "cfg"  OF oSbr
          NAVITEM "Profile"   ICON "person.fill"       ID "user" OF oSbr
       
       NAVSECTION "SYSTEM" OF oSbr
          NAVITEM "Logout"    ICON "power"             ID "exit" OF oSbr
       
       // Gestión de la navegación centralizada
       oSbr:bAction := { | cId | DoNavigation( cId, oWnd ) }
       
    // --- CONTENIDO DEL AREA DE DETALLE (Diferentes Vistas) ---
    
    // Vista 1: Dashboard
    @ 20, 20 VSTACK oDash OF oWnd SIZE 600, 500
       @ 0, 0 SAY "DASHBOARD" SIZE 200, 40 OF oDash
       @ 50, 0 GAUGE VALUE 75 PROMPT "System Performance" STYLE SW_GAUGE_CIRCULAR SIZE 150, 150 OF oDash
       @ 220, 0 BUTTON "Quick Export" SIZE 120, 30 OF oDash ACTION MsgInfo("Exporting...")
    
    // Vista 2: Settings
    @ 20, 20 VSTACK oSettings OF oWnd SIZE 600, 500
       @ 0, 0 SAY "SETTINGS" SIZE 200, 40 OF oSettings
       @ 50, 0 TOGGLE VALUE .t. PROMPT "Dark Mode" STYLE SW_TOGGLE_SWITCH OF oSettings
       @ 90, 0 TOGGLE VALUE .f. PROMPT "Notifications" STYLE SW_TOGGLE_SWITCH OF oSettings
    oSettings:Hide() // Oculta por defecto
    
    // Vista 3: Profile
    @ 20, 20 VSTACK oUserView OF oWnd SIZE 600, 500
       @ 0, 0 SAY "USER PROFILE" SIZE 200, 40 OF oUserView
       @ 50, 0 IMAGE SYMBOL "person.crop.circle.fill" SIZE 100, 100 OF oUserView
       @ 160, 0 SAY "User: Administrator" OF oUserView
    oUserView:Hide() // Oculta por defecto
    */
        
    ACTIVATE WINDOW oWnd CENTERED
return nil

// Lógica de cambio de vista
function DoNavigation( cId, oWnd )
    
    // 1. Acciones especiales
    if cId == "exit"
       if MsgYesNo( "Do you want to exit?" )
          oWnd:End()
       endif
       return nil
    endif
    
    if cId == "rpt"
       CreateMyReport()
       return nil
    endif

    // 2. Cambio de Vistas (Visual Stack Switching)
    oDash:Hide()
    oSettings:Hide()
    oUserView:Hide()
    
    do case
       case cId == "dash" ; oDash:Show()
       case cId == "cfg"  ; oSettings:Show()
       case cId == "user" ; oUserView:Show()
    endcase
    
return nil

function CreateMyReport()
    local oRpt := TSwReport():New( "Sidebar Navigation Report" )
    oRpt:AddHeader( "Navigation Log", ".blue", "list.bullet.rectangle.portrait" )
    oRpt:AddText( "The user requested a report from the sidebar at " + Time(), 14 )
    oRpt:AddDivider()
    oRpt:AddTable( {"Event", "Status"}, { {"Navigated to Reports", "Success"}, {"System Active", "OK"} } )
    oRpt:Show()
return nil
