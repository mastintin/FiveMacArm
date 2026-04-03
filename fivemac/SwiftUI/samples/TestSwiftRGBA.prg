#include "FiveMac.ch"
#include "SwiftControls.ch"

function Main()
    local oWnd, oToggle, oSlider, oBtnAcc, oBtnText, oBtn
    local lVal := .T., nVal := 50

    DEFINE WINDOW oWnd TITLE "Test Arquitectura RGBA SwiftUI" SIZE 500, 400 NOFLIPPED

    // --- TEST TOGGLE ---
    @ 20, 20 SWIFTTOGGLE oToggle VAR lVal PROMPT "Test Alpha Toggle" SIZE 250, 40 OF oWnd SWITCH .T.

    @ 70, 20 SWIFTBUTTON "Acento Rojo (Alpha 128)" SIZE 200, 30 OF oWnd ;
        ACTION { || oToggle:nClrAcc := CLR_RED, oToggle:nAlphaAcc := 128 }

    @ 110, 20 SWIFTBUTTON "Texto Verde (Alpha 255)" SIZE 200, 30 OF oWnd ;
        ACTION { || oToggle:SetTextColor( CLR_GREEN, 255 ) }


    // --- TEST SLIDER ---
    @ 180, 20 SWIFTSLIDER oSlider VAR nVal SIZE 350, 40 OF oWnd ;
        SHOWVALUE .T.

    @ 240, 20 SWIFTBUTTON "Slider Acento Azul (Alpha 100)" SIZE 220, 30 OF oWnd ;
        ACTION { || oSlider:SetAccentColor( CLR_BLUE, 100 ) }

    @ 280, 20 SWIFTBUTTON "Slider Texto Blanco" SIZE 220, 30 OF oWnd ;
        ACTION { || oSlider:nClrText := CLR_WHITE }

    // --- TEST BUTTON ---
    @ 330, 20 SWIFTBUTTON oBtn PROMPT "Botón Camaleón" SIZE 220, 35 OF oWnd ;
        ACTION { || oBtn:SetAccentColor( CLR_YELLOW, 150 ), oBtn:SetTextColor( CLR_BLACK, 255 ) }

    ACTIVATE WINDOW oWnd
return nil
