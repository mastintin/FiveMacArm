// NiceDialog.prg - Modal Dialogs

//----------------------------------------------------------------------------//
// Nice Dialog
//----------------------------------------------------------------------------//

CLASS TNiceDialog FROM TNiceContainer
    DATA lOpen INIT .F.
   
    METHOD New( oPage )
    METHOD Show()
    METHOD Hide()
    METHOD GetHtml()
    METHOD GetModelName()
    METHOD GetModelValue()
ENDCLASS

METHOD New( oPage ) CLASS TNiceDialog
    ::Super:New( oPage )
    ::lOpen := .F.
return Self

METHOD Show() CLASS TNiceDialog
    local oPage := ::GetPage()
    ::lOpen := .T.
    if oPage:oWeb != nil
        oPage:oWeb:ScriptCallMethod( "window.updateModel('" + ::GetModelName() + "', true)" )
    endif
return nil

METHOD Hide() CLASS TNiceDialog
    local oPage := ::GetPage()
    ::lOpen := .F.
    if oPage:oWeb != nil
        oPage:oWeb:ScriptCallMethod( "window.updateModel('" + ::GetModelName() + "', false)" )
    endif
return nil

METHOD GetHtml() CLASS TNiceDialog
    local cHtml := '<q-dialog v-model="' + ::GetModelName() + '">'
    cHtml += '<q-card class="q-pa-md">'
    cHtml += ::GetHtmlChildren() // Dialog Content
    cHtml += '</q-card>'
    cHtml += '</q-dialog>'
return cHtml

METHOD GetModelName() CLASS TNiceDialog
return ::cId + "_vis" 

METHOD GetModelValue() CLASS TNiceDialog
return If( ::lOpen, "true", "false" )
