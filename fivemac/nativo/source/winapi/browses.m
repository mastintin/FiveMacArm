#import <QuartzCore/QuartzCore.h>
#include <fivemac.h>

static PHB_SYMB symFMH = NULL;

// -------------------------------------------------------------------------------
// BrwImageAndTextCell: Clase para celdas con imagen y texto
// -------------------------------------------------------------------------------
#define kIconImageSize 22.0
#define kImageOriginXOffset 0
#define kImageOriginYOffset 0
#define kTextOriginXOffset 0
#define kTextOriginYOffset 0
#define kTextHeightAdjust 0

@interface BrwImageAndTextCell : NSTextFieldCell {
  NSImage *image;
}
- (void)setImage:(NSImage *)anImage;
- (NSImage *)image;
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
- (NSSize)cellSize;
@end

@implementation BrwImageAndTextCell
- (void)dealloc {
  if (image)
    [image release];
  [super dealloc];
}
- (id)copyWithZone:(NSZone *)zone {
  BrwImageAndTextCell *cell = (BrwImageAndTextCell *)[super copyWithZone:zone];
  cell->image = [image retain];
  return cell;
}
- (void)setImage:(NSImage *)anImage {
  if (anImage != image) {
    [image release];
    image = [anImage retain];
    [image setSize:NSMakeSize(kIconImageSize, kIconImageSize)];
  }
}
- (NSImage *)image {
  return image;
}
- (NSRect)titleRectForBounds:(NSRect)cellRect {
  NSSize imageSize = [image size];
  NSRect imageFrame;
  NSDivideRect(cellRect, &imageFrame, &cellRect, 3 + imageSize.width,
               NSMinXEdge);
  return cellRect;
}
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
  if (image != nil) {
    NSSize imageSize = [image size];
    NSRect imageFrame;
    NSDivideRect(cellFrame, &imageFrame, &cellFrame, 3 + imageSize.width,
                 NSMinXEdge);
    imageFrame.origin.y += ceil((cellFrame.size.height - imageSize.height) / 2);
    imageFrame.size = imageSize;
    NSRect newFrame = cellFrame;
    newFrame.origin.x -= 25;
    newFrame.size.width += 25;
    [super drawWithFrame:newFrame inView:controlView];
    [image drawInRect:imageFrame
              fromRect:NSZeroRect
             operation:NSCompositingOperationSourceOver
              fraction:1.0
        respectFlipped:YES
                 hints:nil];
  } else {
    [super drawWithFrame:cellFrame inView:controlView];
  }
}
- (NSSize)cellSize {
  NSSize cellSize = [super cellSize];
  cellSize.width += (image ? [image size].width : 0) + 3;
  return cellSize;
}
@end

// -------------------------------------------------------------------------------
// Wbrowse: Clase principal de la tabla (Control + DataSource + Delegate)
// -------------------------------------------------------------------------------
@interface Wbrowse : NSTableView <NSTableViewDelegate, NSTableViewDataSource> {
@public
  int nRow;
@public
  int nCol;
}
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification;
- (void)tableView:(Wbrowse *)tableView
    mouseDownInHeaderOfTableColumn:(NSTableColumn *)aTableColumn;
- (void)keyDown:(NSEvent *)theEvent;
- (void)drawRow:(NSInteger)row clipRect:(NSRect)clipRect;
- (void)tableView:(Wbrowse *)aTableView
    willDisplayCell:(id)aCell
     forTableColumn:(NSTableColumn *)aTableColumn
                row:(NSInteger)rowIndex;
- (void)mouseDown:(NSEvent *)theEvent;
- (void)rightMouseDown:(NSEvent *)theEvent;
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView;
- (id)tableView:(NSTableView *)aTableView
    objectValueForTableColumn:(NSTableColumn *)aTableColumn
                          row:(NSInteger)rowIndex;
- (void)tableView:(NSTableView *)aTableView
    setObjectValue:(id)aData
    forTableColumn:(NSTableColumn *)aTableColumn
               row:(NSInteger)rowIndex;
- (void)BrwDblClick:(id)sender;
@end

@implementation Wbrowse

- (void)dealloc {
  [self setDataSource:nil];
  [self setDelegate:nil];
  [super dealloc];
}

