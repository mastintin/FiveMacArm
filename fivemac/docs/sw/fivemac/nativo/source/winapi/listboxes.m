#import <Cocoa/Cocoa.h>
#define HB_DONT_DEFINE_BOOL
#include <fivemac.h>
#include <fmsgs.h>
#include <hbapi.h>
#include <hbapiitm.h>
#include <hbstack.h>
#include <hbvm.h>

/*
 * FMListBox: Motor modernizado con Callback Directo (Sin pasar por _FMH)
 */

@interface FMListBox
    : NSTableView <NSTableViewDataSource, NSTableViewDelegate> {
  NSMutableArray *aFullArray;      // Todos los elementos
  NSMutableArray *aFilteredArray;  // Solo los filtrados
  PHB_ITEM pAction; 
}
@property(retain) NSMutableArray *aFullArray;
@property(retain) NSMutableArray *aFilteredArray;

- (void)fillFromHarbour:(PHB_ITEM)pArray;
- (void)filterByString:(NSString *)searchString;
- (void)dblClick:(id)sender;
- (void)setAction:(PHB_ITEM)pBlock;
- (void)okModal:(id)sender;
@end

@implementation FMListBox

@synthesize aFullArray, aFilteredArray;

- (void)fillFromHarbour:(PHB_ITEM)pArray {
  if (!aFullArray) self.aFullArray = [[NSMutableArray alloc] init];
  if (!aFilteredArray) self.aFilteredArray = [[NSMutableArray alloc] init];

  [aFullArray removeAllObjects];
  [aFilteredArray removeAllObjects];

  if (pArray != NULL && hb_itemType(pArray) & HB_IT_ARRAY) {
    HB_SIZE nLen = hb_arrayLen(pArray);
    for (HB_SIZE i = 1; i <= nLen; i++) {
      PHB_ITEM pVal = hb_arrayGetItemPtr(pArray, i);
      if (pVal) {
        const char *szText = ValToChar(pVal);
        NSString * str = [NSString stringWithUTF8String:szText ? szText : ""];
        [aFullArray addObject: str];
        [aFilteredArray addObject: str];
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
            if ([item rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound) {
                [aFilteredArray addObject:item];
            }
        }
    }
    [self reloadData];
}

// Handler llamado por el NSSearchField
- (void)searchChanged:(id)sender {
    [self filterByString:[sender stringValue]];
}

- (void)setAction:(PHB_ITEM)pBlock {
  if (pAction) hb_itemRelease(pAction);
  if (pBlock) pAction = hb_itemNew(pBlock);
  else pAction = NULL;
}

- (void)dblClick:(id)sender {
  if ([self selectedRow] != -1 && pAction) hb_vmEvalBlock(pAction);
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
  NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"cell" owner:self];
  if (!cellView) {
    cellView = [[NSTableCellView alloc] initWithFrame:NSMakeRect(0, 0, tableColumn.width, tableView.rowHeight)];
    cellView.identifier = @"cell";
    NSTextField *textField = [[NSTextField alloc] initWithFrame:NSMakeRect(20, (tableView.rowHeight - 24) / 2, tableColumn.width - 40, 24)];
    [textField setBezeled:NO];
    [textField setDrawsBackground:NO];
    [textField setEditable:NO];
    [textField setSelectable:NO];
    [textField setTextColor:[NSColor blackColor]];
    [textField setFont:[NSFont systemFontOfSize:17 weight:NSFontWeightMedium]];
    [textField setAlignment:NSTextAlignmentLeft];
    [[textField cell] setUsesSingleLineMode:YES];
    [[textField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
    cellView.textField = textField;
    [cellView addSubview:textField];
    textField.autoresizingMask = NSViewWidthSizable | NSViewMinYMargin | NSViewMaxYMargin;
  }
  if (aFilteredArray && row < [aFilteredArray count]) {
    cellView.textField.stringValue = [aFilteredArray objectAtIndex:row];
  }
  return cellView;
}

- (void)dealloc {
  if (aFullArray) [aFullArray release];
  if (aFilteredArray) [aFilteredArray release];
  if (pAction) hb_itemRelease(pAction);
  [super dealloc];
}
@end

// --- Bridge Functions ---

HB_FUNC(LISTCREATE) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSRect frame = NSMakeRect(hb_parnl(2), hb_parnl(1), hb_parnl(3), hb_parnl(4));
  NSWindow *window = (NSWindow *)hb_parnll(5);

  NSScrollView *sv = [[NSScrollView alloc] initWithFrame:frame];
  [sv setHasVerticalScroller:YES];
  [sv setHasHorizontalScroller:NO];
  [sv setBorderType:NSNoBorder];
  [sv setAutohidesScrollers:YES];
  [sv setDrawsBackground:NO];

  FMListBox *tableView = [[FMListBox alloc] initWithFrame:[[sv contentView] frame]];
  [tableView setIdentifier:@"listbox"];
  NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@"main"];
  [column setResizingMask:NSTableColumnAutoresizingMask];
  [column setEditable:NO];
  [column setWidth:frame.size.width];
  [tableView setHeaderView:nil];
  [tableView addTableColumn:column];
  [column release];
  [tableView setRowHeight:44.0];
  [tableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleRegular];
  [tableView setFocusRingType:NSFocusRingTypeNone];
  [tableView setBackgroundColor:[NSColor clearColor]];
  [tableView setDataSource:tableView];
  [tableView setDelegate:tableView];
  [tableView setTarget:tableView];
  [tableView setDoubleAction:@selector(dblClick:)];
  [[sv contentView] setDrawsBackground:NO];
  [sv setDocumentView:tableView];
  [GetView(window) addSubview:sv];
  [sv release];
  hb_retnll((HB_LONGLONG)tableView);
  [pool release];
}

HB_FUNC(LISTSETDBLACTION) {
  FMListBox *tableView = (FMListBox *)hb_parnll(1);
  PHB_ITEM pBlock = hb_param(2, HB_IT_BLOCK);
  if (tableView && pBlock) [tableView setAction: pBlock];
}

HB_FUNC(LISTSETITEMS) {
  FMListBox *tableView = (FMListBox *)hb_parnll(1);
  PHB_ITEM pArray = hb_param(2, HB_IT_ARRAY);
  if (tableView && pArray) [tableView fillFromHarbour: pArray];
}

HB_FUNC(LISTGETPOS) {
  FMListBox *tableView = (FMListBox *)hb_parnll(1);
  if (tableView && [tableView selectedRow] != -1) {
    NSString *selected = [tableView.aFilteredArray objectAtIndex:[tableView selectedRow]];
    NSUInteger idx = [tableView.aFullArray indexOfObject:selected];
    hb_retnl((long)idx + 1);
  } else {
    hb_retnl(0);
  }
}

HB_FUNC(LISTREFRESH) {
  FMListBox *tableView = (FMListBox *)hb_parnll(1);
  if (tableView) [tableView reloadData];
}

HB_FUNC(LISTSETSELECT) {
  FMListBox *tableView = (FMListBox *)hb_parnll(1);
  if (tableView) {
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:hb_parnl(2) - 1];
    [tableView selectRowIndexes:indexSet byExtendingSelection:NO];
    [tableView scrollRowToVisible:hb_parnl(2) - 1];
  }
}

