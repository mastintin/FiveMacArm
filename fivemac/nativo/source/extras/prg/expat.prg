#include "FiveMac.ch"

//----------------------------------------------------------------------------//

CLASS TExpat

    DATA  hParser
    DATA  bStartElement
    DATA  bEndElement
    DATA  bCharData

    METHOD New( cEncoding )
    METHOD End()
    METHOD Parse( cXml, lFinal )
    METHOD SetElementHandler() INLINE ExpatXMLSetElementHandler( ::hParser )
    METHOD SetCharacterDataHandler() INLINE ExpatXMLSetCharacterDataHandler( ::hParser )

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( cEncoding ) CLASS TExpat

    ::hParser = ExpatXMLParserCreate( cEncoding )

    if ! empty( ::hParser )
    ExpatXMLSetUserData( ::hParser, Self )
    endif

return Self

//----------------------------------------------------------------------------//

METHOD End() CLASS TExpat

    if ! empty( ::hParser )
    ExpatXMLParserFree( ::hParser )
    ::hParser = nil
    endif

return nil

//----------------------------------------------------------------------------//

METHOD Parse( cXml, lFinal ) CLASS TExpat

    DEFAULT lFinal := .T.

return ExpatXMLParse( ::hParser, cXml, lFinal )

//----------------------------------------------------------------------------//
