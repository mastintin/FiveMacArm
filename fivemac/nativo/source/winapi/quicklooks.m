#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h> // Usamos Quartz directamente
#import <QuickLookUI/QuickLookUI.h>

#include <fivemac.h>
#include <hbapi.h>

@interface ExcelBoss
    : NSObject <QLPreviewPanelDataSource, QLPreviewPanelDelegate>
@property(strong) NSURL *url;
@end

@implementation ExcelBoss
+ (instancetype)shared {
  static ExcelBoss *i = nil;
  static dispatch_once_t once;
  dispatch_once(&once, ^{
    i = [[ExcelBoss alloc] init];
  });
  return i;
}
- (NSInteger)numberOfPreviewItemsInPreviewPanel:(QLPreviewPanel *)panel {
  return 1;
}
- (id<QLPreviewItem>)previewPanel:(QLPreviewPanel *)panel
               previewItemAtIndex:(NSInteger)index {
  return self.url;
}
- (BOOL)acceptsPreviewPanelControl:(QLPreviewPanel *)panel {
  return YES;
}
@end

//----------------------------------------------------------------------//

HB_FUNC(ABRIREXCEL) {
  NSString *path =
      [[[NSString alloc] initWithUTF8String:hb_parc(1)] autorelease];
  if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
    [ExcelBoss shared].url = [NSURL fileURLWithPath:path];

    QLPreviewPanel *panel = [QLPreviewPanel sharedPreviewPanel];
    panel.dataSource = [ExcelBoss shared];
    panel.delegate = [ExcelBoss shared];

    // FORZAR VENTANA INDEPENDIENTE (Esto habilita el Zoom del Magic Mouse)
    [panel makeKeyAndOrderFront:nil];
    [panel reloadData];
  }
}

//----------------------------------------------------------------------//

HB_FUNC(QLPREVIEWCREATE) {
  NSWindow *window = (NSWindow *)hb_parnll(5);
  NSView *vParent = GetView(window);
  NSRect frame = NSMakeRect(hb_parnl(2), hb_parnl(1), hb_parnl(3), hb_parnl(4));

  // Creamos y marcamos para liberación automática
  QLPreviewView *preview = [[[QLPreviewView alloc]
      initWithFrame:frame
              style:QLPreviewViewStyleNormal] autorelease];

  [preview setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];

  if (vParent) {
    // Al añadirlo a la vista, vParent le hace un 'retain' (incrementa el
    // contador) Esto evita que el objeto muera cuando el autorelease actúe.
    [vParent addSubview:preview];
  }

  hb_retnll((HB_LONGLONG)preview);
}

//----------------------------------------------------------------------//

HB_FUNC(QLPREVIEWSETFILE) {
  QLPreviewView *preview = (QLPreviewView *)hb_parnll(1);
  NSString *cPath = hb_NSSTRING_par(2);

  if (preview && cPath) {
    // fileURLWithPath devuelve un objeto autorelease (no necesitas hacer
    // release tú)
    NSURL *url = [NSURL fileURLWithPath:cPath];

    // QLPreviewView suele manejar bien el retain de su previewItem,
    // pero es vital que el objeto 'preview' sea válido.
    [preview setPreviewItem:url];

    // Forzamos la recarga para que QuickLook procese el nuevo archivo
    // inmediatamente
    [preview refreshPreviewItem];
  }
}

//----------------------------------------------------------------------//

HB_FUNC(QLPREVIEWSETZOOM) {
  // Sin ScrollView, la magnificación nativa no está disponible directamente
  // Si necesitas zoom, QuickLook lo gestionará internamente si el archivo lo
  // permite
}
