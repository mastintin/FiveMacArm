// Splash test
// would require styleMask: NSBorderlessWindowMask of window

#include "FiveMac.ch"


function Main()

   local oWnd
       
   DEFINE WINDOW oWnd TITLE ""  NOFLIPPED ;
      FROM 20, 300 TO 600,400 
         
   oWnd:Center()   
   Splash(oWnd)

   ACTIVATE WINDOW oWnd  ;
      ON INIT WNDFORCEHIDE(oWnd:hwnd)
      
RETURN NIL      

Function Splash(oWnd)
   local oSplash 
   oSplash := TSplash():New( 100, 10, 400, 500)   
   oSplash:SetImage( UserPath() + "/Fivemac/bitmaps/test.png" )
   oSplash:center()
   oSplash:bOnClose := { |o| WNDFORCESHOW(oWnd:hwnd) }
   oSplash:run()
     
return nil
