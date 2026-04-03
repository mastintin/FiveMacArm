#include "FiveMac.ch"

// Class for Button controls specifically designed to live inside SwiftUI Stacks (VStack, HStack, ZStack)
// These controls do NOT have their own NSView/hWnd; they are managed by the Stack's RecursiveItemView.

CLASS TSwiftButtonStack FROM TSwiftStackItem

    ACCESS Caption      INLINE ::GetText()
    ASSIGN Caption( c ) INLINE ::SetText( c )

    METHOD New( cId, oOwner, cCaption, bAction )
    METHOD OnAction()
    
ENDCLASS

METHOD New( cId, oOwner, cCaption, bAction ) CLASS TSwiftButtonStack
    
    ::Super:New( cId, oOwner )
    
    if bAction != nil
        ::bAction := bAction
    endif

return Self

METHOD OnAction() CLASS TSwiftButtonStack
    if ::bAction != nil
        Eval( ::bAction, Self )
    endif
return nil
