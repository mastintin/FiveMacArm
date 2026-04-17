#ifndef _SWFIVE_CH
#define _SWFIVE_CH



// Nombres modernos para la isla (Autoresize)
#define SW_ANCHOR_RIGHT      AnclaRight
#define SW_RESIZE_WIDTH      AnchoMovil
#define SW_ANCHOR_LEFT       AnclaLeft
#define SW_ANCHOR_TOP        AnclaTop
#define SW_RESIZE_HEIGHT     AltoMovil
#define SW_ANCHOR_BOTTOM     AnclaBottom

//----------------------------------------------------------------------------//
// VENTANA
//----------------------------------------------------------------------------//

#xcommand DEFINE WINDOW <oWnd> ;
   [ TITLE <cTitle> ] ;
   FROM <nTop>, <nLeft> TO <nBottom>, <nRight> ;
   [ <of: OF, WINDOW, DIALOG> <oParent> ] ;
   => ;
   <oWnd> := TSwWindow():New( <cTitle>, <nRight> - <nLeft>, <nBottom> - <nTop>,, <oParent> )

#xcommand DEFINE WINDOW <oWnd> ;
   [ TITLE <cTitle> ] ;
   SIZE <nWidth>, <nHeight> ;
   [ <of: OF, WINDOW, DIALOG> <oParent> ] ;
   => ;
   <oWnd> := TSwWindow():New( <cTitle>, <nWidth>, <nHeight>,, <oParent> )

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
   [ <res: AUTORESIZE, ANCHOR> <nAnchor> ] ;
   => ;
   [ <oSay> := ] TSwLabel():New( <nRow>, <nCol>, <nWidth>, <nHeight>, <cText>, <oWnd>,, <nAnchor> )

#xcommand @ <nRow>, <nCol> SAY [ <oSay> PROMPT ] <cText> ;
   [ OF <oWnd> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ <res: AUTORESIZE, ANCHOR> <nAnchor> ] ;
   [ <lScr: SCROLL> ] ;
   => ;
   [ <oSay> := ] TSwLabel():New( <nRow>, <nCol>, <nWidth>, <nHeight>, <cText>, <oWnd>,, <nAnchor> ) ;
   [; <oSay>:lScroll := <.lScr.> ]

#xcommand @ <nRow>, <nCol> BUTTON [ <oBtn> PROMPT ] <cPrompt> ;
   [ OF <oWnd> ] ;
   [ ACTION <uAction,...> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ <res: AUTORESIZE, ANCHOR> <nAnchor> ] ;
   [ <lScr: SCROLL> ] ;
   => ;
   [ <oBtn> := ] TSwButton():New( <nRow>, <nCol>, <nWidth>, <nHeight>,;
   <cPrompt>, <oWnd>, [\{| self |(<uAction>)\}], <nAnchor> ) ;
   [; <oBtn>:lScroll := <.lScr.> ]

#xcommand @ <nRow>, <nCol> TOGGLE [ <oToggle> PROMPT ] <cText> ;
             [ <lValue: VALUE, VAR > <lOn> ] ;
             [ <lSw: SWITCH > ] ;
             [ OF <oWnd> ] ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ <res: AUTORESIZE, ANCHOR> <nAnchor> ] ;
             [ ID <cId> ] ;
      => ;
      [ <oToggle> := ] TSwToggle():New( <nRow>, <nCol>, <nWidth>, <nHeight>, <lOn>, <cText>, <oWnd>, <cId>, [ .not. Empty(<.lSw.>) ], <nAnchor> )

#xcommand @ <nRow>, <nCol> SLIDER [ <oSlider> ] ;
             [ VALUE <nValue> ] ;
             [ RANGE <nMin>, <nMax> ] ;
             [ OF <oWnd> ] ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ <res: AUTORESIZE, ANCHOR> <nAnchor> ] ;
             [ <id: ID, IDENT, CID> <cId> ] ;
             [ <change: ON CHANGE, ACTION> <uAction,...> ] ;
    => ;
   [ <oSlider> := ] TSwSlider():New( <nRow>, <nCol>, <nWidth>, <nHeight>, <nValue>, <nMin>, <nMax>, <oWnd>, <cId>, [\{| nVal, self |(<uAction>)\}], <nAnchor> )

#xcommand @ <nRow>, <nCol> WEBVIEW [ <oWeb> ] ;
              [ URL <cUrl> ] ;
              [ OF <oWnd> ] ;
              [ SIZE <nWidth>, <nHeight> ] ;
              [ <res: AUTORESIZE, ANCHOR> <nAnchor> ] ;
              [ ID <cId> ] ;
    => ;
    [ <oWeb> := ] TSwWebView():New( <nRow>, <nCol>, <nWidth>, <nHeight>, <cUrl>, <oWnd>, <cId>, <nAnchor> )

#xcommand @ <nRow>, <nCol> IMAGE [ <oImg> ] ;
              [ SYMBOL <cSymbol> ] ;
              [ FILE <cFile> ] ;
              [ URL <cUrl> ] ;
              [ OF <oWnd> ] ;
              [ SIZE <nWidth>, <nHeight> ] ;
              [ <res: AUTORESIZE, ANCHOR> <nAnchor> ] ;
              [ ID <cId> ] ;
     => ;
     [ <oImg> := ] TSwImage():New( <nRow>, <nCol>, <nWidth>, <nHeight>, <oWnd>, <cSymbol>, <cFile>, <cUrl>, <cId>, <nAnchor> )

//----------------------------------------------------------------------------//
// CONTENEDORES (Stacks y Listas)
//----------------------------------------------------------------------------//

#xcommand @ <nRow>, <nCol> LIST [ <oList> ] ;
              [ OF <oWnd> ] ;
              [ SIZE <nWidth>, <nHeight> ] ;
              [ <res: AUTORESIZE, ANCHOR> <nAnchor> ] ;
              [ ACTION <uAction,...> ] ;
              [ ID <cId> ] ;
    => ;
    [ <oList> := ] TSwList():New( <nRow>, <nCol>, <nWidth>, <nHeight>, <oWnd>, <cId>, <nAnchor>, [\{| nRow, self |(<uAction>)\}] )

#xcommand DEFINE HSTACK [ <oHStack> ] ;
              [ OF <oParent> ] ;
              [ SIZE <nWidth>, <nHeight> ] ;
              [ AT <nRow>, <nCol> ] ;
              [ <res: AUTORESIZE, ANCHOR> <nAnchor> ] ;
              [ <lScr: SCROLL> ] ;
              [ ID <cId> ] ;
    => ;
    [ <oHStack> := ] TSwHStack():New( <nRow>, <nCol>, <nWidth>, <nHeight>, <oParent>, <cId>, <nAnchor> ) ;
    [; <oHStack>:lScroll := <.lScr.> ]

#xcommand DEFINE VSTACK [ <oVStack> ] ;
              [ OF <oParent> ] ;
              [ SIZE <nWidth>, <nHeight> ] ;
              [ AT <nRow>, <nCol> ] ;
              [ <res: AUTORESIZE, ANCHOR> <nAnchor> ] ;
              [ <lScr: SCROLL> ] ;
              [ ID <cId> ] ;
    => ;
    [ <oVStack> := ] TSwVStack():New( <nRow>, <nCol>, <nWidth>, <nHeight>, <oParent>, <cId>, <nAnchor> ) ;
    [; <oVStack>:lScroll := <.lScr.> ]
 
 #xcommand DEFINE ROW [ <oRow> ] ;
               OF <oList> ;
               [ ID <cId> ] ;
       => ;
       [ <oRow> := ] <oList>:AddRow( [<cId>] )


#endif
