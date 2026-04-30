#include "FiveMac.ch"

//----------------------------------------------------------------------------//

CLASS TPlist

   DATA   cName
   DATA   nPtrDict

   METHOD New( cName ) CONSTRUCTOR
  
   METHOD GetItemByName( cKey ) INLINE GetPlistValue( ::cName, cKey )
   METHOD SetItemByName( cKey, cValue, lpost ) 
  
   METHOD SetArrayByName( cKey, aArray, lpost )
   METHOD GetArrayByName( cKey )
  
   METHOD IsKeyByName(cKey) INLINE IsKeyPlist( ::cName, cKey )
  
   METHOD SetBooleanByName( cKey, lValue, lPost )

   METHOD SetPathValue( cPath, xValue, lPost )
   METHOD SetPathArray( cPath, aArray, lPost )
   
   METHOD ToHash() 
   METHOD GetRootDict()
   
   METHOD End()  // El guardián de la memoria   

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( cName ) CLASS TPlist

   ::cName = cName 
   ::nPtrDict := DictionaryWithContentsOfFile( ::cName )

return self

//----------------------------------------------------------------------------//

METHOD SetItemByName( cKey, cValue, lPost ) CLASS TPlist
   DEFAULT lPost := .t.
   
   // Si es número, lo convertimos a cadena para SetPlistValue
   // O podrías crear un SetPlistNumber si prefieres guardarlos como numéricos reales
   if Valtype( cValue ) == "N"
      cValue = AllTrim( Str( cValue ) )
   endif 
 
   SetPlistValue( ::cName, cKey, cValue, lPost )
return nil 

//----------------------------------------------------------------------------//

METHOD SetArrayByName( cKey, aArray, lpost ) CLASS TPlist
   local oArray, n
   DEFAULT lpost := .t.
        
   if ! Empty( aArray )
      if ValType( aArray ) == "A" .and. Len( aArray ) > 0
      
         oArray:=  ArrayCreateEmpty() 
                        
         for n = 1 to Len( aArray )
            ArrayAddItem( oArray, aArray[ n ] )                       
         next 
         SetPlistArrayValue( ::cName, cKey, oArray, lpost ) 
         NSRelease( oArray )
      endif
   endif 

return nil 

//----------------------------------------------------------------------------//

METHOD GetRootDict() CLASS TPlist
   ::nPtrDict := DictionaryWithContentsOfFile( ::cName )
return ::nPtrDict

//----------------------------------------------------------------------------//

METHOD ToHash() CLASS TPlist
   local hResult := {=>}
   if ::nPtrDict == 0
      ::nPtrDict := ::GetRootDict()
   endif
   if ::nPtrDict != 0
      hResult := DictToHash( ::nPtrDict ) // Convierte el puntero C en Hash de Harbour
   endif

return hResult

//----------------------------------------------------------------------------//

METHOD End() CLASS TPlist
   if ! Empty( ::nPtrDict ) .and. ::nPtrDict != 0
      DictRelease( ::nPtrDict ) // Liberamos el objeto de Cocoa
      ::nPtrDict := 0
   endif
return nil

//----------------------------------------------------------------------------//

METHOD GetArrayByName( cKey ) CLASS TPlist
   local oArray := GetPlistArrayValue( ::cName, cKey ) 
   local i, n, aArray := {}
   local cValue
   
   if oArray != 0  // Verificamos que el puntero sea válido
      n := ArrayLen( oArray )
      for i = 1 to n
         cValue := ArrayGetStringIndex( oArray, i - 1 )
         AAdd( aArray, cValue )
      next      
      
      // CRÍTICO No-ARC: Liberamos el objeto creado en C por GETPLISTARRAYVALUE
      NSRelease( oArray ) 
   endif
return aArray


//----------------------------------------------------------------------------//

METHOD SetBooleanByName( cKey, lValue, lPost ) CLASS TPlist
   DEFAULT lPost := .t.
   SetPlistBoolean( ::cName, cKey, lValue, lPost )
return nil

//----------------------------------------------------------------------------//

METHOD SetPathValue( cPath, xValue, lPost ) CLASS TPlist
   DEFAULT lPost := .t.
   SetPlistPathValue( ::cName, cPath, xValue, lPost )
return nil

//----------------------------------------------------------------------------//

