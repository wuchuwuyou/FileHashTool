//
//  FileWindowController.m
//  FileHash
//
//  Created by Murphy on 08/02/2018.
//  Copyright © 2018 Murphy. All rights reserved.
//

#import "FileWindowController.h"
#import "FileCollectionViewItem.h"
#import "FileModel.h"

@interface FileWindowController () <NSCollectionViewDelegate,NSCollectionViewDataSource>

@property (weak) IBOutlet NSCollectionView *collectionView;

@property (nonatomic,strong) NSArray <FileModel *>*dataArray;
@end

@implementation FileWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [self initViews];
}

- (instancetype)initWithWindowNibName:(NSNibName)windowNibName {
    self = [super initWithWindowNibName:windowNibName];
    if(self) {
        
    }
    return self;
}
- (void)awakeFromNib {
    [self initViews];
}

- (void)initViews {
    [self.collectionView registerForDraggedTypes:@[NSPasteboardTypeFileURL]];
    [self.collectionView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:YES];
    [self.collectionView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:NO];
    
    [self.collectionView registerNib:[[NSNib alloc] initWithNibNamed:@"FileCollectionViewItem" bundle:nil] forItemWithIdentifier:@"FileCollectionViewItem"];
    self.dataArray = @[];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    NSCollectionViewFlowLayout *layout = [[NSCollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(160.0, 80.0);
    layout.sectionInset = NSEdgeInsetsMake(10, 10, 10, 10);
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    self.collectionView.collectionViewLayout = layout;
    
    FileModel *model1 = [[FileModel alloc] init];
    FileModel *model2 = [[FileModel alloc] init];
    FileModel *model3 = [[FileModel alloc] init];
    self.dataArray = @[model1,model2,model3];
    [self.collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
    FileCollectionViewItem *item =  [collectionView makeItemWithIdentifier:@"FileCollectionViewItem" forIndexPath:indexPath];
    FileModel *model = self.dataArray[indexPath.item];
    [item configWithModel:model];
    return item;
}

- (BOOL)collectionView:(NSCollectionView *)collectionView canDragItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths withEvent:(NSEvent *)event {
    return YES;
}

//- (id<NSPasteboardWriting>)collectionView:(NSCollectionView *)collectionView pasteboardWriterForItemAtIndex:(NSUInteger)index {
//    
//}
- (BOOL)collectionView:(NSCollectionView *)collectionView acceptDrop:(id<NSDraggingInfo>)draggingInfo indexPath:(NSIndexPath *)indexPath dropOperation:(NSCollectionViewDropOperation)dropOperation {
    return YES;
}

- (NSDragOperation)collectionView:(NSCollectionView *)collectionView validateDrop:(id<NSDraggingInfo>)draggingInfo proposedIndexPath:(NSIndexPath *__autoreleasing  _Nonnull *)proposedDropIndexPath dropOperation:(NSCollectionViewDropOperation *)proposedDropOperation {
    return NSDragOperationEvery;
}

@end