- (void)BrwDblClick:(id)sender {
  if (symFMH == NULL)
    symFMH = hb_dynsymSymbol(hb_dynsymFindName("_FMH"));
  hb_vmPushSymbol(symFMH);
  hb_vmPushNil();
  hb_vmPushNLL((HB_LONGLONG)[self window]);
  hb_vmPushLong(WM_BRWDBLCLICK); // CORREGIDO
  hb_vmPushNLL((HB_LONGLONG)self);
  hb_vmDo(3);
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
  if (symFMH == NULL)
    symFMH = hb_dynsymSymbol(hb_dynsymFindName("_FMH"));
  hb_vmPushSymbol(symFMH);
  hb_vmPushNil();
  hb_vmPushNLL((HB_LONGLONG)[self window]);
  hb_vmPushNLL(WM_BRWROWS);
  hb_vmPushNLL((HB_LONGLONG)self);
  hb_vmDo(3);
  return (NSInteger)hb_parnl(-1);
}

- (id)tableView:(NSTableView *)aTableView
    objectValueForTableColumn:(NSTableColumn *)aTableColumn
                          row:(NSInteger)rowIndex {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  if (symFMH == NULL)
    symFMH = hb_dynsymSymbol(hb_dynsymFindName("_FMH"));
  hb_vmPushSymbol(symFMH);
  hb_vmPushNil();
  hb_vmPushNLL((HB_LONGLONG)[self window]);
  hb_vmPushNLL(WM_BRWVALUE);
  hb_vmPushNLL((HB_LONGLONG)self);
  hb_vmPushNLL([[(NSTableColumn *)aTableColumn identifier] integerValue]);
  hb_vmPushNLL(rowIndex);
  hb_vmDo(5);

  const char *cStr = HB_ISCHAR(-1) ? hb_parc(-1) : "";
  NSString *string = [NSString stringWithUTF8String:cStr];
  NSCell *cell = [aTableColumn dataCell];

  if ([[cell className] isEqualToString:@"NSImageCell"]) {
    [pool release];
    return ([string length] > 0)
               ? [[[NSImage alloc] initWithContentsOfFile:string] autorelease]
               : nil;
  }

  if ([[cell className] isEqualToString:@"BrwImageAndTextCell"]) {
    NSString *filename = [NSString stringWithUTF8String:hb_parvc(-1, 1)];
    NSImage *image =
        (hb_parvl(-1, 3))
            ? [[NSWorkspace sharedWorkspace] iconForFile:filename]
            : [[[NSImage alloc] initWithContentsOfFile:filename] autorelease];
    [(BrwImageAndTextCell *)cell setImage:image];
    [pool release];
    return [NSString stringWithUTF8String:hb_parvc(-1, 2)];
  }

  [string retain];
  [pool release];
  return [string autorelease];
}

- (void)tableView:(NSTableView *)aTableView
    setObjectValue:(id)aData
    forTableColumn:(NSTableColumn *)aTableColumn
               row:(NSInteger)rowIndex {
  if (symFMH == NULL)
    symFMH = hb_dynsymSymbol(hb_dynsymFindName("_FMH"));
  hb_vmPushSymbol(symFMH);
  hb_vmPushNil();
  hb_vmPushNLL((HB_LONGLONG)[self window]);
  hb_vmPushNLL(WM_BRWSETVALUE);
  hb_vmPushNLL((HB_LONGLONG)self);
  hb_vmPushNLL([[(NSTableColumn *)aTableColumn identifier] integerValue]);
  hb_vmPushNLL(rowIndex);
  hb_vmPushNLL((HB_LONGLONG)aData);
  hb_vmDo(6);
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
  if (symFMH == NULL)
    symFMH = hb_dynsymSymbol(hb_dynsymFindName("_FMH"));
  hb_vmPushSymbol(symFMH);
  hb_vmPushNil();
  hb_vmPushNLL((HB_LONGLONG)[self window]);
  hb_vmPushLong(WM_BRWCHANGED);
  hb_vmPushNLL((HB_LONGLONG)self);
  hb_vmPushLong([self selectedRow]);
  hb_vmDo(4);
}

