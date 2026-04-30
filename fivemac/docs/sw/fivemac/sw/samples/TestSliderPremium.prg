#include "SwFive.ch"

//----------------------------------------------------------------------------//

function Main()
   HSW_START_SWIFT( "mainApp" )
return nil

function mainApp()
   local oWnd, oSlider1, oSlider2, oSlider3, oSlider4, oSlider5
   local oBtn1, oBtn2
   
   // Definición de la ventana principal
   DEFINE WINDOW oWnd TITLE "Fivemac Ultra-Premium Sliders" ;
      SIZE 600, 600
      
   @ 20, 20 SLIDER oSlider1 VALUE 50 RANGE 0, 100 OF oWnd ;
      SIZE 300, 80 ;
      PROMPT "Volumen General" ;
      ICONMIN "speaker.fill" ;
      ICONMAX "speaker.wave.3.fill" ;
      COLOR "#FF9500" 
      
   @ 110, 20 SLIDER oSlider2 VALUE 25 RANGE 0, 50 OF oWnd ;
      SIZE 300, 80 ;
      PROMPT "Brillo Pantalla" ;
      ICONMIN "sun.min" ;
      ICONMAX "sun.max.fill" ;
      COLOR "#007AFF" 
      
   @ 200, 20 SLIDER oSlider3 VALUE 75 RANGE 0, 100 OF oWnd ;
      SIZE 150, 150 ;
      PROMPT "Slider Normal" ;
      COLOR "#34C759" 
      
   @ 200, 200 SLIDER oSlider4 VALUE 40 RANGE 0, 100 OF oWnd ;
      SIZE 150, 150 ;
      PROMPT "Deshabilitado" ;
      DISABLED ;
      COLOR "#FF2D55" 
      
   @ 380, 20 SLIDER oSlider5 VALUE 10 RANGE 0, 100 OF oWnd ;
      SIZE 400, 60 ;
      PROMPT "Con Pasos (Step 10)" ;
      STEP 10 ;
      COLOR "#5856D6" 
      
   @ 460, 20 BUTTON oBtn1 PROMPT "Alternar Habilitado" OF oWnd ;
      SIZE 180, 30 ;
      ACTION ( oSlider1:SetEnabled( ! oSlider1:IsEnabled() ), ;
               oSlider2:SetEnabled( ! oSlider2:IsEnabled() ) )
               
   @ 460, 210 BUTTON oBtn2 PROMPT "Mostrar/Ocultar Step" OF oWnd ;
      SIZE 180, 30 ;
      ACTION ( oSlider5:SetVisible( ! oSlider5:IsVisible() ) )

   ACTIVATE WINDOW oWnd CENTER
   
return nil

//----------------------------------------------------------------------------//