METHOD SetPathArray( cPath, aArray, lPost ) CLASS TPlist
   local oArray, n
   DEFAULT lPost := .t.

   if ! Empty( aArray ) .and. ValType( aArray ) == "A"
      oArray := ArrayCreateEmpty()
      for n = 1 to Len( aArray )
         ArrayAddItem( oArray, aArray[ n ] )
      next
      SetPlistPathArray( ::cName, cPath, oArray, lPost )
      NSRelease( oArray )
   endif
return nil




//----------------------------------------------------------------------------//
// Clase Tarray 
//----------------------------------------------------------------------------//

CLASS TArray
   DATA   nPtr          // El puntero HB_LONGLONG al NSMutableArray de C
   DATA   lAutoRelease  // Para saber si debemos liberarlo al destruir el objeto

   METHOD New( nLen ) CONSTRUCTOR
   METHOD FromPtr( nPtr ) CONSTRUCTOR  // Para cuando ya recibes un puntero de un Plist
   
   METHOD Add( xVal )
   METHOD Get( nIndex )
   METHOD Set( nIndex, xVal )
   METHOD Del( nIndex )
   METHOD DelAll() 
   
   METHOD ToArray()             // Convierte a array nativo de Harbour {...}
   METHOD ToHash()              // Convierte a Hash { => } (si son pares clave/valor)
   


   METHOD Len() INLINE ArrayLen( ::nPtr )
   
   METHOD End() 

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nLen ) CLASS TArray
   DEFAULT nLen := 0
   ::nPtr         := ArrayCreateLen( nLen )
   ::lAutoRelease := .t.
return self

//----------------------------------------------------------------------------//

METHOD FromPtr( nPtr ) CLASS TArray
   ::nPtr         := nPtr
   ::lAutoRelease := .f. // Si viene de fuera (ej: un Plist), mejor no liberarlo nosotros
return self

//----------------------------------------------------------------------------//

METHOD Add( xVal ) CLASS TArray
   if ValType( xVal ) == "C"
      ArrayAddString( ::nPtr, xVal )
   elseif ValType( xVal ) == "O" .and. xVal:IsDerivedFrom( "TArray" )
      ArrayAddObj( ::nPtr, xVal:nPtr )
   elseif ValType( xVal ) == "N" // Si quieres guardarlo como puntero de objeto
      ArrayAddObj( ::nPtr, xVal )
   endif
return self

//----------------------------------------------------------------------------//

METHOD Get( nIndex ) CLASS TArray
   local xVal := ArrayGetStringIndex( ::nPtr, nIndex )
   // Si el string viene vacío, podrías intentar GetObj si esperas sub-arrays
return xVal

//----------------------------------------------------------------------------//

METHOD End() CLASS TArray
   if ::lAutoRelease .and. ::nPtr != 0
      ArrayRelease( ::nPtr )
      ::nPtr := 0
   endif
return nil

//----------------------------------------------------------------------------//

METHOD ToArray() CLASS TArray
   local aResult := {}
   local i, nLen := ::Len()
   
   if ::nPtr != 0
      for i = 1 to nLen
         // Usamos GetObj para que la conversión sea recursiva si hay sub-objetos
         AAdd( aResult, ::Get( i ) )
      next
   endif
return aResult

//----------------------------------------------------------------------------//

METHOD ToHash() CLASS TArray
   local hResult := {=>}
   local i, nLen := ::Len()
   
   if ::nPtr != 0
      for i = 1 to nLen
         // Asume que los elementos son pares: clave (string) -> valor
         // Si el array no tiene pares, esto podría fallar o crear claves numéricas
         hResult[ ::Get( i ) ] := ::Get( i + 1 )
         i++ // Saltar el valor ya que acabamos de usarlo como clave
      next
   endif
return hResult



//----------------------------------------------------------------------------//
// Funciones auxiliares
//----------------------------------------------------------------------------//

