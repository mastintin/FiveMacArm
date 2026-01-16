#include "FiveMac.ch"

//----------------------------------------------------------------------------//

CLASS THbDocs

    DATA   aDocs
    DATA   hIndex

    METHOD New()
    METHOD Load()
    METHOD Find( cPrefix )
    METHOD GetDoc( cName )

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New() CLASS THbDocs

    ::aDocs  := {}
    ::hIndex := {=>}
    ::Load()

return Self

//----------------------------------------------------------------------------//

METHOD Load() CLASS THbDocs

    local cJson, cPath
    local nAttempts := 0
    local aMissing, aItem, cName, hItem

    cPath := ResPath() + "/hbdocs.json"

    if ! File( cPath )
    MsgInfo( "Error: hbdocs.json not found at " + cPath )
    return nil
    endif

    cJson := MemoRead( cPath )
   
    if Empty( cJson )
    MsgInfo( "Error: hbdocs.json is empty" )
    return nil
    endif

    // Parse JSON using Harbour's built-in parser
    ::aDocs := hb_jsonDecode( cJson )

    if Empty( ::aDocs )
    MsgInfo( "Error: Failed to parse hbdocs.json" )
    return nil
    endif

    // Index for faster lookup
    // Structure is Array of Objects (Hashes)
    // { "name": "...", "label": "...", ... }
   
    AEval( ::aDocs, {| hItem, nIdx | ::hIndex[ hItem[ "name" ] ] := nIdx } )

    // Load hbdocs.missing (Supplementary list)
    cPath := ResPath() + "/hbdocs.missing"
    if File( cPath )
    cJson := MemoRead( cPath ) // Read content of hbdocs.missing
    if ! Empty( cJson )
    aMissing := hb_jsonDecode( cJson )
    if ! Empty( aMissing )
    for each aItem in aMissing
    cName := aItem[ 1 ]
    if ! hb_HHasKey( ::hIndex, cName )
    // Create minimal doc structure with Library in Label
    hItem := { "name" => cName,;
        "label" => cName + " (" + aItem[ 2 ] + ")",;
        "library" => aItem[ 2 ],;
        "documentation" => "Library: " + aItem[ 2 ] }
    AAdd( ::aDocs, hItem )
    ::hIndex[ cName ] := Len( ::aDocs )
    endif
    next
    endif
    else
    // MsgInfo( "Error: hbdocs.missing is empty" )
    endif
    else
    // MsgInfo( "Error: hbdocs.missing not found at " + cPath )
    endif

return nil

//----------------------------------------------------------------------------//

METHOD Find( cPrefix ) CLASS THbDocs

    local cList := ""
    local cName
    local nLen := Len( cPrefix )
    local hItem
   
    // This is a simple linear search. 
    // With thousands of items, we might want a better structure (e.g. Trie or sorted array)
    // But let's try this first.
   
    // Optimisation: If we had a sorted array of names, we could binary search.
    // hbdocs.json is "usually" alphabetical? No guarantee.
   
    cPrefix := Upper( cPrefix )
   
    for each hItem in ::aDocs
    cName := hItem[ "name" ]
    if Left( Upper( cName ), nLen ) == cPrefix
    // Use label if available (contains lib info), otherwise name
    if hb_HHasKey( hItem, "label" )
    cList += hItem[ "label" ] + "?1|"
    else
    cList += cName + "?1|"
    endif
    endif
    next
   
    // Scintilla requires list
    if ! Empty( cList )
    cList := Left( cList, Len( cList ) - 1 ) // Remove trailing |
    endif

return cList

//----------------------------------------------------------------------------//

METHOD GetDoc( cName ) CLASS THbDocs

    local nIdx

    if hb_HHasKey( ::hIndex, cName )
    nIdx := ::hIndex[ cName ]
    return ::aDocs[ nIdx ][ "documentation" ]
    endif

return ""

//----------------------------------------------------------------------------//