- (void)tableView:(Wbrowse *)tableView
    mouseDownInHeaderOfTableColumn:(NSTableColumn *)aTableColumn {
  if (symFMH == NULL)
    symFMH = hb_dynsymSymbol(hb_dynsymFindName("_FMH"));
  hb_vmPushSymbol(symFMH);
  hb_vmPushNil();
  hb_vmPushNLL((HB_LONGLONG)[self window]);
  hb_vmPushLong(WM_HEADCLICK);
  hb_vmPushNLL((HB_LONGLONG)self);
  hb_vmPushNLL([[(NSTableColumn *)aTableColumn identifier] integerValue]);
  hb_vmDo(4);
}

- (void)keyDown:(NSEvent *)theEvent {
  NSString *key = [theEvent characters];
  int unichar = [key characterAtIndex:0];
  if (symFMH == NULL)
    symFMH = hb_dynsymSymbol(hb_dynsymFindName("_FMH"));
  hb_vmPushSymbol(symFMH);
  hb_vmPushNil();
  hb_vmPushNLL((HB_LONGLONG)[self window]);
  hb_vmPushLong(WM_KEYDOWN);
  hb_vmPushNLL((HB_LONGLONG)self);
  hb_vmPushLong(unichar);
  hb_vmDo(4);
  if (hb_parnl(-1) != 1)
    [super keyDown:theEvent];
}

- (void)drawRow:(NSInteger)row clipRect:(NSRect)clipRect {
  if (symFMH == NULL)
    symFMH = hb_dynsymSymbol(hb_dynsymFindName("_FMH"));
  hb_vmPushSymbol(symFMH);
  hb_vmPushNil();
  hb_vmPushNLL((HB_LONGLONG)[self window]);
  hb_vmPushLong(WM_BRWDRAWRECT);
  hb_vmPushNLL((HB_LONGLONG)self);
  hb_vmPushLong(row);
  hb_vmDo(4);
  [super drawRow:row clipRect:clipRect];
}

- (void)tableView:(Wbrowse *)aTableView
    willDisplayCell:(id)aCell
     forTableColumn:(NSTableColumn *)aTableColumn
                row:(NSInteger)rowIndex {
  if (![[aCell className] isEqual:@"NSImageCell"]) {
    if (symFMH == NULL)
      symFMH = hb_dynsymSymbol(hb_dynsymFindName("_FMH"));
    hb_vmPushSymbol(symFMH);
    hb_vmPushNil();
    hb_vmPushNLL((HB_LONGLONG)[self window]);
    hb_vmPushLong(WM_BRWCLRTEXT);
    hb_vmPushNLL((HB_LONGLONG)self);
    hb_vmPushNLL((HB_LONGLONG)aTableColumn);
    hb_vmPushNLL(rowIndex);
    hb_vmDo(5);
    [aCell setTextColor:(NSColor *)hb_parnll(-1)];
  }
}

- (void)mouseDown:(NSEvent *)theEvent {
  NSPoint localLocation = [self convertPoint:[theEvent locationInWindow]
                                    fromView:nil];
  self->nRow = [self rowAtPoint:localLocation];
  self->nCol = [self columnAtPoint:localLocation] + 1;
  [super mouseDown:theEvent];
  if (symFMH == NULL)
    symFMH = hb_dynsymSymbol(hb_dynsymFindName("_FMH"));
  hb_vmPushSymbol(symFMH);
  hb_vmPushNil();
  hb_vmPushNLL((HB_LONGLONG)[self window]);
  hb_vmPushLong(WM_MOUSEDOWN);
  hb_vmPushNLL((HB_LONGLONG)self);
  hb_vmPushNLL(self->nRow);
  hb_vmPushNLL(self->nCol);
  hb_vmDo(5);
}

- (void)rightMouseDown:(NSEvent *)theEvent {
  NSPoint point = [theEvent locationInWindow];
  NSPoint localLocation = [self convertPoint:point fromView:nil];
  self->nRow = [self rowAtPoint:localLocation];
  self->nCol = [self columnAtPoint:localLocation] + 1;
  if (symFMH == NULL)
    symFMH = hb_dynsymSymbol(hb_dynsymFindName("_FMH"));
  hb_vmPushSymbol(symFMH);
  hb_vmPushNil();
  hb_vmPushNLL((HB_LONGLONG)[self window]);
  hb_vmPushLong(WM_RBUTTONDOWN);
  hb_vmPushNLL((HB_LONGLONG)self);
  hb_vmPushLong(point.y);
  hb_vmPushLong(point.x);
  hb_vmPushLong(self->nRow);
  hb_vmPushLong(self->nCol);
  hb_vmDo(7);
}
@end

