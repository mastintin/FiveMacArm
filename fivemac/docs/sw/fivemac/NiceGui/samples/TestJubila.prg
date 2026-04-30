#include "FiveMac.ch"
#include "Nice.ch"

function Main()
    local oWnd, oPage, oMainCol, oBanner, oQuickRow, oCard, oKpiGridCard, oKpiGrid
    local oProg1, oProg2, oProg3
    
    DEFINE WINDOW oWnd TITLE "JubilaPRO - Dashboard Concept" SIZE 1000, 800 FLIPPED
    
    DEFINE NICE PAGE oPage OF oWnd
    
    DEFINE NICE HEADER oHeader CLASS "bg-indigo-900 text-white" OF oPage
    NICE BUTTON PROMPT "" ICON "menu" CLASS "flat round" JS "toggleDrawer()" OF oHeader
    NICE SAY PROMPT "JubilaPRO v2.0" CLASS "text-h6 q-ml-md font-bold" OF oHeader
    END NICE HEADER

    DEFINE NICE DRAWER oSide CLASS "bg-slate-100" OF oPage
    NICE DRAWER ITEM PROMPT "Inicio" ICON "dashboard" OF oSide
    NICE DRAWER ITEM PROMPT "Simulaciones" ICON "calculate" OF oSide
    NICE DRAWER ITEM PROMPT "Configuración" ICON "settings" OF oSide
    END NICE DRAWER

    DEFINE NICE VSTACK oMainCol CLASS "w-full p-8 gap-6 bg-slate-50" OF oPage
        
    // --- 1. WELCOME BANNER ---
    DEFINE NICE CARD oBanner RADIUS 24 CLASS "w-full p-8 shadow-xl" ;
        STYLE "background: linear-gradient(135deg, #1e293b 0%, #312e81 100%);" OF oMainCol
            
    NICE SAY PROMPT "¡Hola! Bienvenido a JubilaPRO" ;
        CLASS "text-3xl font-bold text-white tracking-tight" OF oBanner
    NICE SAY PROMPT "Resumen de tu proyección de jubilación y estado del sistema." ;
        CLASS "text-indigo-200 text-sm font-medium opacity-80" OF oBanner
                 
    END NICE CARD
        
    // --- 2. QUICK ACTIONS ROW ---
    DEFINE NICE HSTACK oQuickRow CLASS "w-full gap-4 items-stretch" OF oMainCol
            
    DEFINE NICE CARD oCard RADIUS 16 BORDER COLOR "#3b82f6" BORDER WIDTH 6 SIDE "left" CLASS "flex-grow p-4 cursor-pointer" OF oQuickRow
    DEFINE NICE HSTACK oRow CLASS "items-center gap-4" OF oCard
    NICE ICON NAME "calculate" SIZE "sm" COLOR "blue" OF oRow
    NICE SAY PROMPT "Nueva Simulación" CLASS "text-sm font-bold text-slate-700" OF oRow
    END NICE HSTACK
    END NICE CARD

    DEFINE NICE CARD oCard RADIUS 16 BORDER COLOR "#6366f1" BORDER WIDTH 6 SIDE "left" CLASS "flex-grow p-4 cursor-pointer" OF oQuickRow
    DEFINE NICE HSTACK oRow CLASS "items-center gap-4" OF oCard
    NICE ICON NAME "compare_arrows" SIZE "sm" COLOR "indigo" OF oRow
    NICE SAY PROMPT "Comparar Escenarios" CLASS "text-sm font-bold text-slate-700" OF oRow
    END NICE HSTACK
    END NICE CARD

    DEFINE NICE CARD oCard RADIUS 16 BORDER COLOR "#10b981" BORDER WIDTH 6 SIDE "left" CLASS "flex-grow p-4 cursor-pointer" OF oQuickRow
    DEFINE NICE HSTACK oRow CLASS "items-center gap-4" OF oCard
    NICE ICON NAME "savings" SIZE "sm" COLOR "emerald" OF oRow
    NICE SAY PROMPT "Analizar Amortización" CLASS "text-sm font-bold text-slate-700" OF oRow
    END NICE HSTACK
    END NICE CARD

    DEFINE NICE CARD oCard RADIUS 16 BORDER COLOR "#94a3b8" BORDER WIDTH 2 SIDE "left" CLASS "flex-grow p-4 cursor-pointer" OF oQuickRow
    DEFINE NICE HSTACK oRow CLASS "items-center gap-4" OF oCard
    NICE ICON NAME "settings" SIZE "sm" COLOR "slate" OF oRow
    NICE SAY PROMPT "Configuración" CLASS "text-sm font-bold text-slate-700" OF oRow
    END NICE HSTACK
    END NICE CARD
            
    END NICE HSTACK
        
    // --- 3. MAIN KPI CARD ---
    DEFINE NICE CARD oKpiGridCard RADIUS 20 BORDER COLOR "#e2e8f0" BORDER WIDTH 1 CLASS "w-full p-6 shadow-lg bg-white" OF oMainCol
            
    DEFINE NICE HSTACK oRow CLASS "items-center gap-2" OF oKpiGridCard
    NICE ICON NAME "person" SIZE "sm" COLOR "indigo" OF oRow
    NICE SAY PROMPT "PERFIL DEL USUARIO ACTIVO" CLASS "text-xs font-bold text-slate-400 uppercase tracking-widest" OF oRow
    END NICE HSTACK
            
    DEFINE NICE GRID oKpiGrid COLS 2 CLASS "w-full mt-4" OF oKpiGridCard
                
    DEFINE NICE VSTACK oRow OF oKpiGrid CLASS "gap-0"
    NICE SAY PROMPT "Edad Actual" CLASS "text-[10px] font-bold text-slate-400 uppercase" OF oRow
    NICE SAY PROMPT "30" CLASS "text-xl font-bold text-slate-700" OF oRow
    END NICE VSTACK

    DEFINE NICE VSTACK oRow OF oKpiGrid CLASS "gap-0"
    NICE SAY PROMPT "Días Cotizados" CLASS "text-[10px] font-bold text-slate-400 uppercase" OF oRow
    NICE SAY PROMPT "3650" CLASS "text-xl font-bold text-slate-700" OF oRow
    END NICE VSTACK

    DEFINE NICE VSTACK oRow OF oKpiGrid CLASS "gap-0"
    NICE SAY PROMPT "Fecha Jub. Ord." CLASS "text-[10px] font-bold text-slate-400 uppercase" OF oRow
    NICE SAY PROMPT "12/05/2060" CLASS "text-xl font-bold text-indigo-600" OF oRow
    END NICE VSTACK

    DEFINE NICE VSTACK oRow OF oKpiGrid CLASS "gap-0"
    NICE SAY PROMPT "Cuenta Atrás" CLASS "text-[10px] font-bold text-slate-400 uppercase" OF oRow
    NICE SAY PROMPT "12.345 días" CLASS "text-xl font-bold text-amber-600" OF oRow
    END NICE VSTACK
                
    END NICE GRID
            
    // Progress Bars
    DEFINE NICE VSTACK oRow OF oKpiGridCard CLASS "w-full gap-4 mt-6 items-stretch" STYLE "align-items: stretch;"
                
    DEFINE NICE VSTACK oSubRow1 OF oRow CLASS "w-full gap-1 items-stretch"
    DEFINE NICE HSTACK oTitleRow1 OF oSubRow1 CLASS "w-full justify-between" STYLE "justify-content: space-between;"
    NICE SAY PROMPT "Cotización Máxima (37 años)" CLASS "text-[10px] font-bold text-slate-500 uppercase" OF oTitleRow1
    NICE SAY PROMPT "27%" CLASS "text-xs font-black text-indigo-600" OF oTitleRow1
    END NICE HSTACK
    NICE PROGRESS VALUE 0.27 COLOR "indigo" OF oSubRow1
    END NICE VSTACK

    DEFINE NICE VSTACK oSubRow2 OF oRow CLASS "w-full gap-1 items-stretch"
    DEFINE NICE HSTACK oTitleRow2 OF oSubRow2 CLASS "w-full justify-between" STYLE "justify-content: space-between;"
    NICE SAY PROMPT "Objetivo Jub. Anticipada (38.5 años)" CLASS "text-[10px] font-bold text-slate-500 uppercase" OF oTitleRow2
    NICE SAY PROMPT "15%" CLASS "text-xs font-black text-purple-600" OF oTitleRow2
    END NICE HSTACK
    NICE PROGRESS VALUE 0.15 COLOR "purple" OF oSubRow2
    END NICE VSTACK
                
    END NICE VSTACK
            
    END NICE CARD

    DEFINE NICE FOOTER oFooter CLASS "bg-slate-800 text-white py-2" OF oPage
    NICE SAY PROMPT "© 2026 JubilaPRO - Todos los derechos reservados" CLASS "text-xs opacity-50 q-mx-md" OF oFooter
    END NICE FOOTER

    ACTIVATE NICE PAGE oPage
    
    ACTIVATE WINDOW oWnd CENTERED
    
return nil


