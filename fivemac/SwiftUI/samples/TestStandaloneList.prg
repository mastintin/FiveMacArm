#include "FiveMac.ch"
#include "SwiftControls.ch"

#define TYPE_TEXT            0
#define TYPE_SYSTEMIMAGE     1
#define TYPE_HSTACK          2
#define TYPE_IMAGEFILE       3
#define TYPE_VSTACK          4
#define TYPE_HSTACKCONTAINER 5
#define TYPE_SPACER          6
#define TYPE_LAZYVGRID       7
#define TYPE_LIST            8
#define TYPE_BUTTON          9
#define TYPE_DIVIDER         10

function Main()

    local oWnd
    local oSidebar, oMainList
    local oRow
    local oBtn
    local aSidebarIds := {}
    local aEmailIds := {}
   
    local nWinWidth := 900
    local nWinHeight := 600

    DEFINE WINDOW oWnd TITLE "SwiftFive Mail App - Standalone Lists" ;
        SIZE nWinWidth, nWinHeight FLIPPED

    // --- Sidebar (List 1) ---
    @ 20, 20 SWIFTLIST oSidebar SIZE 250, nWinHeight - 80 OF oWnd ;
        AUTORESIZE ( AnclaTop + AnclaBottom + AnclaLeft )

    oSidebar:SetScroll( .T. )
    oSidebar:SetBackgroundColor( 240, 240, 240, 1.0 ) 

    // Add Categories
    AAdd( aSidebarIds, { "inbox",  AddSidebarItem( oSidebar, "tray.fill", "Inbox" ) } ) 
    AAdd( aSidebarIds, { "sent",   AddSidebarItem( oSidebar, "paperplane.fill", "Sent" ) } )
    AAdd( aSidebarIds, { "drafts", AddSidebarItem( oSidebar, "pencil.circle.fill", "Drafts" ) } )
    oSidebar:AddSpacer()
    AAdd( aSidebarIds, { "trash",  AddSidebarItem( oSidebar, "trash.fill", "Trash" ) } )
   
    oSidebar:SelectIndex( 1 )
    oSidebar:bAction := { |cId| HandleSidebarSelection( cId, oMainList, aSidebarIds ) }

    // --- Main Content (List 2) ---
    @ 20, 290 SWIFTLIST oMainList SIZE nWinWidth - 310, nWinHeight - 80 OF oWnd ;
        AUTORESIZE ( AnclaTop + AnclaBottom + AnclaLeft + AnclaRight + AnchoMovil + AltoMovil )
   
    oMainList:SetScroll( .T. )
    oMainList:SetBackgroundColor( 255, 255, 255, 1.0 )
   
    LoadInbox( oMainList, aEmailIds )

    oMainList:bAction := { |cId| 
    local nIdx := AScan( aEmailIds, cId )
    if nIdx > 0
        MsgInfo( "Opening Email #" + AllTrim(Str(nIdx)) ) 
    endif
    return nil
    }
   
    @ nWinHeight - 50, 20 SWIFTLABEL "SwiftList Standalone Demo" OF oWnd ;
        SIZE 300, 30 AUTORESIZE ( AnclaBottom + AnclaLeft )

    @ nWinHeight - 50, nWinWidth - 140 BUTTON oBtn PROMPT "Exit" OF oWnd ;
        ACTION oWnd:End() SIZE 120, 30 AUTORESIZE ( AnclaBottom + AnclaRight )

    ACTIVATE WINDOW oWnd 

return nil

// Helper to add stylized sidebar rows

function AddSidebarItem( oList, cIcon, cText )
   
    local oRow := oList:AddListRow()
    local oIcon
    MsgInfo( "HStack ID: [" + oRow:cId + "]" )
    oRow:SetSize( 0, 80 ) // A bit more height for sidebar rows
    oIcon := oRow:AddIcon( cIcon )
    //oIcon:SetSize( 22, 22 ) // Slightly larger icon
    oRow:AddSpacing(50)
    oRow:AddText( cText )
    oRow:AddSpacer()
   
return oRow:cId



/*

function AddSidebarItem( oList, cIcon, cText )
    // 1. CREAR EL CONTENEDOR (Fila única en la List)
    // Esto llama a SwiftListLoader.addListRow(rootId) -> Devuelve un ID (ej: "UUID-HSTACK")
    local oRow := oList:AddListRow() 
    msginfo( oRow:cId)
    msginfo( "ID Creado: [" + oRow:cId + "]" ) 
    // 2. AÑADIR HIJOS AL CONTENEDOR (No a la lista directamente)
    // Estos DEBEN llamar a lst_add_item pasándole el cRowId como parentId
    SD_lst_add_item( oList:cId, TYPE_SYSTEMIMAGE, cIcon, "", oRow:cId ) 
    SD_lst_add_item( oList:cId, TYPE_TEXT,        cText, "", oRow:cId )

    SD_lst_add_item( oList:cId, TYPE_SPACER,      "",    "", oRow:cId )

return oRow:cId
*/



function HandleSidebarSelection( cId, oMainList, aSidebarIds )
   
    local nPos := AScan( aSidebarIds, { |a| a[2] == cId } )
    local cType := ""
    
    if nPos > 0
        cType := aSidebarIds[nPos][1]
        do case
            case cType == "inbox" 
                MsgInfo( "Switched to Inbox" )
            case cType == "sent"
                MsgInfo( "Switched to Sent" )
            case cType == "drafts"
                MsgInfo( "Switched to Drafts" )
            case cType == "trash"
                MsgInfo( "Switched to Trash" )
        endcase
    endif
    
return nil

function LoadInbox( oList, aEmailIds )
    local i
    local aEmails := { ;
        { "envelope.fill", "Welcome to SwiftFive", "Get started with your new controls..." }, ;
        { "star.fill", "Meeting Reminders", "Don't forget the weekly standup at 10 AM." }, ;
        { "scroll.fill", "Invoice #10230", "Your payment has been processed successfully." }, ;
        { "person.fill", "New Follower", "John Doe started following your project." } ;
        }
   
    for i := 1 to Len( aEmails )
        AAdd( aEmailIds, AddEmailRow( oList, aEmails[i][1], aEmails[i][2], aEmails[i][3] , i ) )
    next
return nil

function AddEmailRow( oList, cIcon, cSubject, cPreview, nRow)
    local oRow := oList:AddListRow()
    local oIcon
    oRow:SetSize( 0, 164 )
    oRow:SetSpacing( 15 ) 
    oIcon := oRow:AddIcon( cIcon )
    oIcon:SetSize( 32, 32 )
    oRow:AddText( cSubject + " - " + cPreview )
    oRow:AddSpacer()
    oRow:AddButton("chevron.right", {|| MsgInfo("Button in row " + AllTrim(Str(nRow)) + " clicked!") })
return oRow:cId
