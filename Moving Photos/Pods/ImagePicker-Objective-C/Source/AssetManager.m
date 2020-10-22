//
//  AssetManager.m
//  ImagePickerDemo
//
//  Created by hanxt on 16/9/21.
//  Copyright © 2016年 hanxt. All rights reserved.
//

#import "AssetManager.h"
#import <Photos/Photos.h>

@implementation AssetManager

+ (UIImage *)getImage:(NSString *)name {
    UITraitCollection *traitCollection = [UITraitCollection traitCollectionWithDisplayScale:3];
    NSBundle *bundle = [NSBundle bundleForClass:[AssetManager class]];
    NSString *bundlePath = [[bundle resourcePath] stringByAppendingString:@"/ImagePicker.bundle"];
    if (bundlePath) {
        bundle = [NSBundle bundleWithPath:bundlePath];
    }
    
    return [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:traitCollection];
}

+ (void)fetchWithCompletion:(void (^)(NSArray<PHAsset *> *assets))completion {
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    PHAuthorizationStatus authorizationStatus = [PHPhotoLibrary authorizationStatus];
    PHFetchResult *fetchResult = nil;
    
    if (authorizationStatus != PHAuthorizationStatusAuthorized) {
        return;
    }
    
    if (!fetchResult) {
        fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
    }
    
    if (fetchResult.count > 0) {
        NSMutableArray *assets = [NSMutableArray array];
        [fetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            PHAsset *asset = (PHAsset *)obj;
            if (asset) {
                [assets insertObject:asset atIndex:0];
            }
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(assets);
        });
    }
}

+ (void)resolveAsset:(PHAsset *)asset size:(CGSize)size completion:(void (^)(UIImage *image))completion {
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        size = CGSizeMake(720, 1280);
    }
    PHImageManager *imageManager = [PHImageManager defaultManager];
    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    
    [imageManager requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        NSObject *obj = info[@"PHImageFileUTIKey"];
        if (!obj) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(result);
                }
            });
        }
    }];
}

+ (NSArray<UIImage *> *)resolveAssets:(NSArray<PHAsset *> *)assets size:(CGSize)size {
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        size = CGSizeMake(720, 1280);
    }
    PHImageManager *imageManager = [PHImageManager defaultManager];
    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.synchronous = YES;
    
    NSMutableArray *images = [NSMutableArray array];
    for (PHAsset *asset in assets) {
        [imageManager requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if (result) {
                [images addObject:result];
            }
        }];
    }
    
    return [images copy];
}

@end
