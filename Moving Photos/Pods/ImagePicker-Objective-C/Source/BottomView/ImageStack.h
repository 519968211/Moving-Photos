//
//  ImageStack.h
//  ImagePickerDemo
//
//  Created by hanxt on 16/9/21.
//  Copyright © 2016年 hanxt. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PHAsset;

UIKIT_EXTERN NSString *const kNotificationImageDidPush;
UIKIT_EXTERN NSString *const kNotificationImageDidDrop;
UIKIT_EXTERN NSString *const kNotificationStackDidReload;

@interface ImageStack : NSObject

@property (nonatomic, strong) NSMutableArray<PHAsset *> *assets;

- (void)pushAsset:(PHAsset *)asset;
- (void)dropAsset:(PHAsset *)asset;
- (void)resetAssets:(NSArray<PHAsset *> *)assets;
- (BOOL)containsAsset:(PHAsset *)asset;

@end
