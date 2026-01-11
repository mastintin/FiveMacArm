
#include <fivemac.h>

static NSColorPanel * oColorPanel;

HB_FUNC( CHOOSECOLOR )
{
   NSColor * oColor;
   int nRed, nGreen, nBlue;
   
   if( oColorPanel == nil )
      oColorPanel = [ NSColorPanel sharedColorPanel ];
      
   if( hb_pcount() > 0 )
   {
      nRed   = hb_parnl( 1 ) & 0xFF;
      nGreen = ( hb_parnl( 1 ) >> 8 ) & 0xFF;
      nBlue  = ( hb_parnl( 1 ) >> 16 ) & 0xFF;
      
      oColor = [ NSColor colorWithCalibratedRed: ( float ) nRed / 255.0 green: ( float ) nGreen / 255.0 blue: ( float ) nBlue / 255.0 alpha: 1.0 ];
      [ oColorPanel setColor: oColor ]; 
   }   
      
   [ NSApp runModalForWindow: oColorPanel ];
   
   oColor = [ oColorPanel color ];
   
   nRed   = ( int ) ( [ oColor redComponent ] * 255.0 );
   nGreen = ( int ) ( [ oColor greenComponent ] * 255.0 );
   nBlue  = ( int ) ( [ oColor blueComponent ] * 255.0 );

   hb_retnl( nRed + ( nGreen << 8 ) + ( nBlue << 16 ) );
}
