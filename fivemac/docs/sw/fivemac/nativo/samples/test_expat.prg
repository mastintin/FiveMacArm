#include "FiveMac.ch"

//----------------------------------------------------------------------------//

function Main()

    local oExpat := TExpat():New()
    local cXml

    cXml := "<book title='FiveMac Manual'>" + ;
        "<chapter number='1'>Introduction</chapter>" + ;
        "<chapter number='2'>Installation</chapter>" + ;
        "</book>"

    oExpat:bStartElement = { | cName, aAtts | MsgInfo( "Start: " + cName + hb_ValToExp( aAtts ) ) }
    oExpat:bEndElement   = { | cName | MsgInfo( "End: " + cName ) }
    oExpat:bCharData     = { | cData | MsgInfo( "Data: " + cData ) }

    oExpat:SetElementHandler()
    oExpat:SetCharacterDataHandler()

    MsgInfo( "Expat Version: " + ExpatVersion() )

    oExpat:Parse( cXml )

    oExpat:End()

return nil

//----------------------------------------------------------------------------//
