#include "FiveMac.ch"
#include "SwiftControls.ch"

function Main()

    local oWnd, oGrid
    local nW := 800
    local nH := 600
    local aCols := { { "flexible", 100, 200 }, { "flexible", 100, 200 }, { "flexible", 100, 200 } }
    local i

    DEFINE WINDOW oWnd TITLE "Testing Standalone SwiftGrid" SIZE nW, nH FLIPPED

    @ 20, 20 SWIFTGRID oGrid SIZE 760, 500 COLUMNS aCols OF oWnd
    
    MsgInfo( "Grid Handle: " + ValType( oGrid:hWnd ) + " " + cValToChar( oGrid:hWnd ) )
    
    oGrid:bAction := { | nIndex | MsgInfo( "Selected Item: " + Str( nIndex ) ) }
    
    // Add Items
    for i := 1 to 50
    oGrid:AddVStack() // Just a container, or we can add direct items
    // Let's add cards
    // Since TSwiftGrid inherits TSwiftList (which inherits TSwiftVStack nesting),
    // items added to oGrid (root) are added to the Grid.
       
    // Because Grid iterates items, each "Item" added becomes a cell.
       
    // Cell content: VStack with Image and Text
    // Note: To add a composed cell, we should use AddVStack() calling parent
    // But wait, oGrid:AddVStack() creates a NEW VStackItem and appends it to Grid.
    // THIS IS CORRECT. The LazyVGrid iterates these children.
       
    createCard( oGrid, i )
    next

    @ 540, 350 BUTTON "Exit" SIZE 100, 30 OF oWnd ACTION oWnd:End()

    ACTIVATE WINDOW oWnd 

return nil

function createCard( oGrid, nIndex )
    local oCard
    
    oCard := oGrid:AddVStack()
    oCard:SetColor( 230, 230, 250, 1.0 ) // Lavender background
    oCard:AddSystemImage( "star.fill" )
    oCard:AddText( "Item " + AllTrim( Str( nIndex ) ) )
    
return nil
