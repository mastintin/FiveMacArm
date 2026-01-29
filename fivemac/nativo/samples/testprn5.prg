
#include "FiveMac.ch"

*a test program for printing multiple pages 
*made by René Koot

#xcommand @ <nRow>, <nCol> SAY [ <oSay> PROMPT ] <cText> ;
OF <oPrn> PAGINED ;
[ SIZE <nWidth>, <nHeight> ] ;
[ <raised: RAISED> ] ;
[ <cPostext: TEXTLEFT, TEXTRIGHT, TEXTCENTER> ] ;
[ AUTORESIZE <nAutoResize> ] ;
[ TOOLTIP <cToolTip> ] ;
[ <lutf8: UTF8 > ] ;
[ PIXEL ] ;
=> ;
[ <oSay> := ] TSay():New( oPrn:RowPos(<nRow>), <nCol>, <nWidth>, <nHeight>,;
<oPrn>, <cText>, <.raised.>, [ Upper(<(cPostext)>) ],;
[<nAutoResize>], [<cToolTip>], [<(oSay)>] )


#xcommand @ <nRow>, <nCol> IMAGE [ <oImg> ] ;
 OF <oPrn> PAGINED ;
[ SIZE <nWidth>, <nHeight> ] ;
[ FILENAME <cFileName> ] ;
[ <resource: NAME, RESOURCE, RESNAME> <cResName> ] ;
[ TOOLTIP <cToolTip> ] ;
=> ;
[ <oImg> := ] TImage():New( oPrn:RowPos(<nRow>), <nCol>, <nWidth>, <nHeight>,;
<oPrn>, [<cFileName>], [<cResName>], [<cToolTip> ], [<(oImg)>]  )


FUNCTION Main()

   LOCAL oDlg
   
   DEFINE DIALOG oDlg TITLE "Dialog"
   
   @ 40, 40 BUTTON "print" OF oDlg ACTION RK_PrintTest()
   
   DEFINE MSGBAR OF oDlg
   
   ACTIVATE DIALOG oDlg
   
RETURN NIL   

*************************************************

FUNCTION RK_PrintTest()


LOCAL nCol := 28
LOCAL nRow := 0
LOCAL nRowHeight := 0
LOCAL n
LOCAL oSay, oImg

LOCAL aPrintArray[0][5]

AADD(aPrintArray, {'Line 1_1', 'Line2_1', 'Line3_1', 'Line4_1', 'Line5_1'})
AADD(aPrintArray, {'Line 1_2', 'Line2_2', 'Line3_2', 'Line4_2', 'Line5_2'})
AADD(aPrintArray, {'Line 1_3', 'Line2_3', 'Line3_3', 'Line4_3', 'Line5_3'})
AADD(aPrintArray, {'Line 1_4', 'Line2_4', 'Line3_4', 'Line4_4', 'Line5_4'})
AADD(aPrintArray, {'Line 1_5', 'Line2_5', 'Line3_5', 'Line4_5', 'Line5_5'})
AADD(aPrintArray, {'Line 1_6', 'Line2_6', 'Line3_6', 'Line4_6', 'Line5_6'})
AADD(aPrintArray, {'Line 1_7', 'Line2_7', 'Line3_1', 'Line4_1', 'Line5_1'})
AADD(aPrintArray, {'Line 1_8', 'Line2_8', 'Line3_2', 'Line4_2', 'Line5_2'})
AADD(aPrintArray, {'Line 1_9', 'Line2_9', 'Line3_3', 'Line4_3', 'Line5_3'})
AADD(aPrintArray, {'Line 1_10', 'Line2_10', 'Line3_4', 'Line4_4', 'Line5_4'})
AADD(aPrintArray, {'Line 1_11', 'Line2_11', 'Line3_5', 'Line4_5', 'Line5_5'})
AADD(aPrintArray, {'Line 1_12', 'Line2_12', 'Line3_6', 'Line4_6', 'Line5_6'})
AADD(aPrintArray, {'Line 1_13', 'Line2_13', 'Line3_1', 'Line4_1', 'Line5_1'})
AADD(aPrintArray, {'Line 1_14', 'Line2_14', 'Line3_2', 'Line4_2', 'Line5_2'})
AADD(aPrintArray, {'Line 1_15', 'Line2_15', 'Line3_3', 'Line4_3', 'Line5_3'})
AADD(aPrintArray, {'Line 1_16', 'Line2_16', 'Line3_4', 'Line4_4', 'Line5_4'})
AADD(aPrintArray, {'Line 1_17', 'Line2_17', 'Line3_5', 'Line4_5', 'Line5_5'})
AADD(aPrintArray, {'Line 1_18', 'Line2_18', 'Line3_6', 'Line4_6', 'Line5_6'})

