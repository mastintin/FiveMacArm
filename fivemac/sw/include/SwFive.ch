// swfive.ch - Modern SwiftFive Commands Header
// (c) 2026 Modernizing FiveMac

#ifndef _SWFIVE_CH
#define _SWFIVE_CH

//----------------------------------------------------------------------------//
// Modern SwWindow
//----------------------------------------------------------------------------//

#xcommand DEFINE SWWINDOW <oWnd> ;
             [ TITLE <cTitle> ] ;
             [ SIZE <nWidth>, <nHeight> ] ;
          => ;
          <oWnd> := TSwWindow():New( [<cTitle>], [<nWidth>], [<nHeight>] )

#xcommand ACTIVATE SWWINDOW <oWnd> ;
             [ <center: CENTER, CENTERED > ] ;
          => ;
          <oWnd>:Activate()

//----------------------------------------------------------------------------//
// Modern SwLabel (SwiftUI)
//----------------------------------------------------------------------------//

#xcommand @ <nRow>, <nCol> SWLABEL [ <oSay> PROMPT ] <cText> ;
   [ OF <oWnd> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   => ;
   [ <oSay> := ] TSwLabel():New( <nRow>, <nCol>, [<nWidth>], [<nHeight>],;
   <cText>, <oWnd> )

//----------------------------------------------------------------------------//
// Modern SwButton (SwiftUI)
//----------------------------------------------------------------------------//

#xcommand @ <nRow>, <nCol> SWBUTTON [ <oBtn> PROMPT ] <cPrompt> ;
   [ OF <oWnd> ] ;
   [ ACTION <uAction> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   => ;
   [ <oBtn> := ] TSwButton():New( <nRow>, <nCol>, [<nWidth>], [<nHeight>],;
   <cPrompt>, <oWnd>, [\{|v| <uAction> \}] )

//----------------------------------------------------------------------------//
// Modern SwGet (SwiftUI)
//----------------------------------------------------------------------------//

#xcommand @ <nRow>, <nCol> SWGET [ <oGet> VAR ] <uVar> ;
   [ OF <oWnd> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ PICTURE <cPicture> ] ;
   [ <password: PASSWORD> ] ;
   [ ACTION <uAction> ] ;
   => ;
   [ <oGet> := ] SwGet():New( <nRow>, <nCol>, [<nWidth>], [<nHeight>],;
   <uVar>, <oWnd>, [\{|v| <uAction> \}], [<cPicture>], , <.password.> )

//----------------------------------------------------------------------------//

#endif
