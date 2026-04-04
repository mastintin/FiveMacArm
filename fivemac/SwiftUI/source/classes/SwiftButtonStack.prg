#include "FiveMac.ch"

// Class for Button controls specifically designed to live inside SwiftUI Stacks (VStack, HStack, ZStack)
// These controls do NOT have their own NSView/hWnd; they are managed by the Stack's RecursiveItemView.

CLASS TSwiftButtonStack FROM TSwiftStackItem

    ACCESS Caption      INLINE ::hState["Caption"]
    ASSIGN Caption( c ) INLINE ::SetCaption( c )

    DATA hState INIT {=>}

    METHOD New( oOwner, cCaption, cId, bAction )
    METHOD SetCaption( cCaption )
    METHOD OnAction()
    
ENDCLASS

METHOD New( oOwner, cCaption, cId, bAction ) CLASS TSwiftButtonStack
    
    local oRoot := oOwner:Root()
    local cParentId := If( oOwner:IsKindOf( "TSWIFTSTACKITEM" ), oOwner:cId, nil )

    if oRoot == nil ; oRoot := oOwner ; endif

    if oRoot:IsKindOf( "TSWIFTVSTACK" )
       cId := SD_VSTK_ADD_BUTTON_ITEM( oRoot:cId, cCaption, cParentId )
    else
       cId := SD_ZSTK_ADD_BUTTON_TO( oRoot:cId, cCaption, cParentId )
    endif

    ::Super:New( cId, oOwner )
    
    ::hState := { "Caption" => cCaption }

    if bAction != nil ; ::bAction := bAction ; endif

return Self

METHOD SetCaption( cCaption ) CLASS TSwiftButtonStack
    ::hState["Caption"] := cCaption
    ::SetText( cCaption )
return nil

METHOD OnAction() CLASS TSwiftButtonStack
    if ::bAction != nil
        Eval( ::bAction, ::cId, Self )
    endif
return nil