PUBLIC nPage
PUBLIC nPagePx := 813

PUBLIC oPrn:=TPrinter():new()

oPrn:SetLeftMargin(0)
oPrn:SetRightMargin(0)
oPrn:SetTopMargin(0)
oPrn:SetbottomMargin(0)
oPrn:SetPaperName("A4")
oPrn:AutoPage(.T.)

oPrn:nRowsPerPage := nPagePx

nHeight := oPrn:GetPrintableHeight()
nWidth  := oPrn:GetPrintableWidth()

oPrn:SetSize( nWidth, nHeight * LEN(aPrintArray) )

cFoto :=  cGetfile("escoge la imagen ")

 oPrn:StartPage()

@ 2, nCol SAY oSay PROMPT aPrintArray[1,2] OF oPrn SIZE 240, 40
oSay:Setfont("Arial",12 )
oSay:setBkColor(0, 0, 255,100)
oSay:setBezeled(.t.,.f.)

oPrn:endpage()

FOR nPage = 1 TO LEN(aPrintArray)

    oPrn:StartPage()

@ 60, nCol SAY oSay PROMPT "HOLA como estas esto es muy grande " OF oPrn PAGINED TEXTCENTER //SIZE 480, 40
oSay:Setfont("Arial",12 )
oSay:setBkColor(0, 0, 255,100)
oSay:setBezeled(.t.,.f.)
          //  oSay:Setfont("Arial",20 )
          //  oSay:setTextColor(0,51,0,100)

      //  @ 30, 285 IMAGE oImg OF oPrn PAGINED SIZE 250, 250 FILENAME cFoto
        
         @ 30, 285 IMAGE oImg OF oPrn  SIZE 250, 250 FILENAME cFoto
         oImg:SetScaling( 3 )
         oImg:SetFrame()



   //     @ 300, nCol SAY oSay PROMPT aPrintArray[nPage,2] OF oPrn PAGINED SIZE 240, 18
   //         oSay:Setfont("Arial",12 )

   //     @ 330, nCol SAY oSay PROMPT aPrintArray[nPage,3] OF oPrn PAGINED SIZE 240, 18
   //         oSay:Setfont("Arial",12 )


    //    @ 360, nCol SAY oSay PROMPT aPrintArray[nPage,4] OF oPrn PAGINED SIZE 240, 18
    //        oSay:Setfont("Arial",12 )


      //  @ 390 ,nCol SAY oSay PROMPT aPrintArray[nPage,5] OF oPrn PAGINED SIZE 240, 18
      //      oSay:Setfont("Arial",12 )

        RK_PrintFooter()

    oPrn:EndPage()

NEXT

oPrn:run()

RETURN NIL

*************************************************

FUNCTION RK_PrintFooter()

local nWidth  := oPrn:GetPrintableWidth()

//@ 780 , 28 SAY oSay PROMPT CHR(0169) + ' Copyright: Plantenkennis versie ' OF oPrn PAGINED SIZE nWidth- 112, 20
//oSay:Setfont("Arial",12 )

//@ 780 , 450 SAY oSay PROMPT 'page ' + ALLTRIM(STR(nPage)) OF oPrn PAGINED SIZE nWidth - 112, 20
//oSay:Setfont("Arial",12 )


RETURN NIL

