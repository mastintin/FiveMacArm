#include "swfive.ch"

function Main()
   HSW_START_SWIFT( "AppMain" )
return nil

function AppMain()
   local oWnd, oBrw
   local aData := { ;
      { "101", "Manuel Murillo", "manuel@test.com", "Activo" }, ;
      { "102", "Antonio Pérez", "antonio@test.com", "Activo" }, ;
      { "103", "Jose García", "jose@test.com", "Baja" }, ;
      { "104", "Maria López", "maria@test.com", "Activo" }, ;
      { "105", "Elena Rivas", "elena@test.com", "Pendiente" }, ;
      { "106", "David Sanz", "david@test.com", "Activo" }, ;
      { "107", "Lucia Ferrero", "lucia@test.com", "Activo" } ;
   }
   
   DEFINE WINDOW oWnd TITLE "Fivemac Browse Premium (Native Table)" SIZE 650, 450
   
   @ 60, 20 SWBROWSE oBrw OF oWnd SIZE 610, 360
   
    oBrw:AddColumn( "ID", 60, "id" )
    oBrw:AddColumn( "Nombre Completo", 250, "name" )
    oBrw:AddColumn( "Email", 180, "email" )
    oBrw:AddColumn( "Estado", 80, "status" )
    
    oBrw:bLDblClick := { | o, nId | MsgInfo( "Has hecho doble clic en la fila: " + cValToChar( nId ) ) }

    oBrw:SetArray( aData )
   
   @ 15, 20 SAY "Test de Browse Dinámico (SwiftUI Native Table)" OF oWnd SIZE 400, 30
   
   oWnd:Activate( .t. ) // Modal para ver el log

return nil
