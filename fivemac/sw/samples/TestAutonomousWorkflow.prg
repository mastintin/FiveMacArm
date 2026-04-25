#include "swfive.ch"

// -------------------------------------------------------------------------- //
// Test de Workflow Autónomo (La "Apuesta Valiente")
// Swift realiza Red -> Disco -> UI sin volver a Harbour.
// -------------------------------------------------------------------------- //

function Main()
   local oWnd, oBtnLaunch, oLabel, oStack
   local cUrl  := "https://raw.githubusercontent.com/fivetechsoft/fivemac/master/README.md"
   local cPath := "~/Fivemac_Workflow_Result.txt"
   
   oWnd := TSwWindow():New( "Test Workflow Autónomo - Swift", 600, 400 )
   
   oLabel := TSwLabel():New( 50, 50, 500, 100, "HL pulse el botón para iniciar la misión asíncrona...", oWnd )

   oBtnLaunch := TSwButton():New( 250, 150, 300, 50, "¡INICIAR CADENA SWIFT!", oWnd, ;
      { || ;
         oStack := TSwActionStack():New(), ;
         oStack:AddUpdate( oLabel, "Misión en curso: Descargando y guardando..." ), ;
         ; // PASO 1: Descargar de Internet
         oStack:AddHttpGet( cUrl, "mi_descarga" ), ;
         ; // PASO 2: Guardar en disco (usando el resultado anterior)
         oStack:AddFileWrite( cPath, "mi_descarga" ), ;
         ; // PASO 3: Actualizar Label (usando el resultado)
         oStack:AddUpdate( oLabel, "¡ÉXITO! Archivo guardado en: " + cPath ), ;
         ; // PASO 4: Alerta final
         oStack:AddAlert( "La misión autónoma ha finalizado con éxito. Revisa el archivo en tu Home.", "mi_descarga" ), ;
         ;
         oStack:Execute(), ;
         MsgInfo( "Harbour: He enviado la misión a Swift. Ahora Swift trabaja solo en el fondo." ) ;
      } )

   ACTIVATE WINDOW oWnd CENTERED
   
return nil
