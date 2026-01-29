#include "FiveMac.ch"
#include "Nice.ch"

function Main()
    local oWnd, oPage, oStepper, oBtns, oSlider
    
    DEFINE WINDOW oWnd TITLE "NiceGUI - Stepper & Slider Demo" SIZE 800, 700 FLIPPED
    
    DEFINE NICE PAGE oPage OF oWnd
    
    DEFINE NICE HEADER oHeader CLASS "bg-primary text-white" OF oPage
    NICE SAY PROMPT "Nuevos Controles: Stepper & Slider" CLASS "text-h6 q-ml-md" OF oHeader
    END NICE HEADER
    
    DEFINE NICE VSTACK oMain CLASS "q-pa-md gap-lg" OF oPage
        
    // 1. SLIDER DEMO
    DEFINE NICE CARD oCard RADIUS 12 CLASS "p-6" OF oMain
    NICE SAY PROMPT "Control de Selección (Slider)" CLASS "text-h6 q-mb-md" OF oCard
    NICE SLIDER oSlider VALUE 50 MIN 0 MAX 100 STEP 5 CLASS "q-mt-lg" OF oCard
    NICE SAY PROMPT "Desliza para ajustar el valor (Step 5)" CLASS "text-caption text-grey q-mt-sm" OF oCard
    END NICE CARD
        
    // 2. STEPPER DEMO
    DEFINE NICE CARD oCard RADIUS 12 CLASS "p-6" OF oMain
    NICE SAY PROMPT "Asistente de Configuración (Stepper)" CLASS "text-h6 q-mb-md" OF oCard
            
    DEFINE NICE STEPPER oStepper VALUE 1 OF oCard
                
    DEFINE NICE STEP STEP 1 TITLE "Bienvenida" ICON "home" OF oStepper
    NICE SAY PROMPT "Bienvenido al asistente. Este es el paso 1." CLASS "text-subtitle1 q-my-md" OF oStepper
    NICE SAY PROMPT "En este framework puedes crear flujos de trabajo complejos de forma sencilla utilizando la sintaxis xBase tradicional combinada con la potencia de Vue y Quasar." OF oStepper
    END NICE STEP
                
    DEFINE NICE STEP STEP 2 TITLE "Configuración" ICON "settings" OF oStepper
    NICE SAY PROMPT "Personaliza tus opciones en este segundo paso." CLASS "text-subtitle1 q-my-md" OF oStepper
    NICE TOGGLE PROMPT "Habilitar notificaciones en tiempo real" VALUE .T. OF oStepper
    NICE GET PROMPT "Nombre del Perfil" VALUE "Mi Configuración" CLASS "q-mt-md" OF oStepper
    END NICE STEP
                
    DEFINE NICE STEP STEP 3 TITLE "Finalizar" ICON "check" OF oStepper
    NICE SAY PROMPT "Todo listo. Haz clic en finalizar para aplicar los cambios." CLASS "text-subtitle1 q-my-md" OF oStepper
    DEFINE NICE HSTACK CLASS "items-center gap-sm" OF oStepper
    NICE ICON NAME "verified" COLOR "positive" OF oStepper
    NICE SAY PROMPT "Estado:" CLASS "text-bold" OF oStepper
    NICE BADGE PROMPT "LISTO PARA PROCESAR" COLOR "positive" OF oStepper
    END NICE HSTACK
    END NICE STEP
                
    END NICE STEPPER
            
    DEFINE NICE HSTACK oBtns CLASS "q-mt-md gap-md justify-end" OF oCard
    NICE BUTTON PROMPT "Anterior" ICON "arrow_back" CLASS "flat" ACTION {|| oStepper:Previous() } OF oBtns
    NICE BUTTON PROMPT "Siguiente" ICON "arrow_forward" ACTION {|| oStepper:Next() } OF oBtns
    END NICE HSTACK
            
    END NICE CARD
        
    END NICE VSTACK
    
    DEFINE NICE FOOTER oFooter CLASS "bg-grey-2 text-grey-9 text-center p-2" OF oPage
    NICE SAY PROMPT "FiveMac NiceGUI Framework 2026 - Control Labs" OF oFooter
    END NICE FOOTER
    
    ACTIVATE NICE PAGE oPage
    
    ACTIVATE WINDOW oWnd CENTERED
    
return nil
