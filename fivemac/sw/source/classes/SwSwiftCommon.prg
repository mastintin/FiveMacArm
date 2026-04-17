#include "FiveMac.ch"

static s_hRegistry := {=>}
static s_aControls := {}
static s_lInSync   := .F.
static s_cSyncID   := ""

// -------------------------------------------------------------------------------- //

function Sw_IsSyncing() ; return s_lInSync

function Sw_CurrentSyncID() 
    if ValType( s_cSyncID ) != "C"
        s_cSyncID := ""
    endif
return s_cSyncID

// -------------------------------------------------------------------------------- //

function SwApp()
    static oApp
    if oApp == nil
        oApp := TSwApplication():New()
    endif
return oApp

// -------------------------------------------------------------------------------- //

function SwiftCountItems()
return Len( s_hRegistry )

function SwiftRegisterItem( cId, oItem )

    if s_hRegistry == nil
        s_hRegistry = {=>}
    endif

    if Empty( cId ) 
        return nil
    endif

    if ValType( cId ) == "C"
        cId = Upper( AllTrim( cId ) )
    endif

    s_hRegistry[ cId ] := oItem
   
return nil

// -------------------------------------------------------------------------------- //

function SwiftUnregisterItem( cId )

    if s_hRegistry == nil ; return nil ; endif

    if !Empty( cId ) .and. ValType( cId ) == "C"
        cId = Upper( AllTrim( cId ) )
        if hb_HHasKey( s_hRegistry, cId )
            hb_HDel( s_hRegistry, cId )
        endif
    endif

return nil

// -------------------------------------------------------------------------------- //

function SwiftGetItem( cId )
    if ValType( cId ) == "C"
        cId = Upper( AllTrim( cId ) )
    endif
return If( hb_HHasKey( s_hRegistry, cId ), s_hRegistry[ cId ], nil )

// -------------------------------------------------------------------------------- //

function SW_PIPELINE_SYNC( cJson )
    local hChanges 
    local cId, hProps, cProp, uVal
    local oItem, lChanged, aIds, n

    if Empty( cJson ) ; return nil ; endif
    
    s_lInSync := .T.
    SW_LOG( "SW_PIPELINE_SYNC: Received -> " + cJson )
    hb_jsonDecode( cJson, @hChanges )
    
    if ValType( hChanges ) == "H"
        aIds := hb_HKeys( hChanges )
        for n := 1 to Len( aIds )
            cId := aIds[ n ]
            
            // --- COMANDOS DE SISTEMA ---
            if Upper( cId ) == "_SYSTEM"
               hProps := hChanges[ cId ]
               if hb_HHasKey( hProps, "unregister" ) .and. ValType( hProps["unregister"] ) == "A"
                  for each uVal in hProps["unregister"]
                     SW_LOG( "SW_PIPELINE_SYNC: System Unregister -> " + hb_ValToStr( uVal ) )
                     SwiftUnregisterItem( uVal )
                  next
               endif
               loop
            endif

            s_cSyncID := cId
            oItem := SwiftGetItem( cId ) 
            
            if oItem != nil
                hProps := hChanges[ cId ]
                lChanged := .F.
                
                if ValType( hProps ) == "H"
                    if __ObjHasMsg( oItem, "UPDATE" )
                        oItem:Update( hProps )
                        lChanged := .T.
                    else
                        for each cProp in hb_HKeys( hProps )
                            uVal := hProps[ cProp ]
                            if __ObjHasMsg( oItem, cProp )
                                HB_ExecFromArray( oItem, "_" + cProp, { uVal } )
                                lChanged := .T.
                            elseif __ObjHasMsg( oItem, "HSTATE" ) .and. ValType( oItem:hState ) == "H"
                                oItem:hState[ cProp ] := uVal
                                lChanged := .T.
                            endif
                        next
                    endif
                endif
                
                if lChanged .and. __ObjHasMsg( oItem, "REFRESH" )
                    oItem:Refresh()
                endif
            endif
        next
    endif
    s_lInSync := .F.
    s_cSyncID := ""
return nil
