//
//  ImageStack.m
//  ImagePickerDemo
//
//  Created by hanxt on 16/9/21.
//  Copyright © 2016年 hanxt. All rights reserved.
//

#import "ImageStack.h"

static NSString *const kImageKey = @"image";
NSString *const kNotificationImageDidPush = @"imageDidPush";
NSString *const kNotificationImageDidDrop = @"imageDidDrop";
NSString *const kNotificationStackDidReload = @"stackDidReload";

@implementation ImageStack

- (void)pushAsset:(PHAsset *)asset {
    [self.assets addObject:asset];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationImageDidPush object:self userInfo:@{kImageKey : asset}];
}

- (void)dropAsset:(PHAsset *)asset {
    [self.assets removeObject:asset];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationImageDidDrop object:self userInfo:@{kImageKey : asset}];
}

- (void)resetAssets:(NSArray<PHAsset *> *)assets {
    self.assets = [assets mutableCopy];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationStackDidReload object:self userInfo:nil];
}

- (BOOL)containsAsset:(PHAsset *)asset {
    return [self.assets containsObject:asset];
}

- (NSMutableArray *)assets {
    if (!_assets) {
        _assets = [NSMutableArray array];
    }
    return _assets;
}

@end
