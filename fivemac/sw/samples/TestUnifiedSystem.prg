#include "FiveMac.ch"

// -------------------------------------------------------------------------- //
// Test de la Gran Unificación (Versión Corregida)
// -------------------------------------------------------------------------- //

function Main()
   local oWnd, oBtn, oLabel
   local cUrl := "https://raw.githubusercontent.com/fivetechsoft/fivemac/master/README.md"
   
   oWnd := TSwWindow():New( "Sistema Unificado Fivemac", 600, 500 )
   oLabel := TSwLabel():New( 50, 50, 500, 40, "Esperando workflow...", oWnd )
   
   oBtn := TSwButton():New( 150, 150, 300, 50, "DISPARAR UNIFICACIÓN", oWnd, ;
      { |o| ( ;
         oWnd:SetTitle( "Descargando información..." ), ;
         SD:SwHttpGet( cUrl, "descarga_readme" ), ;
         SD:Text( oLabel:cId, "ctx:descarga_readme" ), ;
         SD:window_title( oWnd:cId, "SISTEMA UNIFICADO OK" ) ;
      ) } )

   oWnd:Center() 
   
   ACTIVATE WINDOW oWnd
   
return nil
