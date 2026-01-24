#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#include <fivemac.h>

NSView *GetView(NSWindow *window);

//==================================================================================
// CELL ITEM
//==================================================================================

@interface CVImageItem : NSCollectionViewItem
@end

@implementation CVImageItem

- (void)loadView {
  self.view = [[[NSView alloc] initWithFrame:NSZeroRect] autorelease];
  self.view.wantsLayer = YES;

  NSImageView *iv = [[[NSImageView alloc] init] autorelease];
  iv.imageScaling = NSImageScaleProportionallyUpOrDown;
  iv.translatesAutoresizingMaskIntoConstraints = NO;
  [iv unregisterDraggedTypes];
  [iv setEditable:NO];

  [self.view addSubview:iv];
  self.imageView = iv;

  [NSLayoutConstraint activateConstraints:@[
    [iv.topAnchor constraintEqualToAnchor:self.view.topAnchor],
    [iv.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    [iv.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
    [iv.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor]
  ]];

  // Optional: Add Label overlay
  NSTextField *lbl = [[[NSTextField alloc] init] autorelease];
  lbl.translatesAutoresizingMaskIntoConstraints = NO;
  lbl.drawsBackground = NO;
  lbl.bezeled = NO;
  lbl.editable = NO;
  lbl.selectable = NO;
  lbl.alignment = NSTextAlignmentCenter;
  lbl.textColor = [NSColor whiteColor];
  lbl.font = [NSFont systemFontOfSize:11];

  // Shadow for text visibility
  NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
  shadow.shadowOffset = NSMakeSize(1, -1);
  shadow.shadowColor = [NSColor blackColor];
  shadow.shadowBlurRadius = 2.0;
  lbl.shadow = shadow;

  [self.view addSubview:lbl];
  self.textField = lbl;

  [NSLayoutConstraint activateConstraints:@[
    [lbl.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor
                                     constant:-5],
    [lbl.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
    [lbl.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor]
  ]];

  // Double Click Gesture on Item
  NSClickGestureRecognizer *dbl = [[NSClickGestureRecognizer alloc]
      initWithTarget:self
              action:@selector(handleItemDoubleClick:)];
  dbl.numberOfClicksRequired = 2;
  dbl.delaysPrimaryMouseButtonEvents = NO;
  [self.view addGestureRecognizer:dbl];
  [dbl release];
}

- (void)handleItemDoubleClick:(NSClickGestureRecognizer *)gesture {
  if (gesture.state == NSGestureRecognizerStateEnded) {
    // Pulse Animation
    self.imageView.wantsLayer = YES;
    [NSAnimationContext
        runAnimationGroup:^(NSAnimationContext *context) {
          context.duration = 0.1;
          context.timingFunction = [CAMediaTimingFunction
              functionWithName:kCAMediaTimingFunctionEaseOut];
          [[self.imageView layer]
              setTransform:CATransform3DMakeScale(1.1, 1.1, 1.0)];
        }
        completionHandler:^{
          [NSAnimationContext
              runAnimationGroup:^(NSAnimationContext *context) {
                context.duration = 0.1;
                context.timingFunction = [CAMediaTimingFunction
                    functionWithName:kCAMediaTimingFunctionEaseIn];
                [[self.imageView layer] setTransform:CATransform3DIdentity];
              }
              completionHandler:nil];
        }];

    if ([[self.collectionView delegate]
            respondsToSelector:@selector(handleDoubleClickForItem:)]) {
      NSIndexPath *indexPath = [self.collectionView indexPathForItem:self];
      if (indexPath) {
        [[self.collectionView delegate]
            performSelector:@selector(handleDoubleClickForItem:)
                 withObject:[NSNumber numberWithInteger:(indexPath.item + 1)]];
      }
    }
  }
}

- (void)setSelected:(BOOL)selected {
  [super setSelected:selected];

  // Selection Animation (Scale)
  self.imageView.wantsLayer = YES;
  [NSAnimationContext
      runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.2;
        context.timingFunction = [CAMediaTimingFunction
            functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        if (selected) {
          [[self.imageView layer]
              setTransform:CATransform3DMakeScale(1.05, 1.05, 1.0)];
          self.view.layer.backgroundColor =
              [[NSColor selectedControlColor] CGColor];
          self.view.layer.cornerRadius = 8.0;
          self.view.layer.borderWidth = 3.0;
          self.view.layer.borderColor = [[NSColor whiteColor] CGColor];
          self.view.layer.shadowOpacity = 0.5;
          self.view.layer.shadowRadius = 4.0;
        } else {
          [[self.imageView layer] setTransform:CATransform3DIdentity];
          self.view.layer.backgroundColor = [[NSColor clearColor] CGColor];
          self.view.layer.borderWidth = 0.0;
          self.view.layer.shadowOpacity = 0.0;
        }
      }
      completionHandler:nil];
}
@end

//==================================================================================
// BROWSER VIEW (CONTROLLER + VIEW)
//==================================================================================

@interface CVBrowserView : NSView <NSCollectionViewDelegate>
@property(strong) NSScrollView *scrollView;
@property(strong) NSCollectionView *collectionView;
@property(strong)
    NSCollectionViewDiffableDataSource<NSString *, NSString *> *dataSource;
@property(strong) NSMutableArray<NSString *> *imagePaths;
@property(assign) CGFloat zoomLevel;
@end

static PHB_SYMB symFMH = NULL;

@interface CVCollectionView : NSCollectionView
@end

@implementation CVCollectionView
- (BOOL)isFlipped {
  return YES;
}
@end

@implementation CVBrowserView

- (instancetype)initWithFrame:(NSRect)frameRect {
  self = [super initWithFrame:frameRect];
  if (self) {
    _imagePaths = [[NSMutableArray alloc] init];
    _zoomLevel = 1.0;
    [self setupUI];
  }
  return self;
}

- (BOOL)isFlipped {
  return YES;
}

- (void)dealloc {
  [_scrollView release];
  [_collectionView release];
  [_dataSource release];
  [_imagePaths release];
  [super dealloc];
}

- (void)setupUI {
  self.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;

  // ScrollView
  _scrollView = [[NSScrollView alloc] initWithFrame:self.bounds];
  _scrollView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
  _scrollView.hasVerticalScroller = YES;
  _scrollView.borderType = NSBezelBorder;
  [self addSubview:_scrollView];

  // CollectionView
  _collectionView = [[CVCollectionView alloc] initWithFrame:self.bounds];
  _collectionView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
  _collectionView.backgroundColors = @[ [NSColor controlBackgroundColor] ];
  _collectionView.wantsLayer = YES;
  _collectionView.selectable = YES;
  _collectionView.allowsMultipleSelection = NO;
  _collectionView.delegate = self;

  _scrollView.documentView = _collectionView;

  // Layout
  [self updateLayout];

  // Component Registration
  [_collectionView registerClass:[CVImageItem class]
           forItemWithIdentifier:@"CVImageItem"];

  // DataSource
  // DataSource
  // DataSource
  [self configureDataSource];
}

- (void)handleDoubleClickForItem:(NSNumber *)indexObj {
  NSInteger idx = [indexObj integerValue];

  if (symFMH == NULL)
    symFMH = hb_dynsymSymbol(hb_dynsymFindName("_FMH"));

  hb_vmPushSymbol(symFMH);
  hb_vmPushNil();
  hb_vmPushNumInt((HB_LONGLONG)[self window]);
  hb_vmPushLong(WM_CVDBLCLICK);
  hb_vmPushNumInt((HB_LONGLONG)self);
  hb_vmPushLong(idx);
  hb_vmDo(4);
}

- (void)updateLayout {
  NSCollectionViewFlowLayout *layout =
      [[[NSCollectionViewFlowLayout alloc] init] autorelease];
  CGFloat size = 140.0 * _zoomLevel;
  layout.itemSize = NSMakeSize(size, size);
  layout.sectionInset = NSEdgeInsetsMake(10, 10, 10, 10);
  layout.minimumInteritemSpacing = 10;
  layout.minimumLineSpacing = 10;

  // Preserve selection or offset if possible?
  _collectionView.collectionViewLayout = layout;
}

- (void)configureDataSource {

  self.dataSource = [[NSCollectionViewDiffableDataSource alloc]
      initWithCollectionView:self.collectionView
                itemProvider:^NSCollectionViewItem *_Nullable(
                    NSCollectionView *cv, NSIndexPath *idx, NSString *path) {
                  CVImageItem *item = [cv makeItemWithIdentifier:@"CVImageItem"
                                                    forIndexPath:idx];

                  // Setup Item
                  item.textField.stringValue = [path lastPathComponent];

                  // Lazy Load Image
                  // Ideally should be async, but for now let's use standard
                  // NSImage loading or system icon if fast To prevent blocking,
                  // we can use a placeholder and load in background? For
                  // simplicity and stability based on user test, we use
                  // imageNamed or alloc/init

                  NSImage *img = nil;
                  if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                    // initByReferencingFile is lazy
                    img = [[[NSImage alloc] initByReferencingFile:path]
                        autorelease];
                  } else {
                    img = [NSImage imageNamed:NSImageNameCaution];
                  }
                  item.imageView.image = img;

                  return item;
                }];
}

- (void)applySnapshot {
  NSDiffableDataSourceSnapshot<NSString *, NSString *> *snapshot =
      [[[NSDiffableDataSourceSnapshot alloc] init] autorelease];
  [snapshot appendSectionsWithIdentifiers:@[ @"Main" ]];

  if (_imagePaths.count > 0) {
    [snapshot appendItemsWithIdentifiers:_imagePaths
               intoSectionWithIdentifier:@"Main"];
  }

  [self.dataSource applySnapshot:snapshot
            animatingDifferences:NO]; // Disable animation for bulk loads for
                                      // performance
}

//--- Public Actions ---

- (void)addPath:(NSString *)path {
  if (path && ![_imagePaths containsObject:path]) {
    [_imagePaths addObject:path];
  }
}

- (void)addDirectory:(NSString *)dir {
  NSFileManager *fm = [NSFileManager defaultManager];
  BOOL isDir = NO;
  if ([fm fileExistsAtPath:dir isDirectory:&isDir] && isDir) {
    NSArray *contents = [fm contentsOfDirectoryAtPath:dir error:nil];
    for (NSString *file in contents) {
      if (![file hasPrefix:@"."]) {
        NSString *fullPath = [dir stringByAppendingPathComponent:file];
        [self addPath:fullPath];
      }
    }
  }
}

- (void)refreshData {
  // Ensure on Main Thread
  if ([NSThread isMainThread]) {
    [self applySnapshot];
  } else {
    [self performSelectorOnMainThread:@selector(applySnapshot)
                           withObject:nil
                        waitUntilDone:NO];
  }
}

- (void)setZoom:(CGFloat)zoom {
  _zoomLevel = zoom;
  if (_zoomLevel < 0.2)
    _zoomLevel = 0.2;
  [self updateLayout];
}

// Delegate Methods for Selection
- (void)collectionView:(NSCollectionView *)collectionView
    didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths {
  [self notifySelectionChange];
}

- (void)collectionView:(NSCollectionView *)collectionView
    didDeselectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths {
  [self notifySelectionChange];
}

- (void)notifySelectionChange {
  if (symFMH == NULL)
    symFMH = hb_dynsymSymbol(hb_dynsymFindName("_FMH"));

  NSSet *selection = [self.collectionView selectionIndexPaths];
  NSInteger firstIndex = 0; // 0 for Harbour = no selection? Or -1?
  // TWBrowse uses 0-based index for Harbour? No, Harbour is 1-based usually.
  // TWBrowse source: matches Row index.

  if ([selection count] > 0) {
    NSIndexPath *ip = [selection anyObject];
    firstIndex = [ip item] + 1; // 1-based for Harbour
  }

  hb_vmPushSymbol(symFMH);
  hb_vmPushNil();
  hb_vmPushNumInt((HB_LONG)[self window]);
  hb_vmPushLong(WM_BRWCHANGED);
  hb_vmPushNumInt((HB_LONG)self);
  hb_vmPushLong(firstIndex);
  hb_vmDo(4);
}

- (void)handleDoubleClickItem:(NSNumber *)nIndex {
  if (symFMH == NULL)
    symFMH = hb_dynsymSymbol(hb_dynsymFindName("_FMH"));

  NSInteger idx = [nIndex integerValue];

  hb_vmPushSymbol(symFMH);
  hb_vmPushNil();
  hb_vmPushNumInt((HB_LONG)[self window]);
  hb_vmPushLong(WM_BRWDBLCLICK);
  hb_vmPushNumInt((HB_LONG)self);
  hb_vmPushLong(idx);
  hb_vmDo(4);
}

@end

//==================================================================================
// HARBOUR BINDINGS
//==================================================================================

static NSArray *SimOpenFiles() {
  NSOpenPanel *panel = [NSOpenPanel openPanel];
  panel.canChooseDirectories = YES;
  panel.canChooseFiles = YES;
  panel.allowsMultipleSelection = YES;
  if ([panel runModal] == NSModalResponseOK) {
    return [panel URLs];
  }
  return nil;
}

HB_FUNC(IKIMGBRCREATE) {
  long top = hb_parnl(1);
  long left = hb_parnl(2);
  long w = hb_parnl(3);
  long h = hb_parnl(4);
  NSWindow *win = (NSWindow *)hb_parnl(5);

  // Create Container View
  CVBrowserView *browser =
      [[CVBrowserView alloc] initWithFrame:NSMakeRect(left, top, w, h)];

  // Add to Window
  NSView *parent = GetView(win);
  [parent addSubview:browser];

  // Return handle (retained by view hierarchy, but we might want to autorelease
  // if it was alloc'ed?) Views in Cocoa are retained by superview. `alloc`
  // gives +1. `addSubview` gives +1. If we don't autorelease, we have a memory
  // leak (+1 count hanging). Usually we autorelease views after adding them if
  // we don't keep ivar.
  [browser autorelease];

  hb_retnll((HB_LONGLONG)browser);
}

HB_FUNC(IKIMGBROPENPANEL) {
  CVBrowserView *browser = (CVBrowserView *)hb_parnl(1);
  NSArray *urls = SimOpenFiles();
  if (urls) {
    for (NSURL *url in urls) {
      [browser addDirectory:[url path]];
    }
    [browser refreshData];
  }
}

HB_FUNC(IKIMGBROPENDIR) {
  CVBrowserView *browser = (CVBrowserView *)hb_parnl(1);
  NSString *path = hb_NSSTRING_par(2);
  [browser addDirectory:path];
  [browser refreshData];
}

HB_FUNC(IKIMGBROPENFILE) {
  CVBrowserView *browser = (CVBrowserView *)hb_parnl(1);
  NSString *path = hb_NSSTRING_par(2);
  [browser addPath:path];
  [browser refreshData];
}

HB_FUNC(IKIMGBRSETZOOM) {
  CVBrowserView *browser = (CVBrowserView *)hb_parnl(1);
  CGFloat zoom = (CGFloat)hb_parnl(2) / 100.0;
  [browser setZoom:zoom];
}

HB_FUNC(IKIMGBRGETZOOM) {
  CVBrowserView *browser = (CVBrowserView *)hb_parnl(1);
  long val = (long)([browser zoomLevel] * 100);
  hb_retnl(val);
}

// Stubs
HB_FUNC(IKIMGBROANIMATE) {}
HB_FUNC(IKIMGBROSTYLE) {}
HB_FUNC(IKIMGBROFILTRO) {}
HB_FUNC(IKIMGBROFILTER) {}
HB_FUNC(IKIMGRUNSLIDE) {}
HB_FUNC(IKIMGSTOPSLIDE) {}
