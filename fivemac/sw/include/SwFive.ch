#ifndef _SWFIVE_CH
#define _SWFIVE_CH

//----------------------------------------------------------------------------//
// VENTANA
//----------------------------------------------------------------------------//

#xcommand DEFINE WINDOW <oWnd> ;
   [ TITLE <cTitle> ] ;
   FROM <nTop>, <nLeft> TO <nBottom>, <nRight> ;
   => ;
   <oWnd> := TSwWindow():New( <cTitle>, <nRight> - <nLeft>, <nBottom> - <nTop> )

#xcommand DEFINE WINDOW <oWnd> ;
   [ TITLE <cTitle> ] ;
   SIZE <nWidth>, <nHeight> ;
   => ;
   <oWnd> := TSwWindow():New( <cTitle>, <nWidth>, <nHeight> )

#xcommand ACTIVATE WINDOW <oWnd> ;
   [ <center: CENTER, CENTERED> ] ;
   => ;
   <oWnd>:Activate( <.center.> )

//----------------------------------------------------------------------------//
// COMPONENTES DE LA ISLA (Sw)
//----------------------------------------------------------------------------//

#xcommand @ <nRow>, <nCol> LABEL [ <oSay> PROMPT ] <cText> ;
   [ OF <oWnd> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   => ;
   [ <oSay> := ] TSwLabel():New( <nRow>, <nCol>, <nWidth>, <nHeight>, <cText>, <oWnd> )

#xcommand @ <nRow>, <nCol> SAY [ <oSay> PROMPT ] <cText> ;
   [ OF <oWnd> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   => ;
   [ <oSay> := ] TSwLabel():New( <nRow>, <nCol>, <nWidth>, <nHeight>, <cText>, <oWnd> )

#xcommand @ <nRow>, <nCol> BUTTON [ <oBtn> PROMPT ] <cPrompt> ;
   [ OF <oWnd> ] ;
   [ ACTION <uAction,...> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   => ;
   [ <oBtn> := ] TSwButton():New( <nRow>, <nCol>, <nWidth>, <nHeight>,;
   <cPrompt>, <oWnd>, [\{| self |(<uAction>)\}] )

#xcommand @ <nRow>, <nCol> TOGGLE [ <oToggle> PROMPT ] <cText> ;
             [ <lValue: VALUE, VAR > <lOn> ] ;
             [ <lSw: SWITCH > ] ;
             [ OF <oWnd> ] ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ ID <cId> ] ;
      => ;
      [ <oToggle> := ] TSwToggle():New( <nRow>, <nCol>, <nWidth>, <nHeight>, <lOn>, <cText>, <oWnd>, <cId>, [ .not. Empty(<.lSw.>) ] )

#xcommand @ <nRow>, <nCol> SLIDER [ <oSlider> ] ;
             [ VALUE <nValue> ] ;
             [ RANGE <nMin>, <nMax> ] ;
             [ OF <oWnd> ] ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ <id: ID, IDENT, CID> <cId> ] ;
             [ <change: ON CHANGE, ACTION> <uAction,...> ] ;
    => ;
   [ <oSlider> := ] TSwSlider():New( <nRow>, <nCol>, <nWidth>, <nHeight>, <nValue>, <nMin>, <nMax>, <oWnd>, <cId>, [\{| nVal, self |(<uAction>)\}] )

#endif
