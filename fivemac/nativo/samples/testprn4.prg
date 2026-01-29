#include "fivemac.ch"

static oPrn

function Main()

   local oDlg

   DEFINE DIALOG oDlg TITLE "Printer test"

   @ 40, 40 BUTTON "Print" OF oDlg ACTION Print()

   ACTIVATE DIALOG oDlg

return nil

function Print()

   local nWidth, nHeight

   oPrn = TPrinter():New()

   oPrn:SetLeftMargin( 0 )
   oPrn:SetRightMargin( 0 )
   oPrn:SetTopMargin( 0 )
   oPrn:SetBottomMargin( 0 )
   oPrn:SetPaperName( "A6" )
   oPrn:SetPagOrientation( 0 )

oprn:startpage()

   ?oprn:GetaSizePrintable()[ 2 ]
? oprn:npages
   ? oPrn:rowpos( 5 )
   ?  oprn:GetHeightPos( 99 )
  // oPrn:AutoPage( .T. )

  oPrn:GetPagOrientation()

 ?  nHeight := oPrn:GetPrintableHeight()
 ?  nWidth  := oPrn:GetPrintableWidth()

   oPrn:SetSize( nWidth, nHeight )

 oPrn:Run()

return nil

//------------------------------------------------

#define        UNITS_CM        101
#define        UNITS_INCHES    102
#define        UNITS_PIXELS    103

#define        CVT_P2I        72.0
#define        CVT_C2I        2.54
#define        CVT_P2C        (CVT_P2I / CVT_C2I)


Function ConverMesure( nMedida, cIni, cFin )

local aFactores := {  1, 1/CVT_C2I, CVT_P2C, CVT_C2I,1,CVT_P2I, 1/CVT_P2C, 1/CVT_P2I, 1  }
local rr := cIni - UNITS_CM
local cc := cFin - UNITS_CM
local cf

if ( rr < 0 .or. rr > 2 )
   return ( 0 )
endif

if ( cc < 0 .or. cc > 2 )
   return ( 0 )
endif
cf := aFactores[ rr *3 + cc]
return ( cf * nMedida )



/*
function PrinterPaint()

   local nStep, n, nLine := 1
   local  nHeight := oPrn:GetPrintableHeight()

    nStep =   nHeight/30 // 30 lines

   for n = 1 to nHeight  STEP nStep
      @ n, 0 SAY Str( nLine++ ) OF oPrn
   next
   
return nil
*/
