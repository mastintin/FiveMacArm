#import <Cocoa/Cocoa.h>
#include <fivemac.h>

//==================================================================================
// USER PROVIDED CODE PART 1: ImageItem
//==================================================================================

@interface ImageItem : NSCollectionViewItem
@end

@implementation ImageItem
- (void)loadView {
  self.view = [[[NSView alloc] initWithFrame:NSZeroRect]
      autorelease]; // Added autorelease for safety in MRC
  NSImageView *iv = [[[NSImageView alloc] init] autorelease];
  iv.imageScaling = NSImageScaleProportionallyUpOrDown;
  iv.translatesAutoresizingMaskIntoConstraints = NO;

  [self.view addSubview:iv];
  self.imageView = iv;

  [NSLayoutConstraint activateConstraints:@[
    [iv.topAnchor constraintEqualToAnchor:self.view.topAnchor],
    [iv.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    [iv.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
    [iv.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor]
  ]];

  // Debug: Add a background color to verify visibility
  self.view.wantsLayer = YES;
  self.view.layer.backgroundColor = [[NSColor greenColor] CGColor];
}
@end

//==================================================================================
// USER PROVIDED CODE PART 2: ViewController (Adapted)
//==================================================================================

@interface TestViewController : NSViewController
@property (strong) NSCollectionView *collectionView;
@property (strong) NSCollectionViewDiffableDataSource<NSString *, NSImage *> *dataSource;
@end

@implementation TestViewController

- (void)loadView {
    // Create ScrollView and CollectionView programmatically
    NSScrollView *scrollView = [[[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, 400, 300)] autorelease];
    scrollView.hasVerticalScroller = YES;
    
    // Modern NSCollectionView
    NSCollectionView *cv = [[[NSCollectionView alloc] initWithFrame:NSZeroRect] autorelease];
    cv.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    scrollView.documentView = cv;
    
    self.collectionView = cv;
    self.view = scrollView; 
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureLayout];
    [self configureDataSource];
    [self applySnapshot];
}

- (void)configureLayout {
    NSCollectionViewFlowLayout *layout = [[[NSCollectionViewFlowLayout alloc] init] autorelease];
    layout.itemSize = NSMakeSize(150, 150);
    layout.sectionInset = NSEdgeInsetsMake(10, 10, 10, 10);
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = 10;
    self.collectionView.collectionViewLayout = layout;
}

- (void)configureDataSource {
    // Registrar la clase
    NSUserInterfaceItemIdentifier itemID = @"ImageItem";
    [self.collectionView registerClass:[ImageItem class] forItemWithIdentifier:itemID];

    // Configurar el Data Source
    // Note: ensure we autorelease/retain correctly. DiffableDataSource retains its itemProvider.
    self.dataSource = [[[NSCollectionViewDiffableDataSource alloc] initWithCollectionView:self.collectionView 
        itemProvider:^NSCollectionViewItem * _Nullable(NSCollectionView *cv, NSIndexPath *idx, NSImage *image) {
        
        ImageItem *item = [cv makeItemWithIdentifier:itemID forIndexPath:idx];
        item.imageView.image = image;
        return item;
    }] autorelease];
}

- (void)applySnapshot {
    NSDiffableDataSourceSnapshot<NSString *, NSImage *> *snapshot = [[[NSDiffableDataSourceSnapshot alloc] init] autorelease];
    [snapshot appendSectionsWithIdentifiers:@[@"MainSection"]];
    
    // Usar imagenes compatibles con 10.15 (SF Symbols aka imageWithSystemSymbolName is 11.0+)
    NSImage *img1 = [NSImage imageNamed:NSImageNameUser];
    NSImage *img2 = [NSImage imageNamed:NSImageNameComputer];

    if (img1 && img2) {
        NSArray *images = @[ img1, img2 ];
        [snapshot appendItemsWithIdentifiers:images intoSectionWithIdentifier:@"MainSection"];
        [self.dataSource applySnapshot:snapshot animatingDifferences:YES];
    }
}

@end

//==================================================================================
// HARBOUR BINDING
//==================================================================================

NSView * GetView( NSWindow * window );

HB_FUNC( TESTBROWSER_CREATE )
{
    NSWindow *win = (NSWindow *)hb_parnl(1);
    
    // Create Controller
    TestViewController *vc = [[TestViewController alloc] init]; // Retain it? Memory leak if not stored!
    // We intentionally leak it here for the test duration, otherwise it deallocs immediately.
    
    // Add to Window
    NSView *parent = GetView(win);
    vc.view.frame = parent.bounds;
    vc.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [parent addSubview:vc.view];
}
