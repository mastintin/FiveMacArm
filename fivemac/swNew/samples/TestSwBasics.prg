#include "FiveMac.ch"

function Main()

   local oWnd, oLabel1, oLabel2, oBtn1, oBtn2, oToggle1
   
   // 1. Creamos la Ventana (Form)
   oWnd := TSwForm():New( "FiveMac SwiftUI - The Stable Way", 600, 400 )

   // 2. Añadimos controles
   oLabel1 := SwLabel():New( 30, 30, 400, 40, "¡VUELVE A LA VIDA!", oWnd )

   oToggle1 := SwToggle():New( 80, 30, 250, 30, "Modo Reactivo ON", oWnd, ;
                               {|lOn| MsgInfo( "Estado: " + iif( lOn, "ON", "OFF" ) ) }, , .t. )

   oBtn1 := SwButton():New( 150, 30, 200, 40, "Púlsame", oWnd, ;
                             {|| MsgInfo( "¡Funcionando como antes!" ) } )

   oLabel2 := SwLabel():New( 320, 30, 500, 20, "Arquitectura estable restaurada (Commit 0baccf8 inspired)", oWnd )

   // 3. Activamos (Show + Run bloqueante interno)
   oWnd:Activate()

return nil
