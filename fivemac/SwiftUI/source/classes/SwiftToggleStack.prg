#include "FiveMac.ch"

// Class for Toggle controls specifically designed to live inside SwiftUI Stacks (VStack, HStack, ZStack)
// These controls do NOT have their own NSView/hWnd; they are managed by the Stack's RecursiveItemView.

CLASS TSwiftToggleStack FROM TSwiftStackItem

    ACCESS Caption      INLINE ::hState["Caption"]
    ASSIGN Caption( c ) INLINE ::SetCaption( c )

    ACCESS Checked      INLINE ::hState["Value"]
    ASSIGN Checked( l ) INLINE ::SetValue( l )

    ACCESS Value        INLINE ::hState["Value"]
    ASSIGN Value( l )   INLINE ::SetValue( l )

    ACCESS IsSwitch      INLINE ::hState["IsSwitch"]
    ASSIGN IsSwitch( l ) INLINE ::hState["IsSwitch"] := l

    DATA hState INIT {=>}

    METHOD New( cId, oOwner, cCaption, lOn, lSwitch )
    METHOD SetValue( lOn )
    METHOD SetCaption( cCaption )
    METHOD OnChange( lOn )

ENDCLASS

METHOD New( oOwner, cCaption, lOn, lSwitch, cId, bAction ) CLASS TSwiftToggleStack
        
    DEFAULT lOn := .F., lSwitch := .F.
    cId := SD_VSTK_ADD_TOGGLE( oOwner:cId, cId, cCaption, lOn, lSwitch )
 
    ::Super:New( cId, oOwner )
    ::hState := {=>}
    ::hState["Caption"]  := cCaption
    ::hState["Value"]    := lOn
    ::hState["IsSwitch"] := lSwitch

    if bAction != nil ; ::bAction := bAction ; endif 

return Self



METHOD SetValue( lOn ) CLASS TSwiftToggleStack
    if ::hState["Value"] != lOn
        ::hState["Value"] := lOn
        SD_TGL_SET_VALUE( ::cId, lOn )
        if ::bAction != nil
            Eval( ::bAction, lOn, Self )
        endif
    endif
return nil

METHOD SetCaption( cCaption ) CLASS TSwiftToggleStack
    ::hState["Caption"] := cCaption
    SD_TGL_SET_CAPTION( ::cId, cCaption )
return nil

METHOD OnChange( lOn ) CLASS TSwiftToggleStack
    ::hState["Value"] := lOn
    if ::bAction != nil
        Eval( ::bAction, lOn, Self )
    endif
return nil
