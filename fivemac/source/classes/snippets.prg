#include "FiveMac.ch"

// Class to manage Code Snippets
// Reads a JSON file (VS Code format) and provides snippets based on prefix.

CLASS TSnippets

    DATA hSnippets  INIT {=>}  // Hash: prefix -> body
    DATA cFile

    METHOD New( cFile )
    METHOD Load( cFile )
    METHOD Get( cPrefix )
    METHOD Exist( cPrefix )

ENDCLASS

METHOD New( cFile ) CLASS TSnippets

    if ! Empty( cFile )
    ::Load( cFile )
    endif

return Self

METHOD Load( cFile ) CLASS TSnippets

    local cJson, hJson, hItem, cKey, cPrefix, aBody
    local cBody := ""
    local n 

    if ! File( cFile )
    return .F.
    endif

    ::cFile := cFile
    cJson   := MemoRead( cFile )
    hJson   := hb_jsonDecode( cJson )

    if ValType( hJson ) != "H"
    return .F.
    endif

    // Iterate through the JSON object
    // Format: "Snippet Name": { "prefix": "...", "body": [ ... ], "description": "..." }
   
    for each cKey in hJson:Keys
    hItem := hJson[ cKey ]
      
    if ValType( hItem ) == "H" .and. hb_HHasKey( hItem, "prefix" ) .and. hb_HHasKey( hItem, "body" )
         
    cPrefix := hItem[ "prefix" ]
         
    // Handle body (can be string or array of strings)
    if ValType( hItem[ "body" ] ) == "A"
    aBody := hItem[ "body" ]
    cBody := ""
    for n := 1 to Len( aBody )
    cBody += aBody[ n ] + CRLF
    next
    else
    cBody := hItem[ "body" ]
    endif
         
    // Store in our Hash (Lowercase prefix for case-insensitive lookup)
    ::hSnippets[ Lower( cPrefix ) ] := cBody
         
    endif
    next

return .T.

METHOD Get( cPrefix ) CLASS TSnippets
   
    local cBody := ""
   
    cPrefix := Lower( cPrefix )
   
    if hb_HHasKey( ::hSnippets, cPrefix )
    cBody := ::hSnippets[ cPrefix ]
    endif

return cBody

METHOD Exist( cPrefix ) CLASS TSnippets
return hb_HHasKey( ::hSnippets, Lower( cPrefix ) )
