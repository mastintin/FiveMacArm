#include "swfive.ch"

function Main()
   HSW_START_SWIFT( "AppMain" )
return nil

function AppMain()
   local oWnd, oBrw
   local aData := {}
   
   // Datos limpios
   AAdd( aData, { "id" => 101, "name" => "Manuel Murillo", "email" => "manuel@test.com", "status" => "Activo" } )
   AAdd( aData, { "id" => 102, "name" => "Antonio Pérez", "email" => "antonio@test.com", "status" => "Activo" } )
   AAdd( aData, { "id" => 103, "name" => "Jose García", "email" => "jose@test.com", "status" => "Baja" } )
   AAdd( aData, { "id" => 104, "name" => "Maria López", "email" => "maria@test.com", "status" => "Activo" } )
   AAdd( aData, { "id" => 105, "name" => "Elena Rivas", "email" => "elena@test.com", "status" => "Pendiente" } )
   AAdd( aData, { "id" => 106, "name" => "David Sanz", "email" => "david@test.com", "status" => "Activo" } )
   AAdd( aData, { "id" => 107, "name" => "Lucia Ferrero", "email" => "lucia@test.com", "status" => "Activo" } )
   
   DEFINE WINDOW oWnd TITLE "Fivemac Browse Premium (Native Table)" SIZE 650, 450
   
   @ 20, 20 SWBROWSE oBrw SIZE 610, 360 OF oWnd
   
   oBrw:AddColumn( "ID", 60, "id" )
   oBrw:AddColumn( "Nombre Completo", 250, "name" )
   oBrw:AddColumn( "Email", 180, "email" )
   oBrw:AddColumn( "Estado", 80, "status" )
   
   // Color de fondo del browse completo
   oBrw:cBackColor := "#F0F4F8"
   
   // Lógica de diseño mediante Codeblocks
   oBrw:SetColBackColor( 4, { | v | If( v == "Baja", "#FFCCCC", If( v == "Pendiente", "#FFF3CD", "#D1E7DD" ) ) } )
   
   oBrw:SetColImg( 4, { | v | If( v == "Activo", "checkmark.circle.fill", ;
      If( v == "Baja", "xmark.circle.fill", ;
      If( v == "Pendiente", "clock.fill", "" ) ) ) } )
                              
   oBrw:SetColImg( 2, { || "person.circle" } )
   oBrw:SetColImg( 3, { || "envelope" } )

   // Doble clic para cambiar el valor (Test de actualización parcial)
   oBrw:bLDblClick := { | o, nId | UpdateStatus( o, nId ) }
   
   oBrw:SetArray( aData )
   
   ACTIVATE WINDOW oWnd CENTERED
   
return nil

//----------------------------------------------------------------------------//

static function UpdateStatus( oBrw, nId )
   local nRow := Val( nId )
   local cOld := oBrw:aRows[ nRow ][ "status" ]
   local cNew := if( cOld == "Activo", "Baja", "Activo" )
   
   oBrw:SetCellValue( nRow, 4, cNew )
   
return nil
