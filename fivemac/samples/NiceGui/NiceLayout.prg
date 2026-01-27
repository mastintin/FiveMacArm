// NiceLayout.prg - Containers and Layouts

//----------------------------------------------------------------------------//
// Container Base
//----------------------------------------------------------------------------//

CLASS TNiceContainer FROM TNiceControl
    DATA aControls INIT {}
    METHOD Add( oControl )
    METHOD GetHtmlChildren()
ENDCLASS

METHOD Add( oControl ) CLASS TNiceContainer
    AAdd( ::aControls, oControl )
return nil

METHOD GetHtmlChildren() CLASS TNiceContainer
    local cHtml := ""
    local oCtrl
    for each oCtrl in ::aControls
    cHtml += oCtrl:GetHtml() + " "
    next
return cHtml

//----------------------------------------------------------------------------//
// Nice HStack
//----------------------------------------------------------------------------//

CLASS TNiceHStack FROM TNiceContainer
    METHOD New( oParent )
    METHOD GetHtml()
ENDCLASS

METHOD New( oParent ) CLASS TNiceHStack
    ::Super:New( oParent )
return Self

METHOD GetHtml() CLASS TNiceHStack
    local cHtml := '<div class="row q-gutter-md flex-center">'
    cHtml += ::GetHtmlChildren()
    cHtml += '</div>'
return cHtml

//----------------------------------------------------------------------------//
// Nice VStack
//----------------------------------------------------------------------------//

CLASS TNiceVStack FROM TNiceContainer
    METHOD New( oParent )
    METHOD GetHtml()
ENDCLASS

METHOD New( oParent ) CLASS TNiceVStack
    ::Super:New( oParent )
return Self

METHOD GetHtml() CLASS TNiceVStack
    local cHtml := '<div class="column q-gutter-md flex-center">'
    cHtml += ::GetHtmlChildren()
    cHtml += '</div>'
return cHtml

//----------------------------------------------------------------------------//
// Nice Card
//----------------------------------------------------------------------------//

CLASS TNiceCard FROM TNiceContainer
    METHOD New( oParent )
    METHOD GetHtml()
ENDCLASS

METHOD New( oParent ) CLASS TNiceCard
    ::Super:New( oParent )
return Self

METHOD GetHtml() CLASS TNiceCard
    local cHtml := '<q-card class="my-card q-pa-md" style="min-width: 300px;">'
    cHtml += '<q-card-section>'
    cHtml += ::GetHtmlChildren()
    cHtml += '</q-card-section>'
    cHtml += '</q-card>'
return cHtml
