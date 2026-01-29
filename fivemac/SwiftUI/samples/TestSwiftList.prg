#include "FiveMac.ch"
#include "SwiftControls.ch"

function Main()

    local oWnd
    local oList1, oList2
    local oRow, oItem
    local nW := 1000
    local nH := 600
    local i

    DEFINE WINDOW oWnd TITLE "Testing Two Independent Lists" SIZE nW, nH FLIPPED

    // List 1: Employees (Left)
    @ 20, 20 SWIFTLIST oList1 SIZE 460, 500 OF oWnd
    
    oList1:bAction := { | nIndex | MsgInfo( "List 1 Selected: " + Str( nIndex ) ) }
    
    for i := 1 to 10
    oRow := oList1:AddHStack()
    oRow:AddSystemImage( "person.fill" )
    oRow:AddText( "Employee " + AllTrim( Str( i ) ) )
    oRow:AddSpacer()
    next

    // List 2: Departments (Right)
    @ 20, 500 SWIFTLIST oList2 SIZE 460, 500 OF oWnd
    
    oList2:bAction := { | nIndex | MsgInfo( "List 2 Selected: " + Str( nIndex ) ) }

    for i := 1 to 5
    oRow := oList2:AddHStack()
    oRow:AddSystemImage( "building.2.fill" )
    oRow:AddText( "Department " + AllTrim( Str( i ) ) )
    oRow:AddSpacer()
    oRow:AddButton( "View", { || MsgAlert( "View Dept " + AllTrim( Str( i ) ) ) } )
    next

    @ 540, 450 BUTTON "Exit" SIZE 100, 30 OF oWnd ACTION oWnd:End()

    ACTIVATE WINDOW oWnd 

return nil
