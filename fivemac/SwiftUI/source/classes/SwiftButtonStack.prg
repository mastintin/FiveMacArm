#include "FiveMac.ch"

// Class for Button controls specifically designed to live inside SwiftUI Stacks (VStack, HStack, ZStack)
// These controls do NOT have their own NSView/hWnd; they are managed by the Stack's RecursiveItemView.

CLASS TSwiftButtonStack FROM TSwiftStackItem

    ACCESS Caption      INLINE ::hState["Caption"]
    ASSIGN Caption( c ) INLINE ::SetCaption( c )

    ACCESS lProminent    INLINE ::hState["isProminent"]
    ASSIGN lProminent( l ) INLINE ::SetProminent( l )

    DATA hState INIT {=>}

    METHOD New( oOwner, cCaption, cId, bAction )
    METHOD SetCaption( cCaption )
    METHOD SetProminent( lProminent )
    METHOD OnAction()
    
ENDCLASS

METHOD New( oOwner, cCaption, cId, bAction ) CLASS TSwiftButtonStack
    
    local oRoot := oOwner:Root()
    local cParentId := If( oOwner:IsKindOf( "TSWIFTSTACKITEM" ), oOwner:cId, nil )

    if oRoot == nil ; oRoot := oOwner ; endif

    ::hState := { "Caption" => cCaption, "isProminent" => .T. }

    if oRoot:IsKindOf( "TSWIFTVSTACK" )
       cId := SD_VSTK_ADD_BUTTON_ITEM( oRoot:cId, cCaption, cParentId, ::hState["isProminent"] )
    else
       cId := SD_ZSTK_ADD_BUTTON_TO( oRoot:cId, cCaption, cParentId, ::hState["isProminent"] )
    endif

    ::Super:New( cId, oOwner )
    
    if bAction != nil ; ::bAction := bAction ; endif

return Self

METHOD SetProminent( lProminent ) CLASS TSwiftButtonStack
    local oRoot := ::Root()
    ::hState["isProminent"] := lProminent
    if oRoot != nil
        if lProminent
            sd_vstk_set_item_bgcolor( oRoot:cId, ::cId, -2, 100 )
        else
            sd_vstk_set_item_bgcolor( oRoot:cId, ::cId, -1, 100 )
        endif
    endif
return nil

METHOD SetCaption( cCaption ) CLASS TSwiftButtonStack
    ::hState["Caption"] := cCaption
    ::SetText( cCaption )
return nil

METHOD OnAction() CLASS TSwiftButtonStack
    if ::bAction != nil
        Eval( ::bAction, ::cId, Self )
    endif
return nil
