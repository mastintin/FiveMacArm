#include "FiveMac.ch"

// TSwiftControl: The base class for all SwiftUI controls in FiveMac
// Centralizes state management (Hash) and common lifecycle events.

CLASS TSwiftControl FROM TControl

    DATA hState INIT {=>}
    DATA cId         // Unique String ID used by the Swift Bridge
    DATA bAction     // Main action codeblock (OnClick, OnChange, etc.)

    ACCESS bChange       INLINE ::bAction
    ASSIGN bChange( b )  INLINE ::bAction := b

    ACCESS bOnChange     INLINE ::bAction
    ASSIGN bOnChange( b ) INLINE ::bAction := b

    ACCESS bOnClick      INLINE ::bAction
    ASSIGN bOnClick( b )  INLINE ::bAction := b

    ACCESS bOnAction     INLINE ::bAction
    ASSIGN bOnAction( b ) INLINE ::bAction := b

    // Unified Value Property
    ACCESS Value      INLINE ::hState["Value"]
    ASSIGN Value( x ) INLINE ::SetValue( x )

    // Color Accessors (Reactive)
    ACCESS nClrAcc          INLINE ::hState["AccentColor"]
    ASSIGN nClrAcc( c )     INLINE ::SetAccentColor( c, NIL )

    ACCESS nAlphaAcc        INLINE ::hState["AccentAlpha"]
    ASSIGN nAlphaAcc( a )   INLINE ::SetAccentColor( NIL, a )

    ACCESS nClrText         INLINE ::hState["TextColor"]
    ASSIGN nClrText( c )    INLINE ::SetTextColor( c, NIL )

    ACCESS nAlphaText       INLINE ::hState["TextAlpha"]
    ASSIGN nAlphaText( a )  INLINE ::SetTextColor( NIL, a )

    // Reactive Geometry: Synchronized with hState
    ACCESS nTop      INLINE ::hState["Top"]
    ASSIGN nTop( n ) INLINE ::SetPos( n, NIL )

    ACCESS nLeft      INLINE ::hState["Left"]
    ASSIGN nLeft( n ) INLINE ::SetPos( NIL, n )

    ACCESS nWidth      INLINE ::hState["Width"]
    ASSIGN nWidth( n ) INLINE ::SetSize( n, NIL )

    ACCESS nHeight      INLINE ::hState["Height"]
    ASSIGN nHeight( n ) INLINE ::SetSize( NIL, n )

    ACCESS nClrText          INLINE ::hState["TextColor"]
    ASSIGN nClrText( n )     INLINE ::SetTextColor( n, NIL )

    ACCESS nAlphaText        INLINE ::hState["TextAlpha"]
    ASSIGN nAlphaText( n )   INLINE ::SetTextColor( NIL, n )

    ACCESS nClrAcc           INLINE ::hState["AccentColor"]
    ASSIGN nClrAcc( n )      INLINE ::SetAccentColor( n, NIL )

    ACCESS nAlphaAcc         INLINE ::hState["AccentAlpha"]
    ASSIGN nAlphaAcc( n )    INLINE ::SetAccentColor( NIL, n )

    // Universal Checked Alias (for toggles, switches, checkboxes)
    ACCESS Checked    INLINE ::hState["Value"]
    ASSIGN Checked( l ) INLINE ::SetValue( l )

    // Universal Event Aliases
    ASSIGN OnChange( b ) INLINE ::bAction := b
    ASSIGN OnAction( b ) INLINE ::bAction := b
    ASSIGN OnClick( b )  INLINE ::bAction := b

    METHOD New( nTop, nLeft, nWidth, nHeight, cId )
    METHOD SetValue( x ) VIRTUAL  // To be implemented by subclasses
    METHOD GetValue()    VIRTUAL  // To be implemented by subclasses
    METHOD SetTextColor( nColor, nAlpha )
    METHOD SetAccentColor( nColor, nAlpha )
    METHOD SetPos( nTop, nLeft )
    METHOD SetSize( nWidth, nHeight )
    METHOD SetColor( nFg, nBg, nAlphaFg, nAlphaBg )
    
    // State Synchronization
    METHOD Sync()        
    METHOD Update( hNewState )
    
    // Lifecycle
    METHOD OnAppear()    INLINE ::Super:OnAppear()
    METHOD OnDisappear() INLINE ::Super:OnDisappear()
    
    METHOD End()

    // Registration
    METHOD Register( hPtr )
    METHOD Root()

ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, cId ) CLASS TSwiftControl
    ::hState  := { "Value" => nil, "Top" => nTop, "Left" => nLeft, "Width" => nWidth, "Height" => nHeight, ;
                   "TextColor" => 0, "TextAlpha" => 255, "AccentColor" => 0, "AccentAlpha" => 255 }
    ::cId     := hb_defaultValue( cId, "" )
return Self

METHOD Register( hPtr ) CLASS TSwiftControl
    if !Empty( hPtr )
        ::hWnd := hPtr
        ::cId  := SW_GET_ID( ::hWnd )
        SwiftRegisterItem( ::cId, Self )
    endif
return Self

METHOD SetTextColor( nColor, nAlpha ) CLASS TSwiftControl
     if nColor == NIL ; nColor := ::nClrText  ; endif
     if nAlpha == NIL ; nAlpha := ::nAlphaText; endif
     ::hState["TextColor"] := nColor
     ::hState["TextAlpha"] := nAlpha
     sd_sw_set_text_colors_rgba( ::cId, nColor, nAlpha )
return self

METHOD SetAccentColor( nColor, nAlpha ) CLASS TSwiftControl
     if nColor == NIL ; nColor := ::nClrAcc  ; endif
     if nAlpha == NIL ; nAlpha := ::nAlphaAcc; endif
     ::hState["AccentColor"] := nColor
     ::hState["AccentAlpha"] := nAlpha
     sd_sw_set_colors_rgba( ::cId, nColor, nAlpha )
return self

METHOD SetPos( nTop, nLeft ) CLASS TSwiftControl
    if nTop != NIL  ; ::hState["Top"]  := nTop  ; endif
    if nLeft != NIL ; ::hState["Left"] := nLeft ; endif
    if !Empty( ::cId )
       sw_set_pos( ::cId, nTop, nLeft )
    endif
return nil

METHOD SetSize( nWidth, nHeight ) CLASS TSwiftControl
    if nWidth != NIL  ; ::hState["Width"]  := nWidth ; endif
    if nHeight != NIL ; ::hState["Height"] := nHeight ; endif
    if !Empty( ::cId )
       sw_set_size( ::cId, nWidth, nHeight )
    endif
return nil

METHOD SetColor( nFg, nBg, nAlphaFg, nAlphaBg ) CLASS TSwiftControl
    if nFg != NIL ; ::SetTextColor( nFg, nAlphaFg )  ; endif
    if nBg != NIL ; ::SetAccentColor( nBg, nAlphaBg ); endif
return self

METHOD Sync() CLASS TSwiftControl
    local cJson := hb_jsonEncode( ::hState )
    if !Empty( ::cId )
       sw_update_state( ::cId, cJson ) 
    endif
return nil

METHOD Update( hNewState ) CLASS TSwiftControl
    if ValType( hNewState ) == "H"
       hb_HMerge( ::hState, hNewState )
    endif
return nil

METHOD Root() CLASS TSwiftControl
return Self

METHOD End() CLASS TSwiftControl
    SwiftUnregisterItem( ::cId )
    ::hState := {=>}
    ::cId    := ""
return ::Super:End()
