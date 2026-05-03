#include "SwFive.ch"

CLASS TSwWindow FROM TSwiftControl

   DATA lVisible  INIT .f.
    
   DATA bOnEnd
   DATA bOnInit
   DATA bOnToolbar

   ACCESS cTitle    INLINE ::hState["title"]
   ASSIGN cTitle(c) INLINE ( ::hState["title"] := c, ::Apply( { "title" => c } ) )

   ACCESS cBackColor    INLINE hb_HGetDef( ::hState, "backcolor", "" )
   ASSIGN cBackColor(c) INLINE ( ::hState["backcolor"] := c, ::Apply( { "backcolor" => c } ) )

   ACCESS lCenter     INLINE hb_HGetDef( ::hState, "center", .f. )
   ASSIGN lCenter(l)  INLINE ( ::hState["center"] := l, if( l, ::Apply( { "center" => .t. } ), ) )
    

   METHOD New( cTitle, nWidth, nHeight, cId, oParent ) CONSTRUCTOR
   METHOD Activate( lModal )
   METHOD End()
   METHOD Close() INLINE ::End()
   METHOD Center() INLINE ::lCenter := .t.
   METHOD Update( hProps )
   METHOD SetToolbar( aButtons )
   METHOD AddButtonBar( cId, cLabel, cIcon, bAction )
    
   METHOD Disable() INLINE SD:Apply( ::cId, { "interactive" => .f. } )
   METHOD Enable()  INLINE SD:Apply( ::cId, { "interactive" => .t. } )

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( cTitle, nWidth, nHeight, cId, oParent ) CLASS TSwWindow

   DEFAULT nWidth := 500, nHeight := 400
    
   // Llamamos a la base para inicializar hState e ID de forma estándar
   ::Super:New( 0, 0, nWidth, nHeight, cId )

   ::oParent         := oParent
   ::hState["title"] := cTitle
   ::hState["type"]  := 100
   ::hState["hastoolbar"] := .F.
   ::hState["toolbarItems"] := {} // Inicializamos el array interno
 
   // CREACIÓN POR MENSAJERÍA ASÍNCRONA (Fire-and-Forget)
   SDS:Create( ::hState )
  
return self

//----------------------------------------------------------------------------//

METHOD Activate( lModal ) CLASS TSwWindow

   hb_default( @lModal, .f. )
   ::lVisible := .t.
   ::hState["modal"] := lModal

   if lModal
      SDS:Apply( ::cId, { "modal" => .t. } ) 
   endif

   // Si hemos añadido botones al toolbar antes de activar, los enviamos ahora
   if hb_HGetDef( ::hState, "hastoolbar", .f. )
      ::SetToolbar()
   endif

   // Notificamos a Swift que debe mostrar la ventana
   SDS:Apply( ::cId, { "visible" => .t. } )
 
   // BUCLE DE EVENTOS HSW (Thread 1)
   while ::lVisible
      SW_PROCESS_EVENTS()
      hb_idleSleep( 0.01 )
   end

RETURN nil

//----------------------------------------------------------------------------//

METHOD End() CLASS TSwWindow
   if ::bOnEnd != nil
      Eval( ::bOnEnd, Self )
   endif
   ::lVisible := .f.
   ::Apply( { "close" => .t. } )
return nil

//----------------------------------------------------------------------------//

METHOD Update( hProps ) CLASS TSwWindow
   local cEvent := hb_HGetDef( hProps, "event", "" )
   local cItem  := hb_HGetDef( hProps, "item", "" )
   local nAt

   if hb_HHasKey( hProps, "close" )
      ::End()
   elseif cEvent == "init"
      if !Empty( ::bOnInit )
         Eval( ::bOnInit, Self )
      endif
   elseif cEvent == "toolbar"
      // 1. Buscar acción específica del botón por su UUID interno
      nAt := AScan( ::hState[ "toolbarItems" ], { | h | h["uuid"] == cItem } )
      if nAt > 0 .and. hb_HHasKey( ::hState[ "toolbarItems" ][ nAt ], "action" )
         Eval( ::hState[ "toolbarItems" ][ nAt ][ "action" ], Self )
      endif
      
      // 2. Ejecutar bOnToolbar general si existe (pasando el ID original del usuario)
      if !Empty( ::bOnToolbar )
         Eval( ::bOnToolbar, if( nAt > 0, ::hState["toolbarItems"][nAt]["id"], cItem ), Self )
      endif
   endif
return nil

//----------------------------------------------------------------------------//

METHOD SetToolbar( aButtons ) CLASS TSwWindow
   local aViewItems := {}
   local hItem
   
   // Si nos pasan un array, actualizamos el estado interno (por compatibilidad)
   if !Empty( aButtons )
      ::hState["toolbarItems"] := aButtons
   endif
   
   // Procesamos los botones inyectando hb_uuid() si no lo tienen
   for each hItem in ::hState["toolbarItems"]
       if !hb_HHasKey( hItem, "uuid" )
          hItem["uuid"] := hb_uuid() 
       endif
       
       // Preparamos la versión para Swift usando el UUID como ID de comunicación
       AAdd( aViewItems, { "id"    => hItem["uuid"], ;
                           "label" => hItem["label"], ;
                           "icon"  => hItem["icon"] } )
   next

   ::hState["hastoolbar"] := .T.
   
   // Aplicamos los datos visuales a Swift
   ::Apply( { "hastoolbar" => .T., "toolbarItems" => aViewItems } )
return nil

//----------------------------------------------------------------------------//

METHOD AddButtonBar( cId, cLabel, cIcon, bAction ) CLASS TSwWindow
   local hItem := { "id" => cId, "label" => cLabel, "icon" => cIcon, "action" => bAction, "uuid" => hb_uuid() }
   
   ::hState["hastoolbar"] := .T.
   AAdd( ::hState["toolbarItems"], hItem )
   
   // Si la ventana ya está activa, refrescamos el toolbar inmediatamente
   if ::lVisible
      ::SetToolbar()
   endif
return nil

//----------------------------------------------------------------------------//

//----------------------------------------------------------------------------//
