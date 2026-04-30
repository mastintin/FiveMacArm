#include "swfive.ch"

static aMenuStack := {}

// -------------------------------------------------------------------------- //
// Clase para el Menú Principal de la Aplicación (Barra superior macOS)
// -------------------------------------------------------------------------- //

CLASS TSwAppMenu
    DATA aItems INIT {}
    
    METHOD New() CONSTRUCTOR
    METHOD AddItem( oItem ) INLINE aAdd( ::aItems, oItem )
    METHOD ToHash()
    METHOD Activate()
ENDCLASS

METHOD New() CLASS TSwAppMenu
return Self

METHOD ToHash() CLASS TSwAppMenu
    local aData := {}
    local oItem
    for each oItem in ::aItems
        aAdd( aData, oItem:ToHash() )
    next
return aData

METHOD Activate() CLASS TSwAppMenu
    local hData := { "type" => SW_TYPE_APPMENU, "id" => "mainmenu", "items" => ::ToHash() }
    SW_LOG( "🚢 [TSwAppMenu:Activate] Enviando mensaje de creación para MainMenu" )
    SD:Create( hData )
return nil

// -------------------------------------------------------------------------- //

CLASS TSwAppMenuItem
    DATA cId
    DATA cCaption
    DATA cShortcut
    DATA bAction
    DATA oSubMenu
    
    METHOD New( cCaption, bAction, cShortcut, oSubMenu ) CONSTRUCTOR
    METHOD ToHash()
    METHOD OnAction()
    METHOD Update( hProps )
ENDCLASS

METHOD New( cCaption, bAction, cShortcut, oSubMenu ) CLASS TSwAppMenuItem
    ::cId       := Lower( hb_uuid() )
    ::cCaption  := cCaption
    ::bAction   := bAction
    ::cShortcut := hb_defaultValue( cShortcut, "" )
    ::oSubMenu  := oSubMenu
    
    // Registramos en el sistema global para recibir eventos
    SwiftRegisterItem( ::cId, Self )
return Self

METHOD ToHash() CLASS TSwAppMenuItem
    local hData := { "caption" => ::cCaption, "id" => ::cId, "shortcut" => ::cShortcut }
    if ::oSubMenu != nil
        hData["items"] := ::oSubMenu:ToHash()
    endif
return hData

METHOD OnAction() CLASS TSwAppMenuItem
    if ::bAction != nil
        Eval( ::bAction, Self )
    endif
return nil

METHOD Update( hProps ) CLASS TSwAppMenuItem
    if hb_HHasKey( hProps, "event" ) .and. hProps["event"] == "click"
       ::OnAction()
    endif
return nil

// -------------------------------------------------------------------------- //
// Funciones auxiliares para comandos MENU / ENDMENU
// -------------------------------------------------------------------------- //
// -------------------------------------------------------------------------- //

function sw_MenuStart()
   local oMenu := TSwAppMenu():New()
   aAdd( aMenuStack, oMenu )
return oMenu

function sw_MenuEnd()
   local oMenu
   
   // Limpiamos items sueltos en el stack hasta encontrar el inicio del menú actual
   while Len( aMenuStack ) > 0 .and. ! aTail( aMenuStack ):IsKindOf( "TSWAPPMENU" )
      hb_ADel( aMenuStack, Len( aMenuStack ) )
      asize( aMenuStack, Len( aMenuStack ) - 1 )
   enddo

   if Len( aMenuStack ) == 0 ; return nil ; endif

   // Obtenemos el menú y lo sacamos del stack
   oMenu := aTail( aMenuStack )
   hb_ADel( aMenuStack, Len( aMenuStack ) )
   asize( aMenuStack, Len( aMenuStack ) - 1 )
   
   // Si al sacar el menú, lo que queda en el tail es un MenuItem,
   // significa que este menú es un submenú de ese item.
   if Len( aMenuStack ) > 0 .and. aTail( aMenuStack ):IsKindOf( "TSWAPPMENUITEM" )
      aTail( aMenuStack ):oSubMenu := oMenu
      // Una vez asignado el submenú, el MenuItem ya puede salir del stack
      hb_ADel( aMenuStack, Len( aMenuStack ) )
      asize( aMenuStack, Len( aMenuStack ) - 1 )
   endif
   
return oMenu

function sw_MenuItem( cPrompt, bAction, cShortcut )
   local oMenu, oItem, n
   
   // Buscamos el menú contenedor (el último TSWAPPMENU en el stack)
   for n := Len( aMenuStack ) to 1 step -1
       if aMenuStack[ n ]:IsKindOf( "TSWAPPMENU" )
          oMenu := aMenuStack[ n ]
          exit
       endif
   next

   oItem := TSwAppMenuItem():New( cPrompt, bAction, cShortcut )
   
   if oMenu != nil
      oMenu:AddItem( oItem )
   endif
   
   // Metemos el item en el stack. Si la siguiente línea es un MENU, 
   // sw_MenuEnd sabrá que este item es el padre.
   aAdd( aMenuStack, oItem )
   
return oItem

function sw_MenuItemStackFix( cPrompt, bAction, cShortcut )
   // Si el tail es un MenuItem, lo sacamos (significa que no tuvo un submenú anidado)
   if Len( aMenuStack ) > 0 .and. aTail( aMenuStack ):IsKindOf( "TSWAPPMENUITEM" )
      hb_ADel( aMenuStack, Len( aMenuStack ) )
      asize( aMenuStack, Len( aMenuStack ) - 1 )
   endif
   return sw_MenuItem( cPrompt, bAction, cShortcut )
