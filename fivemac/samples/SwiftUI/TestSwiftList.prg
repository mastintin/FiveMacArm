#include "FiveMac.ch"
#include "SwiftControls.ch"

function Main()

    local oWnd, oZStack
    local oVStack, oList
    local oRow, oItem
    local nW := 500
    local nH := 600
    local i

    DEFINE WINDOW oWnd TITLE "Testing SwiftUI List (Table)" SIZE nW, nH FLIPPED

    // Standalone List Control
    @ 20, 20 SWIFTLIST oList SIZE 460, 500 OF oWnd
    
    oList:bAction := { | nIndex | MsgInfo( "Selected Row: " + Str( nIndex ) ) }
    
    // MsgInfo( "List Handle: " + ValType( oList:hWnd ) + " " + cValToChar( oList:hWnd ) )

    
    // Add Rows (HStacks) to List
    // Note: Since TSwiftList inherits from TSwiftVStack, we can use AddHStack, AddText, etc.
    // They will be added to the List because SwiftListLoader sets the global state.

    for i := 1 to 20
    oRow := oList:AddHStack()
       
    // Column 1: Icon
    oRow:AddSystemImage( "person.circle.fill" )
       
    // Column 2: Name
    oRow:AddText( "Employee " + AllTrim( Str( i ) ) )

    // Column 3: Detail (Button) - Now before spacer (or remove spacer if user wants it left)
    // User said "a la derecha en vez de la izquierda", implying they want it Left.
    // So I will place it immediately after text.
    //oRow:AddButton( "Details", MakeBlock( i ) )
       
    // Spacer to push anything else to right? (Nothing else)
    oRow:AddSpacer()
    next

    @ 550, 380 BUTTON "Exit" SIZE 100, 30 OF oWnd ACTION oWnd:End()

    ACTIVATE WINDOW oWnd 

return nil

function MakeBlock( nRow )    
return { || MsgAlert( "Button clicked in Row: " + AllTrim( Str( nRow ) ) ) }
