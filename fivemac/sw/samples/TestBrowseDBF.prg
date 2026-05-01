#include "swfive.ch"

//----------------------------------------------------------------------------//

function Main()
   HSW_START_SWIFT( "AppMain" )
return nil

//----------------------------------------------------------------------------//

function AppMain()
   local oWnd, oBrw
   local cDbfPath := Path() + "test.dbf"
   
   if ! File( cDbfPath )
      MsgInfo( "No se encuentra test.dbf en: " + cDbfPath )
      return nil
   endif
   
   // Abrir DBF
   USE ( cDbfPath ) SHARED NEW ALIAS TEST
   
   DEFINE WINDOW oWnd TITLE "Fivemac SW - Browse DBF" SIZE 800, 500
   
   @ 20, 20 SWBROWSE oBrw SIZE 760, 400 OF oWnd
   
   // En DBF no hace falta pasar objeto, pilla la workarea activa
   // y autogenera las columnas si no hemos definido ninguna
   oBrw:SetDB() 
   
   // Personalización opcional
   oBrw:cBackColor := "#EDF2F7"
   
   ACTIVATE WINDOW oWnd CENTERED
   
   CLOSE TEST

return nil