Function CreateInfoFile( cProg, cIcon, cVersion )
   local lpost:= .f.
   local cFile, cExe, oInfo
   
   // Ensure cProg does NOT have .app for the binary/identifier
   cExe := cProg
   if Right( cExe, 4 ) == ".app"
      cExe := Left( cExe, Len( cExe ) - 4 )
   endif
   // Ensure it is just the filename, not full path
   cExe := cFileNoPath( cExe )

   // Bundle path DOES need .app
   if !Right( cProg, 4 ) == ".app"
      cProg := cProg + ".app"
   endif
   cFile := cProg + "/Contents/Info.plist"

   if Empty( cIcon )
      cIcon := "fivetech.icns"
   endif

   if Empty( cVersion )
      cVersion := "1.0"
   endif

   oInfo:=TPlist():new( cfile )

   WITH OBJECT oInfo  
   :SetItemByName ( "CFBundleExecutable" , cExe , lpost ) 
   :SetItemByName ( "CFBundleName" , cExe, lpost )
   :SetItemByName ( "CFBundleIdentifier" , "com.fivetech."+cExe , lpost  ) 
   :SetItemByName ( "CFBundlePackageType" , "APPL" , lpost  ) 
   :SetItemByName ( "CFBundleShortVersionString" , cVersion , lpost  )
   :SetItemByName ( "CFBundleVersion" , cVersion , lpost  )
   :SetItemByName ( "CFBundleInfoDictionaryVersion" , "6.0" , lpost  ) 
   :SetItemByName ( "CFBundleIconFile" , cIcon , lpost  ) 
   :SetPathValue( "NSHighResolutionCapable", .t., lpost )
   :SetItemByName( "NSPrincipalClass", "NSApplication", lpost )
   :SetPathValue( "NSAppTransportSecurity/NSAllowsArbitraryLoads", .t., lpost )
   END

Return nil



//----------------------------------------------------------------------------//

Function CreatePkInfo( cProg )
   
   local cFile
   
   if !Right( cProg, 4 ) == ".app"
      cProg := cProg + ".app"
   endif
   cFile := cProg + "/Contents/"+ "PkgInfo"
      
   MemoWrit( cFile, "APPL????" )

return nil

//----------------------------------------------------------------------------//

Function DictToHash( nPtrDict )
   local hResult := {=>}
   local i, nKeys, cKey, xVal

   if nPtrDict != 0
      nKeys := DictCount( nPtrDict ) // Usamos la función DICTCOUNT que hicimos

      for i = 1 to nKeys
         // DICTGETKEY ya ajusta el (i-1) internamente en el código C que te pasé
         cKey := DictGetKey( nPtrDict, i ) 

         if ! Empty( cKey )
            // Obtenemos el valor con detección de tipos (String, Num, Log o Puntero)
            xVal := DictGetValue( nPtrDict, cKey )

            // --- MAGIA DE LA RECURSIVIDAD ---
            if ValType( xVal ) == "N" .and. xVal != 0
               // Si el valor es un puntero (un sub-diccionario o array en Cocoa)
               // comprobamos si es un Diccionario para seguir bajando
               if IsDict( xVal ) 
                  hResult[ cKey ] := DictToHash( xVal )
               elseif IsArray( xVal )
                  hResult[ cKey ] := NSArrayToValue( xVal ) // Para convertir sub-arrays
               else
                  hResult[ cKey ] := xVal
               endif
            else
               hResult[ cKey ] := xVal
            endif
         endif
      next
   endif

return hResult

//----------------------------------------------------------------------------//

Function NSArrayToValue( nPtrArray )
   local aResult := {}
   local i, nLen, xVal

   if nPtrArray != 0
      // Usamos la función C: HB_FUNC( ARRAYLEN )
      nLen := ArrayLen( nPtrArray ) 

      for i = 1 to nLen
         // Obtenemos el objeto de la posición i (Base 1)
         // Usamos la función C: HB_FUNC( ARRAYGETOBJINDEX )
         xVal := ArrayGetObjIndex( nPtrArray, i ) 

         if ValType( xVal ) == "N" .and. xVal != 0
            // Si el elemento es otro puntero, decidimos qué hacer
            if IsDict( xVal ) 
               // Si hay un Diccionario dentro del Array -> Hash
               AAdd( aResult, DictToHash( xVal ) )
            elseif IsArray( xVal )
               // Si hay un Array dentro del Array -> Recursividad
               AAdd( aResult, NSArrayToValue( xVal ) )
            else
               AAdd( aResult, xVal )
            endif
         else
            // Si es String, Num o Log devuelto directamente por C
            AAdd( aResult, xVal )
         endif
      next
   endif

return aResult

//----------------------------------------------------------------------------//


Function HashToPlist( hHash, cFile )
   local nPtrDict := Hash_To_Dict( hHash )
   local lSuccess := .f.

   if nPtrDict != 0
      // Usamos la función de guardado que ya teníamos
      lSuccess := DictWriteToFile( nPtrDict, cFile, .t. )
      
      // CRÍTICO No-ARC: Liberamos el diccionario creado con 'alloc'
      DictRelease( nPtrDict )
   endif

return lSuccess



