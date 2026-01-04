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
   
                  
   @ 100, 10 IMAGE oImg OF  SIZE 400,500 FILENAME cBmp  
                 
   @ 40, 40 BUTTON "Salir" OF oWnd ACTION  WndDestroy( oWnd:hWnd )  
                 
   ACTIVATE WINDOW oWnd
     
return nil

