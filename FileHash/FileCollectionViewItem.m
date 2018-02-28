//
//  FileCollectionViewItem.m
//  FileHash
//
//  Created by Murphy on 08/02/2018.
//  Copyright © 2018 Murphy. All rights reserved.
//

#import "FileCollectionViewItem.h"

@interface FileCollectionViewItem ()

@property (weak) IBOutlet NSTextField *filePathLabel;
@property (weak) IBOutlet NSTextField *fileMD5Label;
@property (weak) IBOutlet NSTextField *fileSizeLabel;

@end

@implementation FileCollectionViewItem

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}
- (void)awakeFromNib {
    [super awakeFromNib];
}
- (void)viewDidAppear {
    [super viewDidAppear];
}

- (void)configWithModel:(FileModel *)model {
    if (!model.isFinish) {
        
    }
    self.filePathLabel.stringValue = model.filePath;
    self.fileMD5Label.stringValue = model.fileHash?model.fileHash:@"";
    self.fileSizeLabel.stringValue = model.fileSize;
}
@end