HB_FUNC(LISTSETSEARCH) {
  FMListBox *tableView = (FMListBox *)hb_parnll(1);
  NSSearchField *search = (NSSearchField *)hb_parnll(2);
  if (tableView && search) {
    [search setTarget:tableView];
    [search setAction:@selector(searchChanged:)];
  }
}

// --- FUNCIÓN C PURA: Muestre una lista en un diálogo nativo con FILTRO ---
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

    // --- CONTENEDOR PRINCIPAL (BUSCADOR + TABLA) ---
    NSView * container = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, w, h + 45)];
    
    // 1. BUSCADOR (NSSearchField)
    NSSearchField * search = [[NSSearchField alloc] initWithFrame:NSMakeRect(0, h + 10, w, 24)];
    [search setPlaceholderString:@"Escriba para buscar..."];
    
    // 2. SCROLL Y TABLA
    NSScrollView *sv = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, w, h)];
    [sv setHasVerticalScroller:YES];
    [sv setAutohidesScrollers:YES];
    [sv setBorderType:NSBezelBorder];

    FMListBox *tv = [[FMListBox alloc] initWithFrame:[sv bounds]];
    NSTableColumn *col = [[NSTableColumn alloc] initWithIdentifier:@"col"];
    [col setWidth:w]; [tv addTableColumn:col]; [col release];
    [tv setHeaderView:nil];
    [tv setRowHeight:30];
    [tv setDataSource:tv];
    [tv setDelegate:tv];
    [tv fillFromHarbour:aItems];
    [sv setDocumentView:tv];

    // CONEXIONES
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
      if([tv selectedRow] != -1) {
          NSString * selected = [tv.aFilteredArray objectAtIndex:[tv selectedRow]];
          NSUInteger idx = [tv.aFullArray indexOfObject:selected];
          nResult = (int)idx + 1;
      }
    }

    [tv release]; [sv release]; [search release]; [container release]; [alert release];
  }

  [pool drain];
  return nResult;
}

HB_FUNC(MSGSELECTLISTNATIVE) {
  hb_retni(FM_MsgSelectList(hb_NSSTRING_par(1), hb_param(2, HB_IT_ARRAY),
                            HB_ISNUM(3) ? hb_parnd(3) : 350,
                            HB_ISNUM(4) ? hb_parnd(4) : 400));
}
