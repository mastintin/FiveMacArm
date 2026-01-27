#include "FiveMac.ch"

#include "Nice.prg" 

function Main()

    local oWnd, oPanel, oPage, oCard, oRow, oInput
    local oBtn1, oBtn2

    DEFINE WINDOW oWnd TITLE "Hybrid App: Native + NiceGUI" SIZE 900, 600 FLIPPED

    // -----------------------------------------------------------------------
    // 1. Parte NATIVA (FiveMac puro)
    // -----------------------------------------------------------------------
    @ 30, 30 SAY "Esto es un texto nativo de Mac (Cocoa)" OF oWnd SIZE 300, 20
   
    @ 60, 30 BUTTON "Soy un Botón Nativo" OF oWnd SIZE 180, 40 ;
        ACTION MsgInfo( "Hola desde el mundo nativo!" )

    // -----------------------------------------------------------------------
    // 2. Parte WEB / NICEGUI (Incrustada en un Panel)
    // -----------------------------------------------------------------------
   
    // Creamos un Panel nativo que alojará la interfaz web
    oPanel := TPanel():New( 120, 30, 840, 450, oWnd )
   
    // Creamos la página NiceGUI DENTRO del panel
    oPage := TNicePage():New( oPanel )

    // --- Construimos la UI con objetos Nice ---
   
    oCard := TNiceCard():New( oPage ) // Tarjeta centrada

    // Input Reactivo
    oInput := TNiceInput():New( oCard, "Tu Nombre", "Amigo" )

    oRow := TNiceHStack():New( oCard ) // Stack Horizontal

    oBtn1 := TNiceButton():New( oRow, "Saludar", { || MsgInfo( "Hola " + oInput:cValue + "!" ) } )
   
    oBtn2 := TNiceButton():New( oRow, "Salir", { || oWnd:End() } )

    // -----------------------------------------------------------------------

    oPage:Activate()

    ACTIVATE WINDOW oWnd CENTERED

return nil
