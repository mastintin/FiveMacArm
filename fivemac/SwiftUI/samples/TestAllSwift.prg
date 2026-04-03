#include "FiveMac.ch"
#include "SwiftControls.ch"

function Main()
   local oWnd, oVStack, oList, oSlider, oToggle
   local lOn := .T., nVal := 45
   local oRow, oItem

   DEFINE WINDOW oWnd TITLE "Test Arquitectura SwiftUI Modernizada" SIZE 700, 600 NOFLIPPED

   // 1. --- EL CONTENEDOR PRINCIPAL (GLASS) ---
   @ 20, 20 SWIFTVSTACK oVStack SIZE 300, 550 OF oWnd 
   oVStack:Glass := .T.
   oVStack:Spacing := 15
   oVStack:nClrAcc := CLR_BLUE 
   oVStack:nAlphaAcc := 100 // Fondo azul suave con glass

   oVStack:AddText( "Panel de Control" ):SetFont( 24, .T. )
   oVStack:AddDivider()

   // 2. --- TEST TOGGLE ---
   // oToggle := oVStack:AddToggle( "Efecto Moderno", lOn, { |val| lOn := val }, .T. )
  
   oToggle := TSwiftToggleStack():New( oVStack, "Efecto Moderno", lOn, .T. )
   oToggle:SetColor( CLR_GREEN, nil, 180 )

   // 3. --- TEST SLIDER CON GLASS ---
   // oSlider := oVStack:AddSlider( nVal, 0, 100, { |val| nVal := val }, .T. )
   oSlider := TSwiftSliderStack():New( oVStack, nVal, 0, 100, .t. , { |val| nVal := val } ) 

   oSlider:SetColor( CLR_RED, nil, 200 )

   oVStack:AddSpacer()

   // 4. --- ACCIONES QUE AFECTAN A LA LISTA ---
   oVStack:AddButton( "Añadir Fila a la Lista", {|| AddNewRow( oList ) } )
   oVStack:AddButton( "Limpiar Lista", {|| oList:RemoveAll() } )


   // 5. --- LA LISTA (Lado Derecho) ---
   @ 20, 340 SWIFTLIST oList SIZE 340, 550 OF oWnd 
   oList:nClrAcc := CLR_HGRAY 
   oList:nAlphaAcc := 40 // Fondo gris muy suave
    
   // Añadimos unas filas iniciales usando la clase restaurada TSwiftRow
   AddInitialRows( oList )

   ACTIVATE WINDOW oWnd CENTERED
return nil

//----------------------------------------------------------------------------//

static function AddInitialRows( oList )
   local oRow
   
   oRow := oList:AddListRow()
   oRow:AddIcon( "star.fill" ):SetColor( CLR_YELLOW, nil, 255 )
   oRow:AddText( "Fila Importante" ):SetFont( 16, .T. )
   oRow:SetSpacing( 10 )

   oRow := oList:AddListRow()
   oRow:AddIcon( "heart.fill" ):SetColor( CLR_RED, nil, 255 )
   oRow:AddText( "Fila Favorita" )
   oRow:AddSpacer()
   oRow:AddButton( "X", {|| MsgInfo( "Borrar!" ) } ):SetSize( 30, 30 )

return nil

//----------------------------------------------------------------------------//

static function AddNewRow( oList )
   local oRow
   static nCounter := 1

   oRow := oList:AddListRow()
   oRow:AddIcon( "bolt.fill" ):SetColor( CLR_CYAN, nil, 255 )
   oRow:AddText( "Nueva Fila #" + hb_ntos( nCounter++ ) )
   oRow:SetSpacing( 15 )
   
return nil
