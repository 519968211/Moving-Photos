//
//  AssetManager.h
//  ImagePickerDemo
//
//  Created by hanxt on 16/9/21.
//  Copyright © 2016年 hanxt. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PHAsset;

@interface AssetManager : NSObject

+ (UIImage *)getImage:(NSString *)name;

+ (void)fetchWithCompletion:(void (^)(NSArray<PHAsset *> *assets))completion;

+ (void)resolveAsset:(PHAsset *)asset size:(CGSize)size completion:(void (^)(UIImage *image))completion;

+ (NSArray<UIImage *> *)resolveAssets:(NSArray<PHAsset *> *)assets size:(CGSize)size;
@end
