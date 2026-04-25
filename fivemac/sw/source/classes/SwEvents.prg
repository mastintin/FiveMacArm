#include "SwFive.ch"

// ---------------------------------------------------------
// PROCESADOR DE EVENTOS HSW
// Llamado periódicamente desde el Hilo 1 de Harbour
// ---------------------------------------------------------
function SW_PROCESS_EVENTS()
   local cJson := SW_GET_EVENTS()
   local aEvents, hEvent
   local cId, cType, oItem
   
   if !Empty( cJson ) .and. cJson != "[]"
      aEvents := hb_jsonDecode( cJson )
      
      for each hEvent in aEvents
         cId   := hEvent[ "id" ]
         cType := hEvent[ "event" ]
         
         // Buscamos el objeto PRG en el registro global
         oItem := SwiftGetItem( cId )
         
         if !Empty( oItem )
            do case
               case cType == "call"
                  if __objHasMethod( oItem, "OnAction" )
                     oItem:OnAction()
                  endif
                  
               case cType == "change"
                  if __objHasMethod( oItem, "Update" )
                     oItem:Update( hEvent )
                  endif
                  
               otherwise
                  if __objHasMethod( oItem, "Update" )
                     oItem:Update( hEvent )
                  endif
            endcase
         else
            // Si el ID es una función global (como un callback directo)
            if cType == "call"
               if Type( cId + "()" ) == "UI"
                  DoInternalCall( cId, hEvent )
               endif
            endif
         endif
      next
   endif
   
return nil

static function DoInternalCall( cId, hEvent )
   local aArgs := {}
   local i := 1
   while hb_HHasKey( hEvent, "p" + AllTrim(Str(i)) )
      aAdd( aArgs, hEvent[ "p" + AllTrim(Str(i)) ] )
      i++
   end
   hb_ExecFromArray( cId, aArgs )
return nil
