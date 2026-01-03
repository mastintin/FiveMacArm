#include "FiveMac.ch"

function Main()

   local oWnd, oTbr, oWeb
   
   SetImgPath( ResPath() + "/bitmaps/" )

   DEFINE WINDOW oWnd TITLE "WebView Test" 
	  	 
	 oWnd:Maximize() 	 
	  	 
	 DEFINE TOOLBAR oTbr OF oWnd 	 
	 
	 DEFINE BUTTON OF oTbr ;
	    PROMPT "Back" ;
	    TOOLTIP "Go back" ;
	    IMAGE ImgTemplate( "GoLeft" ) ;
	    ACTION oWeb:GoBack()
	    
	 DEFINE BUTTON OF oTbr ;
	    PROMPT "Forward" ;
	    TOOLTIP "Go forward" ;
	    IMAGE ImgTemplate( "GoRight" ) ;
	    ACTION oWeb:GoForward()   
	    
	 DEFINE BUTTON OF oTbr ;
	    PROMPT "End" ;
	    TOOLTIP "Exit from the application" ;
	    IMAGE ImgSymbols( "xmark.circle", "Salir del programa" ) ;
	    ACTION oWnd:End()   
	  	 
	 @ 20, 20 WEBVIEW oWeb ;
	    SIZE oWnd:nWidth - 40, oWnd:nHeight - 100 OF oWnd ;
	    URL "https://www.fivetechsoft.com"
	   	             
   ACTIVATE WINDOW oWnd

return nil   

//----------------------------------------------------------------------------//