HB_FUNC(BRWCREATE) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSScrollView *sv =
      [[NSScrollView alloc] initWithFrame:NSMakeRect(hb_parnl(2), hb_parnl(1),
                                                     hb_parnl(3), hb_parnl(4))];
  Wbrowse *browse;
  NSWindow *window = (NSWindow *)hb_parnll(5);
  [sv setHasVerticalScroller:YES];
  [sv setHasHorizontalScroller:YES];
  [sv setBorderType:NSBezelBorder];
  browse = [[Wbrowse alloc] initWithFrame:[[sv contentView] frame]];
  [sv setDocumentView:browse];
  [GetView(window) addSubview:sv];
  [browse setDelegate:browse];
  [browse setDataSource:browse];
  [browse setGridStyleMask:NSTableViewSolidVerticalGridLineMask |
                           NSTableViewSolidHorizontalGridLineMask];
  [browse setDoubleAction:@selector(BrwDblClick:)];
  browse->nRow = 0;
  browse->nCol = 0;
  [browse release];
  [sv release];
  hb_retnll((HB_LONGLONG)browse);
  [pool release];
}

HB_FUNC(BRWRESCREATE) {
  NSWindow *window = (NSWindow *)hb_parnll(1);
  Wbrowse *browse = (Wbrowse *)[GetView(window) viewWithTag:hb_parnl(2)];
  [browse setDelegate:browse];
  [browse setDataSource:browse];
  [browse setDoubleAction:@selector(BrwDblClick:)];
  browse->nRow = 0;
  browse->nCol = 0;
  for (int i = 0; i < [browse numberOfColumns]; i++) {
    NSTableColumn *column = [[browse tableColumns] objectAtIndex:i];
    [column setIdentifier:[NSString stringWithFormat:@"%i", i]];
    [column setEditable:NO];
  }
  hb_retnll((HB_LONGLONG)browse);
}

HB_FUNC(BRWSETSIZE) {
  Wbrowse *browse = (Wbrowse *)hb_parnll(1);
  [[browse enclosingScrollView]
      setFrameSize:NSMakeSize(hb_parnl(2), hb_parnl(3))];
}

HB_FUNC(BRWREFRESH) { [(Wbrowse *)hb_parnll(1) reloadData]; }

HB_FUNC(BRWADDCOLUMN) {
  Wbrowse *browse = (Wbrowse *)hb_parnll(1);
  NSTableColumn *column = [[[NSTableColumn alloc] init] autorelease];
  [column
      setIdentifier:[NSString
                        stringWithFormat:@"%i", (int)[browse numberOfColumns]]];
  [column setWidth:100];
  [column setEditable:NO];
  [[column headerCell] setStringValue:hb_NSSTRING_par(2)];
  [browse addTableColumn:column];
  hb_retnll((HB_LONGLONG)column);
}

HB_FUNC(COLSETHEADER) {
  [[(NSTableColumn *)hb_parnll(1) headerCell]
      setStringValue:hb_NSSTRING_par(2)];
}

HB_FUNC(BRWGOTOP) {
  Wbrowse *browse = (Wbrowse *)hb_parnll(1);
  [browse selectRowIndexes:[NSIndexSet indexSetWithIndex:0]
      byExtendingSelection:NO];
  [browse scrollRowToVisible:0];
}

HB_FUNC(BRWGOBOTTOM) {
  Wbrowse *browse = (Wbrowse *)hb_parnll(1);
  NSInteger iRows = [browse numberOfRows];
  if (iRows > 0) {
    [browse selectRowIndexes:[NSIndexSet indexSetWithIndex:iRows - 1]
        byExtendingSelection:NO];
    [browse scrollRowToVisible:iRows - 1];
  }
}

HB_FUNC(BRWGODOWN) {
  Wbrowse *browse = (Wbrowse *)hb_parnll(1);
  NSInteger row = [browse selectedRow];
  if (row < [browse numberOfRows] - 1) {
    [browse selectRowIndexes:[NSIndexSet indexSetWithIndex:row + 1]
        byExtendingSelection:NO];
    [browse scrollRowToVisible:row + 1];
  }
}

