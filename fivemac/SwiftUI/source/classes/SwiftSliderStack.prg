#include "FiveMac.ch"

// Class for Slider controls specifically designed to live inside SwiftUI Stacks (VStack, HStack, ZStack)
// These controls do NOT have their own NSView/hWnd; they are managed by the Stack's RecursiveItemView.

CLASS TSwiftSliderStack FROM TSwiftStackItem

    ACCESS Value        INLINE ::hState["Value"]
    ASSIGN Value( n )   INLINE ::SetValue( n )

    ACCESS Min           INLINE ::hState["Min"]
    ASSIGN Min( n )      INLINE ::hState["Min"] := n

    ACCESS Max           INLINE ::hState["Max"]
    ASSIGN Max( n )      INLINE ::hState["Max"] := n

    ACCESS Glass         INLINE ::hState["Glass"]
    ASSIGN Glass( l )    INLINE ::hState["Glass"] := l

    DATA hState INIT {=>}

    METHOD New( oOwner, nVal, nMin, nMax, lGlass, cId, bAction )
    METHOD SetValue( nVal )
    METHOD OnChange( nVal )

ENDCLASS

METHOD New( oOwner, nVal, nMin, nMax, lGlass, cId, bAction ) CLASS TSwiftSliderStack
    
    local oRoot := oOwner:Root()
    local cParentId := If( oOwner:IsKindOf( "TSWIFTSTACKITEM" ), oOwner:cId, nil )

    if oRoot == nil ; oRoot := oOwner ; endif

    DEFAULT nVal := 0, nMin := 0, nMax := 100, lGlass := .F.

    if oRoot:IsKindOf( "TSWIFTVSTACK" )
       cId := SD_VSTK_ADD_SLIDER( oRoot:cId, cId, nVal, nMin, nMax, lGlass, cParentId )
    else
       cId := SD_ZSTK_ADD_SLIDER( oRoot:cId, cId, nVal, nMin, nMax, lGlass, cParentId )
    endif

    ::Super:New( cId, oOwner )

    ::hState := {=>}
    ::hState["Value"] := nVal
    ::hState["Min"]   := nMin
    ::hState["Max"]   := nMax
    ::hState["Glass"] := lGlass

    if bAction != nil ; ::bAction := bAction ; endif

return Self

METHOD SetValue( nVal ) CLASS TSwiftSliderStack
    if ::hState["Value"] != nVal
        ::hState["Value"] := nVal
        SD_SLD_SET_VALUE( ::cId, nVal )
        if ::bAction != nil
            Eval( ::bAction, nVal, Self )
        endif
    endif
return nil

METHOD OnChange( nVal ) CLASS TSwiftSliderStack
    ::hState["Value"] := nVal
    if ::bAction != nil
        Eval( ::bAction, nVal, Self )
    endif
return nil
