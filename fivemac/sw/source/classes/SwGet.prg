#include "swfive.ch"
 
 //----------------------------------------------------------------------------//
  
 CLASS SwGet FROM TSwiftControl
  
    ACCESS cPicture         INLINE ::hState["picture"]
    ASSIGN cPicture( c )    INLINE ( ::hState["picture"] := c, ::Apply( { "picture" => c } ) )
  
    DATA bValid
    DATA lSecure    INIT .F.
  
    ACCESS Value      INLINE ::hState["text"]
    ASSIGN Value( u ) INLINE ( ::hState["text"] := hb_ValToStr( u ), ::Apply( { "text" => ::hState["text"] } ) )
 
    ACCESS bAction          INLINE hb_HGetDef( ::hState, "action", nil )
    ASSIGN bAction( u )     INLINE ( ::hState["action"] := u,;
       ::hState["interactive"] := !Empty( u ) .or. !Empty( ::bPipeline ),;
       ::Apply( { "interactive" => ::hState["interactive"] } ) )
   
    ACCESS bPipeline        INLINE hb_HGetDef( ::hState, "pipeline", nil )
    ASSIGN bPipeline( u )   INLINE ( ::hState["pipeline"] := u,;
       ::hState["interactive"] := !Empty( u ) .or. !Empty( ::bAction ),;
       ::Apply( { "interactive" => ::hState["interactive"] } ) )
 
    ACCESS lScroll          INLINE hb_HGetDef( ::hState, "hasscroll", .F. )
    ASSIGN lScroll( l )     INLINE ( ::hState["hasscroll"] := l, ::Apply( "hasscroll", l ) )

    ACCESS cColor           INLINE hb_HGetDef( ::hState, "color", "" )
    ASSIGN cColor( c )      INLINE ( ::hState["color"] := c, ::Apply( "color", c ) )

    ACCESS cBackColor       INLINE hb_HGetDef( ::hState, "backcolor", "" )
    ASSIGN cBackColor( c )  INLINE ( ::hState["backcolor"] := c, ::Apply( "backcolor", c ) )

    ACCESS cVibrance        INLINE hb_HGetDef( ::hState, "vibrance", "" )
    ASSIGN cVibrance( c )   INLINE ( ::hState["vibrance"] := c, ::Apply( "vibrance", c ) )

    ACCESS cIcon            INLINE hb_HGetDef( ::hState, "icon", "" )
    ASSIGN cIcon( c )       INLINE ( ::hState["icon"] := c, ::Apply( "icon", c ) )

    ACCESS cIconColor       INLINE hb_HGetDef( ::hState, "iconcolor", "" )
    ASSIGN cIconColor( c )  INLINE ( ::hState["iconcolor"] := c, ::Apply( "iconcolor", c ) )

    ACCESS nShadow          INLINE hb_HGetDef( ::hState, "shadow", 0 )
    ASSIGN nShadow( n )     INLINE ( ::hState["shadow"] := n, ::Apply( "shadow", n ) )

    ACCESS nShadowColor     INLINE hb_HGetDef( ::hState, "shadowcolor", "" )
    ASSIGN nShadowColor( c ) INLINE ( ::hState["shadowcolor"] := c, ::Apply( "shadowcolor", c ) )

    ACCESS nCornerRadius    INLINE hb_HGetDef( ::hState, "corner", 10 )
    ASSIGN nCornerRadius( n ) INLINE ( ::hState["corner"] := n, ::Apply( "corner", n ) )

    ACCESS cPrompt          INLINE hb_HGetDef( ::hState, "prompt", "" )
    ASSIGN cPrompt( c )     INLINE ( ::hState["prompt"] := c, ;
                                     ::nHeight := 38 + IIf( Empty( c ), 0, 20 ), ; 
                                     ::Apply( { "prompt" => c, "height" => ::nHeight } ) )

    ACCESS cPromptColor     INLINE hb_HGetDef( ::hState, "promptcolor", "" )
    ASSIGN cPromptColor( c ) INLINE ( ::hState["promptcolor"] := c, ::Apply( "promptcolor", c ) )

    ACCESS nPromptSize      INLINE hb_HGetDef( ::hState, "promptsize", 12 )
    ASSIGN nPromptSize( n ) INLINE ( ::hState["promptsize"] := n, ::Apply( "promptsize", n ) )

    ACCESS lReadOnly        INLINE hb_HGetDef( ::hState, "readonly", .F. )
    ASSIGN lReadOnly( l )   INLINE ( ::hState["readonly"] := l, ::Apply( "readonly", l ) )

    ACCESS lInvalid         INLINE hb_HGetDef( ::hState, "invalid", .F. )
    ASSIGN lInvalid( l )    INLINE ( ::hState["invalid"] := l, ::Apply( "invalid", l ) )

    ACCESS nAlignment       INLINE hb_HGetDef( ::hState, "alignment", 0 )
    ASSIGN nAlignment( n )  INLINE ( ::hState["alignment"] := n, ::Apply( "alignment", n ) )
 
    METHOD _event( c )      INLINE If( c == "valid", ::OnValid(), )

    METHOD New( nTop, nLeft, nWidth, nHeight, uValue, oWnd, bAction, cPicture, bValid, lSecure, cPlaceholder, cPrompt, cId )
    METHOD SetText( cText )
    METHOD OnAction( cNewText )
    METHOD OnValid()
    METHOD Update( hNewState )
    
    METHOD SelectAll()    INLINE ::Apply( "selectall", .T. )
    METHOD GoToStart()    INLINE ::Apply( "selectstart", .T. )
    METHOD GoToEnd()      INLINE ::Apply( "selectend", .T. )
    METHOD GoToPos( n )   INLINE ::Apply( "gotopos", n )
    METHOD SetFocus()     INLINE ::Apply( "focus", .T. )
  
 ENDCLASS
  
 //----------------------------------------------------------------------------//
  
 METHOD New( nTop, nLeft, nWidth, nHeight, uValue, oWnd, bAction, cPicture, bValid, lSecure, cPlaceholder, cPrompt, cId ) CLASS SwGet
  
    DEFAULT nWidth := 120, nHeight := 38
    DEFAULT uValue := "", lSecure := .F., cPlaceholder := "", cPrompt := ""
    
    if !Empty( cPrompt )
       nHeight += 20
    endif

    ::Super:New( nTop, nLeft, nWidth, nHeight )
    
    if !Empty( cId )
       ::cId := cId
    endif

    ::oWnd     := oWnd
    ::bValid   := bValid
    ::cPicture := cPicture
    ::lSecure  := lSecure
  
    ::hState["text"]        := hb_ValToStr( uValue )
    ::hState["picture"]     := cPicture
    ::hState["issecure"]    := lSecure
    ::hState["placeholder"] := cPlaceholder
    ::hState["prompt"]      := cPrompt
    ::hState["hasscroll"]   := .F.
    ::hState["interactive"] := .F.
    ::hState["type"]        := 14
    
    ::bAction  := bAction
     
    if hb_IsObject( oWnd )
       ::hState["parentid"] := oWnd:cId
    endif
  
    ::Create()
  
 return Self
  
 //----------------------------------------------------------------------------//
  
 METHOD SetText( cText ) CLASS SwGet
    ::Value := cText
 return nil
  
 //----------------------------------------------------------------------------//
  
 METHOD OnAction( cNewText ) CLASS SwGet
    ::hState["text"] := cNewText
    SW_LOG( "🚢 [SwGet:OnAction] ID: " + ::cId + " Val: [" + hb_ValToStr( cNewText ) + "]" )
    if !Empty( ::bPipeline )
       WITH OBJECT Sw_GetProxy()
          :Pipeline( ::bPipeline )
       END
    elseif !Empty( ::bAction )
       Eval( ::bAction, cNewText, Self )
    endif
 return nil
  
 //----------------------------------------------------------------------------//
  
 METHOD OnValid() CLASS SwGet
    local lRet := .T.
    SW_LOG( "🚢 [SwGet:OnValid] Checking ID: " + ::cId + " Val: [" + hb_ValToStr( ::Value ) + "]" )
    if ::bValid != nil
       lRet := Eval( ::bValid, Self )
       SW_LOG( "   -> Result: " + hb_ValToStr( lRet ) )
       ::lInvalid := !lRet
    endif
 return lRet
 
 //----------------------------------------------------------------------------//
 
 METHOD Update( hNewState ) CLASS SwGet
    local cEvent := hb_HGetDef( hNewState, "event", "" )
    
    if cEvent == "valid"
       ::OnValid()
    endif
    
 return ::Super:Update( hNewState )
