#include "FiveMac.ch"
#include "SwiftControls.ch"


function Main()

    local oWnd
    local oSidebar, oMainList
    local oRow
    local oBtn
    // Build a standard "Sidebar + Content" Layout
    // Sidebar: Fixed width (250)
    // Content: Flexible width
   
    local nWinWidth := 900
    local nWinHeight := 600

    DEFINE WINDOW oWnd TITLE "SwiftFive Mail App - Standalone Lists" ;
        SIZE nWinWidth, nWinHeight FLIPPED

    // --- Sidebar (List 1) ---
    // Top-Left, Fixed Width, Full Height (Anchored Left + Top + Bottom)
    @ 20, 20 SWIFTLIST oSidebar SIZE 250, nWinHeight - 80 OF oWnd ;
        AUTORESIZE ( AnclaTop + AnclaBottom + AnclaLeft )

    oSidebar:SetScroll( .T. )


    // Simulate Mac Sidebar Style
    oSidebar:SetBackgroundColor( 240, 240, 240, 1.0 ) 
  

    // Add Categories
    AddSidebarItem( oSidebar, "tray.fill", "Inbox", .T. ) // Default Selected
    AddSidebarItem( oSidebar, "paperplane.fill", "Sent" )
    AddSidebarItem( oSidebar, "pencil.circle.fill", "Drafts" )
    oSidebar:AddSpacer()
    AddSidebarItem( oSidebar, "trash.fill", "Trash" )
   
    oSidebar:SelectIndex( 1 )
    oSidebar:bAction := { |nIdx| HandleSidebarSelection( nIdx, oMainList ) }


    // --- Main Content (List 2) ---
    // Right of Sidebar, fills remaining space (Anchored All Sides or just Width/Height)
    // Top: 20
    // Left: 290 (20 margin + 250 sidebar + 20 gap)
    // Width: nWinWidth - 310 (290 + 20 right margin)
    // Scale with Width and Height
    @ 20, 290 SWIFTLIST oMainList SIZE nWinWidth - 310, nWinHeight - 80 OF oWnd ;
        AUTORESIZE ( AnclaTop + AnclaBottom + AnclaLeft + AnclaRight + AnchoMovil + AltoMovil )
   
    oMainList:SetScroll( .T. )
    oMainList:SetBackgroundColor( 255, 255, 255, 1.0 )
   
    //oMainList:SelectIndex( 1 )
    // Load Initial Data (Inbox)
    LoadInbox( oMainList )

    oMainList:bAction := { |nIdx| MsgInfo( "Opening Email #" + AllTrim(Str(nIdx)) ) }
   
    // --- Footer / Status Bar (Optional) ---
    @ nWinHeight - 50, 20 SWIFTLABEL "SwiftList Standalone Demo" OF oWnd ;
        SIZE 300, 30 AUTORESIZE ( AnclaBottom + AnclaLeft )

    @ nWinHeight - 50, nWinWidth - 140 BUTTON oBtn PROMPT "Exit" OF oWnd ;
        ACTION oWnd:End() SIZE 120, 30 AUTORESIZE ( AnclaBottom + AnclaRight )


    ACTIVATE WINDOW oWnd 

return nil

// Helper to add stylized sidebar rows
function AddSidebarItem( oList, cIcon, cText, lBold )
    local oRow := oList:AddHStack()
    local oImg
   
    // Icon
    oRow:AddSystemImage( cIcon )
   
    // Text
    if lBold == .T.
        // We don't have explicit Bold text API yet in simple addText, 
        // but we can assume standard text for now.
        oRow:AddText( cText ) 
    else
        oRow:AddText( cText )
    endif
   
    oRow:AddSpacer()
   
return nil

function HandleSidebarSelection( nIdx, oMainList )
    // NOTE: We currently lack a 'Clear' method in SwiftList to fully implement
    // switching views dynamically in a single list instance without creating a mess.
    // For this visual verification of "Standalone Complex Example",
    // we will just show an alert confirming the independent event.
    // A future enhancement would be adding oList:Clear() or oList:SetItems().
   
    do case
        case nIdx == 1 
            MsgInfo( "Switched to Inbox" )
        case nIdx == 2
            MsgInfo( "Switched to Sent" )
        case nIdx == 3
            MsgInfo( "Switched to Drafts" )
        case nIdx == 4
            MsgInfo( "Clicked Spacer" )
        case nIdx == 5
            MsgInfo( "Switched to Trash" )
            otherwise
            MsgInfo( "Selected Category: " + AllTrim(Str(nIdx)) )
    endcase
   
return nil

function LoadInbox( oList )
    local i
    local aEmails := { ;
        { "envelope.fill", "Welcome to SwiftFive", "Get started with your new controls..." }, ;
        { "star.fill", "Meeting Reminders", "Don't forget the weekly standup at 10 AM." }, ;
        { "scroll.fill", "Invoice #10230", "Your payment has been processed successfully." }, ;
        { "person.fill", "New Follower", "John Doe started following your project." } ;
        }
   
    for i := 1 to Len( aEmails )
    AddEmailRow( oList, aEmails[i][1], aEmails[i][2], aEmails[i][3] )
    next
   
return nil

function AddEmailRow( oList, cIcon, cSubject, cPreview )
    local oRow := oList:AddHStack()
   
    // Leading Icon
    oRow:AddSystemImage( cIcon )
   
    // Vertical Stack for Subject + Preview (simulate with just Text for now or use complex nesting)
    // Since we don't have explicit VSTACK-inside-row easily w/o complex API wrapping,
    // we'll just use Text.
    // But wait! SwiftVStack allows nesting. 
    // `oRow` is an Item. `AddHStack` returns an Item.
    // Does `AddVStack` work on an `AddHStack` item? Yes! 
    // The C-level `addVStackItem` logic handles recursion if parentId is passed.
    // But `oRow:AddVStack()` isn't explicit in TSwiftStackItem yet?
    // Let's check `TSwiftStackItem` methods.
    // Actually `TSwiftStackItem` inherits `TSwiftVStack` methods? No.
    // `TSwiftVStack` performs actions on the root.
    // We need to see if `TSwiftStackItem` (returned by AddHStack) has methods to add children.
    // Let's check `SwiftVStack.prg` again.
   
    oRow:AddText( cSubject + " - " + cPreview )
   
    oRow:AddSpacer()
    oRow:AddSystemImage("chevron.right")
   
return nil