HB_FUNC(BRWGOUP) {
  Wbrowse *browse = (Wbrowse *)hb_parnll(1);
  NSInteger row = [browse selectedRow];
  if (row > 0) {
    [browse selectRowIndexes:[NSIndexSet indexSetWithIndex:row - 1]
        byExtendingSelection:NO];
    [browse scrollRowToVisible:row - 1];
  }
}

HB_FUNC(BRWROWPOS) { hb_retnl([(Wbrowse *)hb_parnll(1) selectedRow] + 1); }

HB_FUNC(BRWSETROWPOS) {
  Wbrowse *browse = (Wbrowse *)hb_parnll(1);
  NSInteger row = hb_parnl(2) - 1;
  [browse selectRowIndexes:[NSIndexSet indexSetWithIndex:row]
      byExtendingSelection:NO];
  [browse scrollRowToVisible:row];
}

HB_FUNC(BRWSETSELECT) {
  [(Wbrowse *)hb_parnll(1)
          selectRowIndexes:[NSIndexSet indexSetWithIndex:hb_parnl(2) - 1]
      byExtendingSelection:NO];
}

HB_FUNC(BRWGETSELECT) { hb_retnl([(Wbrowse *)hb_parnll(1) selectedRow] + 1); }

HB_FUNC(BRWSETCOLBMP) {
  Wbrowse *browse = (Wbrowse *)hb_parnll(1);
  NSTableColumn *column =
      [[browse tableColumns] objectAtIndex:(hb_parnl(2) - 1)];
  [column setDataCell:[[[NSImageCell alloc] init] autorelease]];
}

HB_FUNC(BRWSETCOLBMPTXT) {
  Wbrowse *browse = (Wbrowse *)hb_parnll(1);
  NSTableColumn *column =
      [[browse tableColumns] objectAtIndex:(hb_parnl(2) - 1)];
  [column setDataCell:[[[BrwImageAndTextCell alloc] init] autorelease]];
}

HB_FUNC(BRWSETGRIDLINES) {
  [(Wbrowse *)hb_parnll(1) setGridStyleMask:hb_parnl(2)];
}

HB_FUNC(BRWGETGRIDLINES) { hb_retnl([(Wbrowse *)hb_parnll(1) gridStyleMask]); }

HB_FUNC(BRWSETBKCOLOR) {
  [(Wbrowse *)hb_parnll(1) setBackgroundColor:(NSColor *)hb_parnll(2)];
}

HB_FUNC(BRWSETTEXTCOLOR) {
  Wbrowse *browse = (Wbrowse *)hb_parnll(1);
  for (NSTableColumn *col in [browse tableColumns])
    [[col dataCell] setTextColor:(NSColor *)hb_parnll(2)];
}

HB_FUNC(BRWSETFONT) {
  Wbrowse *browse = (Wbrowse *)hb_parnll(1);
  NSFont *font = [NSFont fontWithName:hb_NSSTRING_par(2) size:hb_parnl(3)];
  for (NSTableColumn *col in [browse tableColumns])
    [[col dataCell] setFont:font];
}

HB_FUNC(BRWSETROWHEIGHT) { [(Wbrowse *)hb_parnll(1) setRowHeight:hb_parnd(2)]; }

HB_FUNC(BRWGETROWHEIGHT) { hb_retnd([(Wbrowse *)hb_parnll(1) rowHeight]); }

HB_FUNC(BRWSETCOLWIDTH) {
  Wbrowse *browse = (Wbrowse *)hb_parnll(1);
  NSTableColumn *column = [[browse tableColumns] objectAtIndex:hb_parnl(2) - 1];
  [column setWidth:hb_parnd(3)];
}

HB_FUNC(BRWGETCOLWIDTH) {
  hb_retnd([[[(Wbrowse *)hb_parnll(1) tableColumns]
      objectAtIndex:hb_parnl(2) - 1] width]);
}

HB_FUNC(BRWSETCOLEDITABLE) {
  Wbrowse *browse = (Wbrowse *)hb_parnll(1);
  NSTableColumn *column = [[browse tableColumns] objectAtIndex:hb_parnl(2) - 1];
  [column setEditable:hb_parl(3)];
}

HB_FUNC(BRWSETDBLACTION) {
  [(Wbrowse *)hb_parnll(1) setDoubleAction:@selector(BrwDblClick:)];
}

