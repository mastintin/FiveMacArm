#include "swfive.ch"

// -------------------------------------------------------------------------- //
// Test de Puente Transparente (SD_ Proxy Magic)
// Harbour -> Swift sin capas visibles.
// -------------------------------------------------------------------------- //

function Main()
   local oWnd, oBtn
   local cUrl  := "https://raw.githubusercontent.com/fivetechsoft/fivemac/master/README.md"
   local cPath := "~/Fivemac_Magic_Result.txt"
   
   oWnd := TSwWindow():New( "Test Puente Mágico - Swift", 500, 400 )

   oBtn := TSwButton():New( 150, 100, 200, 50, "LANZAR MAGIA SD_", oWnd, ;
      { || ;
         ; // 1. Llamada transparente a Red
         SD_http_get( cUrl, "mi_magia" ), ;
         ;
         ; // 2. Llamada transparente a Disco (usando el contexto)
         SD_file_write( cPath, "mi_magia" ), ;
         ;
         ; // 3. Alerta transparente
         SD_Alert( "¡Increíble! He ejecutado Red y Disco usando el prefijo SD_ directamente." ) ;
      } )

   ACTIVATE WINDOW oWnd CENTERED
   
return nil
