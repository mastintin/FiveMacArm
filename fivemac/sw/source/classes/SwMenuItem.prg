#include "swfive.ch"

#define SW_TYPE_MENUITEM 26

CLASS TSwMenuItem FROM TSwiftControl

    ACCESS Caption      INLINE ::hState["caption"]
    ASSIGN Caption( c ) INLINE ( ::hState["caption"] := c, ::Apply( "caption", c ) )

    ACCESS bAction          INLINE hb_HGetDef( ::hState, "action", nil )
    ASSIGN bAction( u )     INLINE ( ::hState["action"] := u,;
                                     ::hState["interactive"] := iif( !Empty( u ), 1, 0 ),;
                                     ::Apply( "interactive", ::hState["interactive"] ) )

    ACCESS cIcon            INLINE hb_HGetDef( ::hState, "icon", "" )
    ASSIGN cIcon( c )       INLINE ( ::hState["icon"] := c, ::Apply( "icon", c ) )

    ACCESS cShortcut        INLINE hb_HGetDef( ::hState, "shortcut", "" )
    ASSIGN cShortcut( c )   INLINE ( ::hState["shortcut"] := c, ::Apply( "shortcut", c ) )

    METHOD New( nRow, nCol, oMenu, cPrompt, bAction, cId )
    METHOD OnAction()
    METHOD Update( hProps )

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nRow, nCol, oMenu, cPrompt, bAction, cId ) CLASS TSwMenuItem

    DEFAULT cPrompt := "Item"
    
    ::Super:New( nRow, nCol, 0, 0, cId, 0 )
    
    if hb_IsObject( oMenu )
       ::oWnd               := if( __ObjHasData( oMenu, "oWnd" ), oMenu:oWnd, oMenu )
       ::hState["parentid"] := if( __ObjHasData( oMenu, "cId"  ), oMenu:cId , "NONE" )
    endif

    ::hState["caption"] := cPrompt
    ::hState["type"]    := SW_TYPE_MENUITEM
    ::hState["interactive"] := 1

    ::bAction  := bAction
   
    ::Create()
    
return Self

//----------------------------------------------------------------------------//

METHOD OnAction() CLASS TSwMenuItem
   if !Empty( ::bAction )
      Eval( ::bAction, Self )
   endif
return nil

//----------------------------------------------------------------------------//

METHOD Update( hProps ) CLASS TSwMenuItem
   if hb_HHasKey( hProps, "event" ) .and. hProps["event"] == "click"
      ::OnAction()
   endif
return nil
