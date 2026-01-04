// MyMsgLogo() example by Dino Alessandri

#include "FiveMac.ch"

function Main()

   MyMsgLogo( UserPath() + "/five/Fivemac/fivemac/bitmaps/test.png", 3.0 )

return nil

function MyMsgLogo( cBmp, nSeconds )

   local oWnd,oImg 
   
   DEFINE WINDOW oWnd FROM 20, 300 TO 600, 800 NOBORDER 
   oWnd:SetPos( ( ScreenHeight() - 580 ) / 2, ( ScreenWidth() - 500 ) / 2 )
   oWnd:SetSplash()
   
   //savescreen("./yo.png")
                 
   @ 100, 10 IMAGE oImg OF oWnd SIZE 400,500 FILENAME cBmp  
                 
   @ 40, 40 BUTTON "Salir" OF oWnd ACTION AppTerminate() // don't END
                 
   ACTIVATE WINDOW oWnd 
     
return nil

#pragma BEGINDUMP
#include <Cocoa/Cocoa.h>
#include <hbapi.h>

HB_FUNC( APPTERMINATE )
{
   // [ NSApp terminate : nil ];
   exit( 0 );
}
#pragma ENDDUMP
