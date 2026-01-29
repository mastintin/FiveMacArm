#include "FiveMac.ch"

function Main()

   local oWnd, oBrw
   local cFile := Path() + "/scripts.dbf"
   local cAlias

   if ! File( cFile )
      MsgInfo( "File scripts.dbf not found" )
      return nil
   endif

   USE ( cFile ) SHARED
   cAlias := Alias()

   DEFINE WINDOW oWnd TITLE "Testing Browse Change" SIZE 600, 400

   @ 20, 20 BROWSE oBrw OF oWnd SIZE 560, 360 ;
      FIELDS (cAlias)->Name, (cAlias)->Descript ;
      HEADERS "Name", "Description" ;
      COLSIZES 150, 300 ;
 ON CHANGE ( MsgInfo( "RecNo: " + AllTrim( Str( (oBrw:cAlias)->( ordkeyNo() ) ) ) + CRLF + ;
                      "miAlias"+ AllTrim( Str( (cAlias)->( ordkeyNo() ) ) )+ CRLF + ;
                       "Row: " + AllTrim( Str( oBrw:GetSelect() + 1 ) ) ) )

      
      
   oBrw:cAlias := cAlias

    

   ACTIVATE WINDOW oWnd

return nil
