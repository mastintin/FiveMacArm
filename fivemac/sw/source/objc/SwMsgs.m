#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
#include <fivemac.h>
#import <hbapi.h>

//----------------------------------------------------------------------------//
// MENSAJES SÍNCRONOS (MODALES) EN OBJECTIVE-C
// Basados en NSAlert para máxima estabilidad con el hilo principal de Harbour
// Gestión de memoria manual (MRC) con NSAutoreleasePool
//----------------------------------------------------------------------------//

extern PHB_ITEM hb_vmEvalBlock(PHB_ITEM pBlock);

#define hb_NSSTRING_VAL_par hb_NSSTRING_par

NSString *hb_NSSTRING_par(int iParam) {
  const char *szText = hb_parc(iParam);
  return [[[NSString alloc] initWithUTF8String:(szText ? szText : "")]
      autorelease];
}

// Funciones migradas a Swift: MsgBeep, MsgInfo, MsgYesNo, etc.

//----------------------------------------------------------------------------//
// FMListBox: Motor de selección vertical con buscador nativo
//----------------------------------------------------------------------------//

@interface FMListBox
    : NSTableView <NSTableViewDataSource, NSTableViewDelegate> {
  NSMutableArray *aFullArray;     // Todos los elementos
  NSMutableArray *aFilteredArray; // Solo los filtrados
  PHB_ITEM pAction;
}
@property(retain) NSMutableArray *aFullArray;
@property(retain) NSMutableArray *aFilteredArray;
- (void)fillFromHarbour:(PHB_ITEM)pArray;
- (void)filterByString:(NSString *)searchString;
- (void)okModal:(id)sender;
@end

@implementation FMListBox
@synthesize aFullArray, aFilteredArray;

- (void)fillFromHarbour:(PHB_ITEM)pArray {
  if (!aFullArray)
    self.aFullArray = [NSMutableArray array];
  if (!aFilteredArray)
    self.aFilteredArray = [NSMutableArray array];

  [aFullArray removeAllObjects];
  [aFilteredArray removeAllObjects];

  if (pArray != NULL && hb_itemType(pArray) & HB_IT_ARRAY) {
    HB_SIZE nLen = hb_arrayLen(pArray);
    for (HB_SIZE i = 1; i <= nLen; i++) {
      PHB_ITEM pVal = hb_arrayGetItemPtr(pArray, i);
      if (pVal) {
        const char *szText = hb_itemGetCPtr(pVal);
        NSString *str = [NSString stringWithUTF8String:szText ? szText : ""];
        [aFullArray addObject:str];
        [aFilteredArray addObject:str];
      }
    }
  }
  [self reloadData];
}

- (void)filterByString:(NSString *)searchString {
  [aFilteredArray removeAllObjects];
  if ([searchString length] == 0) {
    [aFilteredArray addObjectsFromArray:aFullArray];
  } else {
    for (NSString *item in aFullArray) {
      if ([item rangeOfString:searchString options:NSCaseInsensitiveSearch]
              .location != NSNotFound) {
        [aFilteredArray addObject:item];
      }
    }
  }
  [self reloadData];
}

- (void)searchChanged:(id)sender {
  [self filterByString:[sender stringValue]];
}

- (void)okModal:(id)sender {
  [NSApp stopModalWithCode:NSAlertFirstButtonReturn];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
  return aFilteredArray ? [aFilteredArray count] : 0;
}

- (NSView *)tableView:(NSTableView *)tableView
    viewForTableColumn:(NSTableColumn *)tableColumn
                   row:(NSInteger)row {
  NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"cell"
                                                          owner:self];
  if (!cellView) {
    cellView = [[NSTableCellView alloc]
        initWithFrame:NSMakeRect(0, 0, tableColumn.width, 24)];
    cellView.identifier = @"cell";
    NSTextField *textField = [[NSTextField alloc]
        initWithFrame:NSMakeRect(5, 0, tableColumn.width - 10, 24)];
    [textField setBezeled:NO];
    [textField setDrawsBackground:NO];
    [textField setEditable:NO];
    [textField setTextColor:[NSColor labelColor]];
    [textField setFont:[NSFont systemFontOfSize:13]];
    cellView.textField = textField;
    [cellView addSubview:textField];
  }
  if (aFilteredArray && row < [aFilteredArray count]) {
    cellView.textField.stringValue = [aFilteredArray objectAtIndex:row];
  }
  return cellView;
}

- (void)dealloc {
  if (aFullArray)
    [aFullArray release];
  if (aFilteredArray)
    [aFilteredArray release];
  [super dealloc];
}
@end

//----------------------------------------------------------------------------//

int FM_MsgSelectList(NSString *title, PHB_ITEM aItems, CGFloat w, CGFloat h) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  int nResult = 0;

  if (title && aItems) {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:title];
    [alert setInformativeText:@"Filtre y seleccione:"];
    [alert setAlertStyle:NSAlertStyleInformational];
    [alert addButtonWithTitle:@"Aceptar"];
    [alert addButtonWithTitle:@"Cancelar"];

    NSView *container =
        [[NSView alloc] initWithFrame:NSMakeRect(0, 0, w, h + 45)];
    NSSearchField *search =
        [[NSSearchField alloc] initWithFrame:NSMakeRect(0, h + 10, w, 24)];
    [search setPlaceholderString:@"Escriba para buscar..."];

    NSScrollView *sv =
        [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, w, h)];
    [sv setHasVerticalScroller:YES];
    [sv setAutohidesScrollers:YES];
    [sv setBorderType:NSBezelBorder];

    FMListBox *tv = [[FMListBox alloc] initWithFrame:[sv bounds]];
    NSTableColumn *col = [[NSTableColumn alloc] initWithIdentifier:@"col"];
    [col setWidth:w];
    [tv addTableColumn:col];
    [col release];
    [tv setHeaderView:nil];
    [tv setRowHeight:24];
    [tv setDataSource:tv];
    [tv setDelegate:tv];
    [tv fillFromHarbour:aItems];
    [sv setDocumentView:tv];

    [search setTarget:tv];
    [search setAction:@selector(searchChanged:)];
    [container addSubview:search];
    [container addSubview:sv];
    [alert setAccessoryView:container];

    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    [tv setTarget:tv];
    [tv setDoubleAction:@selector(okModal:)];

    NSModalResponse response = [alert runModal];

    if (response == NSAlertFirstButtonReturn) {
      if ([tv selectedRow] != -1) {
        NSString *selected = [tv.aFilteredArray objectAtIndex:[tv selectedRow]];
        NSUInteger idx = [tv.aFullArray indexOfObject:selected];
        nResult = (int)idx + 1;
      }
    }
    [tv release];
    [sv release];
    [search release];
    [container release];
    [alert release];
  }
  [pool drain];
  return nResult;
}

HB_FUNC(NAT_MSGSELECTLIST) {
  hb_retni(FM_MsgSelectList(hb_NSSTRING_par(1), hb_param(2, HB_IT_ARRAY),
                            HB_ISNUM(3) ? hb_parnd(3) : 350,
                            HB_ISNUM(4) ? hb_parnd(4) : 400));
}

//----------------------------------------------------------------------------//

// MSGGET eliminado - ahora se usa la versión Swift en SwiftSystem.swift

//----------------------------------------------------------------------------//

// MSGGETMULTILINE eliminado - ahora se usa la versión Swift en
// SwiftSystem.swift

// NAT_MSGRUN eliminado - ahora se usa el wrapper en SwSystem.prg que llama a
// MAC_MSGSTATUS
