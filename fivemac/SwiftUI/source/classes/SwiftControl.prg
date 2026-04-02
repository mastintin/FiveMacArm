#include "FiveMac.ch"

// TSwiftControl: The base class for all SwiftUI controls in FiveMac
// Centralizes state management (Hash) and common lifecycle events.

CLASS TSwiftControl FROM TControl

    DATA hState INIT {=>}
    DATA cId         // Unique String ID used by the Swift Bridge
    DATA bAction     // Main action codeblock (OnClick, OnChange, etc.)

    // Unified Value Property
    ACCESS Value      INLINE ::hState["Value"]
    ASSIGN Value( x ) INLINE ::Set( x )

    // Reactive Geometry: Synchronized with hState
    ACCESS nTop      INLINE ::hState["Top"]
    ASSIGN nTop( n ) INLINE ::hState["Top"] := n

    ACCESS nLeft      INLINE ::hState["Left"]
    ASSIGN nLeft( n ) INLINE ::hState["Left"] := n

    ACCESS nWidth      INLINE ::hState["Width"]
    ASSIGN nWidth( n ) INLINE ::hState["Width"] := n

    ACCESS nHeight      INLINE ::hState["Height"]
    ASSIGN nHeight( n ) INLINE ::hState["Height"] := n

    // Universal Checked Alias (for toggles, switches, checkboxes)
    ACCESS Checked    INLINE ::hState["Value"]
    ASSIGN Checked( l ) INLINE ::Set( l )

    // Universal Event Aliases
    ASSIGN OnChange( b ) INLINE ::bAction := b
    ASSIGN OnAction( b ) INLINE ::bAction := b
    ASSIGN OnClick( b )  INLINE ::bAction := b

    METHOD New( nTop, nLeft, nWidth, nHeight )
    METHOD Set( x )      VIRTUAL  // To be implemented by subclasses
    METHOD Get()         VIRTUAL  // To be implemented by subclasses
    
    // State Synchronization
    METHOD Sync()        
    METHOD Update( hNewState )
    
    // Lifecycle
    METHOD OnAppear()    INLINE ::Super:OnAppear()
    METHOD OnDisappear() INLINE ::Super:OnDisappear()
    
    METHOD End()

ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight ) CLASS TSwiftControl
    ::hState  := { "Value" => nil, "Top" => nTop, "Left" => nLeft, "Width" => nWidth, "Height" => nHeight }
    ::cId     := ""
return Self

METHOD Sync() CLASS TSwiftControl
    local cJson := hb_jsonEncode( ::hState )
    // This requires a generic bridge in Swift to update full states
    // SD_SW_UPDATE_STATE( ::cId, cJson ) 
return nil

METHOD Update( hNewState ) CLASS TSwiftControl
    if ValType( hNewState ) == "H"
       hb_HMerge( ::hState, hNewState )
    endif
return nil

METHOD End() CLASS TSwiftControl
    SwiftUnregisterItem( ::cId )
    ::hState := {=>}
    ::cId    := ""
return ::Super:End()