HB_FUNC(BRWCLRDBLACTION) { [(Wbrowse *)hb_parnll(1) setDoubleAction:nil]; }

HB_FUNC(BRWCOLPOS) { hb_retnl([(Wbrowse *)hb_parnll(1) clickedColumn] + 1); }

HB_FUNC(BRWSETCOLORSFORALTERNATE) {
  [(Wbrowse *)hb_parnll(1) setUsesAlternatingRowBackgroundColors:hb_parl(2)];
}

HB_FUNC(BRWSETALTCOLOR) {}

HB_FUNC(BRWSCROLLSTYLE) {
  Wbrowse *browse = (Wbrowse *)hb_parnll(1);
  NSScrollView *sv = [browse enclosingScrollView];
  if ([sv respondsToSelector:@selector(setScrollerStyle:)])
    [sv setScrollerStyle:hb_parnl(2)];
}

HB_FUNC(BRWSCROLLVSHOW) {
  [[(Wbrowse *)hb_parnll(1) enclosingScrollView]
      setHasVerticalScroller:hb_parl(2)];
}

HB_FUNC(BRWSCROLLHSHOW) {
  [[(Wbrowse *)hb_parnll(1) enclosingScrollView]
      setHasHorizontalScroller:hb_parl(2)];
}

HB_FUNC(BRWSCROLLAUTOHIDE) {
  [[(Wbrowse *)hb_parnll(1) enclosingScrollView]
      setAutohidesScrollers:hb_parl(2)];
}

HB_FUNC(BRWEDIT) {
  [(Wbrowse *)hb_parnll(1) editColumn:hb_parnl(2) - 1
                                  row:hb_parnl(3) - 1
                            withEvent:nil
                               select:YES];
}

HB_FUNC(BRWSETNOHEAD) {
  if (hb_parl(2))
    [(Wbrowse *)hb_parnll(1) setHeaderView:nil];
}

HB_FUNC(BRWSETHEADHEIGHT) {}

HB_FUNC(BRWAUTOAJUST) { [(Wbrowse *)hb_parnll(1) sizeToFit]; }

HB_FUNC(BRWSETSYSTEMFONT) {
  Wbrowse *browse = (Wbrowse *)hb_parnll(1);
  for (NSTableColumn *col in [browse tableColumns])
    [[col dataCell] setFont:[NSFont systemFontOfSize:hb_parnl(2)]];
}

HB_FUNC(BRWSETMENUFONT) {
  Wbrowse *browse = (Wbrowse *)hb_parnll(1);
  for (NSTableColumn *col in [browse tableColumns])
    [[col dataCell] setFont:[NSFont menuFontOfSize:hb_parnl(2)]];
}

HB_FUNC(BRWSETHEADTOOLTIP) {}

HB_FUNC(BRWSETINDICATORASCEND) {
  Wbrowse *browse = (Wbrowse *)hb_parnll(1);
  [browse
      setIndicatorImage:[NSImage imageNamed:@"NSAscendingSortIndicator"]
          inTableColumn:[[browse tableColumns] objectAtIndex:hb_parnl(2) - 1]];
}

HB_FUNC(BRWSETINDICATORDESCENT) {
  Wbrowse *browse = (Wbrowse *)hb_parnll(1);
  [browse
      setIndicatorImage:[NSImage imageNamed:@"NSDescendingSortIndicator"]
          inTableColumn:[[browse tableColumns] objectAtIndex:hb_parnl(2) - 1]];
}

HB_FUNC(BRWSETNOINDICATOR) {
  Wbrowse *browse = (Wbrowse *)hb_parnll(1);
  [browse
      setIndicatorImage:nil
          inTableColumn:[[browse tableColumns] objectAtIndex:hb_parnl(2) - 1]];
}

HB_FUNC(BRWSSETCROLLVGRAFITE) {}
HB_FUNC(BRWSSETCROLLHGRAFITE) {}

HB_FUNC(BRWSETSELECTORSTYLE) {
  Wbrowse *browse = (Wbrowse *)hb_parnll(1);
  if ([browse respondsToSelector:@selector(setSelectionHighlightStyle:)]) {
    [browse setSelectionHighlightStyle:hb_parnl(2)];
  }
}
