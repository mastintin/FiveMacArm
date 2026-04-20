#include "swfive.ch"

// -------------------------------------------------------------------------- //
// Test de Proxy Dinámico (SD:)
// Este test valida que Harbour puede descubrir los comandos de Swift 
// a través del Proxy Map negociado en tiempo de ejecución.
// -------------------------------------------------------------------------- //

#define SD Sw_GetProxy()

function Main()
   local oWnd, oBtn, oBtn2
   local cUrl := "https://raw.githubusercontent.com/fivetechsoft/fivemac/master/README.md"
   
   oWnd := TSwWindow():New( "Test Dynamic Proxy SD: (Map)", 500, 400 )

   // Botón para probar comandos dinámicos directos
   oBtn := TSwButton():New( 150, 100, 300, 50, "ENVIAR COMANDOS VÍA SD:", oWnd, ;
      { || ;
      SD:SWALERT( "Hola desde Harbour vía Proxy Dinámico" ), ;
      SD:SWHTTPGET( cUrl, "result_sd" ), ;
      SD:SWMSGINFO( "El comando SWMSGINFO ha sido mapeado a 'info' en Swift" ) ;
      } )

   // Botón para probar el buffering (Pipeline) con el proxy
   oBtn2 := TSwButton():New( 250, 100, 300, 50, "MISION: RED -> DISCO -> ALERT", oWnd, ;
      { || ;
      SD:Pipeline( { || ;
      SD:SWHTTPGET( cUrl, "mi_data" ), ;
      SD:SWFILEWRITE( "~/resultado_proxy.txt", "ctx:mi_data" ), ;
      SD:SWALERT( "ctx:mi_data" ), ;
      SD:SWTEXT( oBtn2:cId, "¡CONSEGUIDO!" ) ;
      } ) ;
      } )

   ACTIVATE WINDOW oWnd CENTERED
   
return nil
