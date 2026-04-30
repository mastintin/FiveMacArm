#include "FiveMac.ch"

// Estilos estructurales del sistema operativo (Button Styles)
static s_aSwiftSystemStyles := { "prominent", "bordered", "plain", "link", "borderless" }

CLASS TSwiftButton FROM TSwiftControl

    ACCESS Caption      INLINE ::hState["Caption"]
    ASSIGN Caption( c ) INLINE ::SetText( c )

    ACCESS IsGlass     INLINE ::hState["IsGlass"]
    ASSIGN IsGlass( l ) INLINE ::SetGlass( l )
    
    ASSIGN OnClick( b ) INLINE ::bAction := b
    ASSIGN OnAction( b ) INLINE ::bAction := b

    ACCESS Style         INLINE ::hState["style"]
    ASSIGN Style( c )    INLINE ::SetStyle( c )

    ACCESS TextColor      INLINE ::hState["textcolor"]
    ASSIGN TextColor( c ) INLINE ::SetTextColor( c, NIL )

    ACCESS BgColor        INLINE ::hState["bgcolor"]
    ASSIGN BgColor( c )   INLINE ::SetAccentColor( c, NIL )

    METHOD New( nTop, nCol, nWidth, nHeight, cPrompt, oWnd, bAction, nAutoResize, cId, lGlass, lProminent )
    METHOD OnAction()
    METHOD SetRadius( nRadius )
    METHOD SetPadding( nPadding )
    METHOD SetGlass( lGlass )
    METHOD SetText( cText )
    METHOD SetImage( cImage ) 
    METHOD SetAutoResize( nAutoResize ) INLINE  if(nAutoResize != 0 , SWIFTAUTORESIZE( ::hWnd, nAutoResize ), )
    METHOD SetTextColor( nColor, nAlpha )
    METHOD SetAccentColor( nColor, nAlpha )
    METHOD SetStyle( cStyle )
    METHOD  selectStyle(cStyle)    
    METHOD End()
      
ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, cPrompt, oWnd, bAction, nAutoResize, cId, lGlass ) CLASS TSwiftButton

    DEFAULT nWidth := 90, nHeight := 30, oWnd := GetWndDefault(), cPrompt := "SwiftBtn", nAutoResize := 0, lGlass := .F.

    ::Super:New( nTop, nLeft, nWidth, nHeight, cId )
    
    
    ::bAction = bAction
    ::oWnd    = oWnd
    
    ::hState["caption"]      := cPrompt
    ::hState["isglass"]      := lGlass
    ::hState["cornerRadius"] := 8
    ::hState["padding"]      := 0
    ::hState["imageName"]    := ""
   
    ::hState["textcolor"] := ::InitialColorToHex( "primary", 100 )
    ::hState["bgcolor"] := ::InitialColorToHex( "clear", 100 )
    ::selectStyle( "prominent" )
  
    

   
    ::Register( SD_SWIFT_BUTTON_CREATE( nTop, nLeft, nWidth, nHeight, hb_JsonEncode( ::hState ), oWnd:hWnd, ::cId ) )

    // if lGlass
    //     ::SetGlass( lGlass )
    // endif

    oWnd:AddControl( Self )

    return Self

return nil

METHOD SetText( cText ) CLASS TSwiftButton
    ::hState["Caption"] := cText
    SD_BTN_SET_TEXT( ::cId, cText )
return nil

METHOD OnAction() CLASS TSwiftButton
   
    if ::bAction != nil
        Eval( ::bAction, Self )
    endif

return nil

METHOD SetRadius( nRadius ) CLASS TSwiftButton
    SD_BTN_SET_RADIUS( ::cId, nRadius )
return nil

METHOD SetPadding( nPadding ) CLASS TSwiftButton
    SD_BTN_SET_PADDING( ::cId, nPadding )
return nil

METHOD SetGlass( lGlass ) CLASS TSwiftButton
    DEFAULT lGlass := .T.
    ::hState["IsGlass"] := lGlass
    SD_BTN_SET_GLASS( ::cId, lGlass )
return nil

METHOD SetImage( cImage ) CLASS TSwiftButton
    if cImage != nil
        SD_BTN_SET_IMAGE( ::cId, cImage )
    endif
return nil

METHOD SetTextColor( nColor, nAlpha ) CLASS TSwiftButton
    local cHex 
    
    if nColor != NIL 
        cHex := ::InitialColorToHex( nColor, nAlpha )
        ::hState["textcolor"] := cHex 
        SD_BTN_SET_FG( ::cId, cHex )
    endif
return self

METHOD SetAccentColor( nColor, nAlpha ) CLASS TSwiftButton
    local cHex 
    
    if nColor != NIL 
        cHex := ::InitialColorToHex( nColor, nAlpha )
        ::hState["bgcolor"] := cHex 
        SD_BTN_SET_BG( ::cId, cHex )
    endif
return self

METHOD SetStyle( cStyle ) CLASS TSwiftButton
    if  ::selectStyle( cStyle )
        SD_BTN_SET_STYLE( ::cId, cStyle )
    endif
return self

METHOD selectStyle( cStyle ) CLASS TSwiftButton
    if ValType( cStyle ) == "C" .and. AScan( s_aSwiftSystemStyles, lower( cStyle ) ) > 0
        ::hState["style"] := lower( cStyle )
        return .t.
    endif
Return .f.       


METHOD End() CLASS TSwiftButton
    if !Empty( ::hWnd )
        SD_BTN_DESTROY( ::cId, ::hWnd )
        ::bAction := nil
    endif
return ::Super:End()
