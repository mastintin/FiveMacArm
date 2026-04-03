#include "FiveMac.ch"

// Class for Label/Text controls specifically designed to live inside SwiftUI Stacks (VStack, HStack, ZStack)
// These controls do NOT have their own NSView/hWnd; they are managed by the Stack's RecursiveItemView.

CLASS TSwiftLabelStack FROM TSwiftStackItem

    ACCESS Caption      INLINE ::GetText()
    ASSIGN Caption( c ) INLINE ::SetText( c )

    METHOD New( cId, oOwner, cCaption )
    
ENDCLASS

METHOD New( cId, oOwner, cCaption ) CLASS TSwiftLabelStack
    
    ::Super:New( cId, oOwner )
    
return Self
