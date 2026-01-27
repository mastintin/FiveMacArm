// NiceControls.prg - Standard Controls

//----------------------------------------------------------------------------//
// Nice Button
//----------------------------------------------------------------------------//

CLASS TNiceButton FROM TNiceControl
    DATA cLabel
    DATA cIcon
   
    METHOD New( oParent, cLabel, bAction, cIcon )
    METHOD GetHtml()
ENDCLASS

METHOD New( oParent, cLabel, bAction, cIcon ) CLASS TNiceButton
    ::Super:New( oParent )
    ::cLabel  := cLabel
    ::bAction := bAction
    ::cIcon   := cIcon
    DEFAULT ::cIcon := ""
return Self

METHOD GetHtml() CLASS TNiceButton
    local cHtml := '<q-btn color="primary" '
    cHtml += 'label="' + ::cLabel + '" '
    if !Empty( ::cIcon )
        cHtml += 'icon="' + ::cIcon + '" '
    endif
    cHtml += '@click="sendEvent( ' + "'" + ::cId + "'" + ', ' + "'" + 'click' + "'" + ' )" '
    cHtml += '></q-btn>'
return cHtml

//----------------------------------------------------------------------------//
// Nice Input
//----------------------------------------------------------------------------//

CLASS TNiceInput FROM TNiceControl
    DATA cLabel
    DATA cValue
   
    METHOD New( oParent, cLabel, cValue )
    METHOD GetHtml()
    METHOD GetModelName()
ENDCLASS

METHOD New( oParent, cLabel, cValue ) CLASS TNiceInput
    ::Super:New( oParent )
    ::cLabel := cLabel
    ::cValue := cValue
    DEFAULT ::cValue := ""
return Self

METHOD GetHtml() CLASS TNiceInput
    local cHtml := '<q-input outlined ' // Style
    cHtml += 'label="' + ::cLabel + '" '
   
    // Two-way binding
    cHtml += 'v-model="' + ::GetModelName() + '" ' 
   
    // Simplified Updater
    cHtml += '@update:model-value="updateVal( ' + "'" + ::cId + "'" + ', $event )" '
   
    cHtml += '></q-input>'
return cHtml

METHOD GetModelName() CLASS TNiceInput
return ::cId + "_val"

//----------------------------------------------------------------------------//
// Nice Label (SAY)
//----------------------------------------------------------------------------//

CLASS TNiceLabel FROM TNiceControl
    DATA cText
    DATA cClass
   
    METHOD New( oParent, cText, cClass )
    METHOD GetHtml()
ENDCLASS

METHOD New( oParent, cText, cClass ) CLASS TNiceLabel
    ::Super:New( oParent )
    ::cText  := cText
    ::cClass := cClass
    DEFAULT ::cClass := "text-body1"
return Self

METHOD GetHtml() CLASS TNiceLabel
return '<div class="' + ::cClass + '">' + ::cText + '</div>'
