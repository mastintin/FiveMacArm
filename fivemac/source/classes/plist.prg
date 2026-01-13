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

Function CreateInfoFile( cProg, cPath, cIcon, cVersion )
local lpost:= .f.
local cFile:= cPath + cProg + ".app" + "/Contents/" + "Info.plist"

if Right( cPath, 4 ) == ".app"
   cFile := cPath + "/Contents/Info.plist"
endif

if Empty( cIcon )
   cIcon := "fivetech.icns"
endif

if Empty( cVersion )
   cVersion := "1.0"
endif

oInfo:=TPlist():new( cfile )

 WITH OBJECT oInfo  
   :SetItemByName ( "CFBundleExecutable" , cProg , lpost ) 
   :SetItemByName ( "CFBundleName" , cProg, lpost )
   :SetItemByName ( "CFBundleIdentifier" , "com.fivetech."+cProg , lpost  ) 
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

Function CreatePkInfo( cProg, cPath )
   local cFile := cPath + cProg + ".app" + "/Contents/" + "PkgInfo"
   
   // Handle case where cPath already ends in .app (CreaBuilder fix)
   if Right( cPath, 4 ) == ".app"
       cFile := cPath + "/Contents/PkgInfo"
   endif

   MemoWrit( cFile, "APPL????" )

return nil
