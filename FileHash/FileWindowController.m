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
#import "FileHash.h"

@interface FileWindowController () <NSCollectionViewDelegate,NSCollectionViewDataSource>

@property (weak) IBOutlet NSCollectionView *collectionView;

@property (nonatomic,strong) NSMutableArray <FileModel *>*dataArray;
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
    [super awakeFromNib];
    [self initViews];
}
- (void)initViews {
    [self.collectionView registerForDraggedTypes:@[NSPasteboardTypeFileURL]];
    [self.collectionView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:YES];
    [self.collectionView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:NO];
    
    [self.collectionView registerNib:[[NSNib alloc] initWithNibNamed:@"FileCollectionViewItem" bundle:nil] forItemWithIdentifier:@"FileCollectionViewItem"];

    self.dataArray = [NSMutableArray array];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    NSCollectionViewFlowLayout *layout = [[NSCollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(450.0, 81.0);
    layout.sectionInset = NSEdgeInsetsMake(10, 10, 10, 10);
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    self.collectionView.collectionViewLayout = layout;
    
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
    if(!item) {
        item = [[FileCollectionViewItem alloc] initWithNibName:@"FileCollectionViewItem" bundle:nil];
    }
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
    [self handleDragInfo:draggingInfo];
    return YES;
}

- (NSDragOperation)collectionView:(NSCollectionView *)collectionView validateDrop:(id<NSDraggingInfo>)draggingInfo proposedIndexPath:(NSIndexPath *__autoreleasing  _Nonnull *)proposedDropIndexPath dropOperation:(NSCollectionViewDropOperation *)proposedDropOperation {
    return NSDragOperationEvery;
}

- (void)handleDragInfo:(id<NSDraggingInfo>)draggingInfo{
    NSPasteboard* pb = draggingInfo.draggingPasteboard;
    NSMutableArray *uploadUrls = [[NSMutableArray alloc] initWithCapacity:0];
    NSArray *urlItems = [pb pasteboardItems];
    for (NSPasteboardItem *item in urlItems)
    {
        NSArray *array = [item types];
        NSString *string = [item stringForType:[array lastObject]];
        NSURL *urlString = [NSURL URLWithString:string];
        if (urlString)
        {
            [uploadUrls addObject:urlString];
        }
    }
    NSArray *urlStringArray = [NSArray array];
    if (uploadUrls.count > 0)
    {
        NSMutableArray *uploadUrlArr = [NSMutableArray array];
        for (NSURL *url in uploadUrls) {
            if (![url isKindOfClass:[NSURL class]]) {
                return;
            }
            [uploadUrlArr addObject:url.path];
        }
        if (uploadUrlArr.count == 0) {
            return;
        }
        urlStringArray = [NSArray arrayWithArray:uploadUrlArr];
    }
    [self handleUrlString:urlStringArray];
}
- (void)handleUrlString:(NSArray *)array {
    if (array.count == 0) {
        return;
    }
    NSFileManager *manager = [NSFileManager defaultManager];
    for (NSString *url in array) {
        NSError *error = nil;
        NSDictionary *att = [manager attributesOfItemAtPath:url error:&error];
        if (error || att == nil) {
            NSLog(@"%@",error);
            return;
        }
        NSString *fileSize = att[NSFileSize];
        NSString *name = [[NSURL URLWithString:url] lastPathComponent];
        FileModel *model = [[FileModel alloc] init];
        model.filePath = url;
        model.fileName = name;
        model.fileSize = fileSize;
        model.fileHash = [FileHash getFileMD5WithPath:url];
        model.isFinish = YES;
        [self.dataArray addObject:model];
    }
    [self.collectionView reloadData];
}
@end
