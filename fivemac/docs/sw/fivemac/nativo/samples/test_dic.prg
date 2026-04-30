function Main()
   local oInfo
   local cFile := "test.plist"

   if File( cFile )
      FErase( cFile )
   endif

   oInfo := TPlist():New( cFile )
   
   // 1. Existing Tests
   // oInfo:SetDictByName( "UserConfig" ) // Removed as redundant
   oInfo:SetPathValue( "UserConfig/Name", "Manuel" )
   oInfo:SetPathValue( "UserConfig/IsAdmin", .T. )
   oInfo:SetPathValue( "UserConfig/LoginCount", 100 )
   oInfo:SetPathValue( "UserConfig/Permissions/Write", .T. ) // Replaces SetDictIn
   oInfo:SetPathValue( "Deep/Structure/Level3", "Success" )
   oInfo:SetPathValue( "Deep/Structure/IsEnabled", .T. )
   oInfo:SetPathValue( "Deep/Structure/Timeout", 5000 )

   // 2. New Array Tests
   oInfo:SetArrayByName( "MixedRootArray", { "One", 2, .T. } )
   
   // Deep Array
   oInfo:SetPathArray( "Deep/Structure/MyList", { "Alpha", 99.9, .F. } )

   // 3. Refactored Security Test
   // Should create NSAppTransportSecurity -> NSAllowsArbitraryLoads = true
   oInfo:SetPathValue( "NSAppTransportSecurity/NSAllowsArbitraryLoads", .T. )

   Alert( "test.plist updated. Check NSAppTransportSecurity." )
   
return nil
