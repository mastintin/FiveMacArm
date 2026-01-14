#include "FiveMac.ch"

//----------------------------------------------------------------------------//

CLASS TPlist

   DATA   cName

   METHOD New( cName ) CONSTRUCTOR
  
   METHOD GetItemByName( cKey ) INLINE GetPlistValue( ::cName, cKey )
   METHOD SetItemByName( cKey, cValue, lpost ) 
  
   METHOD SetArrayByName( cKey, aArray, lpost )
   METHOD GetArrayByName( cKey )
  
   METHOD IsKeyByName(cKey) INLINE IsKeyPlist( ::cName, cKey )
  
   METHOD SetBooleanByName( cKey, lValue, lPost )

   METHOD SetPathValue( cPath, xValue, lPost )
   METHOD SetPathArray( cPath, aArray, lPost )
                        
ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( cName ) CLASS TPlist

   ::cName = cName 

return self

//----------------------------------------------------------------------------//

METHOD SetItemByName( cKey, cValue, lpost ) CLASS TPlist
   local oArray
   DEFAULT lpost := .t.
   
   if Valtype( cValue ) == "N"
      cValue = AllTrim( Str( cValue ) )
   endif 
 
   SetPlistValue( ::cName, cKey, cValue, lpost )

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
      endif
   endif 

return nil 

//----------------------------------------------------------------------------//

METHOD GetArrayByName( cKey ) CLASS TPlist

   local oArray := GetPlistArrayValue(::cName,Ckey) 
   local i
   local n:= Arraylen(oArray)
   local aArray:= {}
   loca cValue
   
   for i=1 to n
      cValue:= ArrayGetStringIndex(oArray,i-1)
      aadd(aArray,cValue)
   next      
 
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
   endif
return nil

//----------------------------------------------------------------------------//

Function CreateInfoFile( cProg, cIcon, cVersion )
   local lpost:= .f.
   local cFile, cExe, oInfo
   
   // Ensure cProg does NOT have .app for the binary/identifier
   cExe := cProg
   if Right( cExe, 4 ) == ".app"
      cExe := Left( cExe, Len( cExe ) - 4 )
   endif

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
