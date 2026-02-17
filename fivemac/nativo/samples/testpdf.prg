//
//  testpdf.prg
//  makelibs
//
//  Created by Manuel Sanchez on 08/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#include "FiveMac.ch"

function Main()

	local oWnd, oTbr, oWeb
	local oPdf
	local cFile
   
	DEFINE WINDOW oWnd TITLE "WebView Test" TEXTURED SIZE 1000, 800
	  	 
	oWnd:Maximize() 	 
	  	 
	DEFINE TOOLBAR oTbr OF oWnd 	 
	 
	DEFINE BUTTON OF oTbr ;
		PROMPT "Open" ;
		TOOLTIP "Open PDF" ;
		IMAGE "folder" ;
		ACTION ( cFile := cGetFile( "Select PDF", "PDF Files (*.pdf)|*.pdf" ), ;
		If( !Empty( cFile ), oPdf:SetPdf( cFile ), nil ) )

	DEFINE BUTTON OF oTbr ;
		PROMPT "Back" ;
		TOOLTIP "Go back" ;
		IMAGE "chevron.left" ;
		ACTION oPDF:goTop()
	    
	DEFINE BUTTON OF oTbr ;
		PROMPT "Forward" ;
		TOOLTIP "Go forward" ;
		IMAGE "chevron.right" ;
		ACTION oPdf:GoBottom()   
	    
	DEFINE BUTTON OF oTbr PROMPT "Zoom In" ;
		TOOLTIP "Zoom in" ;
		IMAGE "plus.magnifyingglass" ;
		ACTION oPdf:zoomin()

	DEFINE BUTTON OF oTbr PROMPT "Zoom Out" ;
		TOOLTIP "Zoom out" ;
		IMAGE "minus.magnifyingglass" ;
		ACTION oPdf:zoomOut() 
  
	DEFINE BUTTON OF oTbr ;
		PROMPT "Previous" ;
		TOOLTIP "Go Previous" ;
		IMAGE "arrow.left" ;
		ACTION oPDF:GoPrevious()
	    
	DEFINE BUTTON OF oTbr ;
		PROMPT "Next" ;
		TOOLTIP "Go Next" ;
		IMAGE "arrow.right" ;
		ACTION oPdf:GoNext()  
 
	DEFINE BUTTON OF oTbr ;
		PROMPT "End" ;
		TOOLTIP "Exit from the application" ;
		IMAGE "xmark.circle" ;
		ACTION oWnd:End() 
          
	@ 20, 20 PDFVIEW oPdf OF oWnd ;
		SIZE oWnd:nWidth - 40, oWnd:nHeight - 100 ;
		FILE UserPath() + "/fivemac/samples/OSXHIGuidelines.pdf" ;
		AUTOSCALE                                                     
          
                     
	ACTIVATE WINDOW oWnd

return nil   



