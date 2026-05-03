#include "SwFive.ch"

//----------------------------------------------------------------------------//

function Main()
   HSW_START_SWIFT( "AppMain" )
return nil

//----------------------------------------------------------------------------//

function AppMain()

   local oWnd, oMap, oSldZoom, oSldPitch, oSay, oGetCity
   local oBtn3D, oBtnAnnos, oBtnTraffic, oBtnSat, oBtnNorm
   local nLat := 40.416775
   local nLon := -3.703790
   local cCity := "Madrid"
   local nZoom := 500  // Iniciamos ya muy cerca para forzar el 3D
   local nPitch := 0
   
   DEFINE WINDOW oWnd TITLE "Fivemac MapKit PRO 3D" SIZE 800, 750
   
   @ 20, 20 SAY oSay PROMPT "MapKit Pro: Zoom Extremo e Inclinación" OF oWnd
   oSay:nAutoResize := AnchoMovil
   
   @ 60, 20 MAP oMap LAT nLat LON nLon ZOOM nZoom SIZE 760, 350 OF oWnd
   oMap:nAutoResize := AnchoMovil + AltoMovil
      
   @ 430, 20 GET oGetCity VAR cCity PROMPT "Lugar:" SIZE 300, 40 OF oWnd
   oGetCity:nAutoResize := AnchoMovil + AnclaBottom
   
   @ 430, 330 BUTTON "Buscar" SIZE 100, 40 OF oWnd ;
      ACTION ( oGetCity:Sync(), oMap:Search( oGetCity:text ) ) ;
      AUTORESIZE AnclaRight + AnclaBottom

   // Slider con escala 1-1000. 1000 ahora equivale a 100 metros de altura.
   @ 490, 20 SLIDER oSldZoom VALUE 950 RANGE 1, 1000 SIZE 350, 40 OF oWnd ;
      PROMPT "Zoom: 950" ;
      SHOWVALUE .F. ;
      ACTION { | nVal | ;
         oMap:SetCamera( , , 100100 - ( nVal * 100 ) ), ;
         oSldZoom:SetText( "Zoom: " + AllTrim( Str( Int( nVal ) ) ) ) ;
      }
   oSldZoom:nAutoResize := AnchoMovil + AnclaBottom

   @ 540, 20 SLIDER oSldPitch VALUE 0 RANGE 0, 85 SIZE 350, 40 OF oWnd ;
      PROMPT "Inclinación: 0°" ;
      SHOWVALUE .F. ;
      ACTION { | nVal | ;
         oMap:SetCamera( nVal ), ;
         oSldPitch:SetText( "Inclinación: " + AllTrim( Str( Int( nVal ) ) ) + "°" ) ;
      }
   oSldPitch:nAutoResize := AnchoMovil + AnclaBottom
      
   @ 600, 20 BUTTON oBtn3D PROMPT "Reset 3D" SIZE 100, 40 OF oWnd ;
      ACTION oMap:SetCamera( 45, 0, 800 ) 
   oBtn3D:nAutoResize := AnclaLeft + AnclaBottom
      
   @ 600, 130 BUTTON oBtnAnnos PROMPT "Marcadores" SIZE 100, 40 OF oWnd ;
      ACTION ( oMap:AddAnnotation( 40.415363, -3.70717, "Plaza Mayor", "Histórico" ),;
               oMap:AddAnnotation( 40.4189, -3.7144, "Palacio Real", "Visita obligada" ) )
   oBtnAnnos:nAutoResize := AnclaLeft + AnclaBottom

   @ 600, 240 BUTTON oBtnTraffic PROMPT "Tráfico" SIZE 100, 40 OF oWnd ;
      ACTION oMap:ShowTraffic( .T. )
   oBtnTraffic:nAutoResize := AnclaLeft + AnclaBottom

   @ 600, 350 BUTTON oBtnSat PROMPT "Satélite" SIZE 100, 40 OF oWnd ;
      ACTION oMap:SetStyle( 1 )
   oBtnSat:nAutoResize := AnclaLeft + AnclaBottom

   @ 600, 460 BUTTON oBtnNorm PROMPT "Normal" SIZE 100, 40 OF oWnd ;
      ACTION oMap:SetStyle( 0 )
   oBtnNorm:nAutoResize := AnclaLeft + AnclaBottom
      
   ACTIVATE WINDOW oWnd CENTER
   
return nil
