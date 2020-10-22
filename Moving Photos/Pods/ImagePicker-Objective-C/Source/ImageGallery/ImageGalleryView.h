//
//  ImageGalleryView.h
//  ImagePickerDemo
//
//  Created by hanxt on 16/9/21.
//  Copyright © 2016年 hanxt. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ImageStack;
@class ImageGalleryLayout;

UIKIT_EXTERN CGFloat const kGalleryBarHeight;
UIKIT_EXTERN CGFloat const kGalleryHeight;

@protocol ImageGalleryViewDelegate <NSObject>

- (void)panGestureDidStart;

- (void)panGestureDidChangeWithTranslation:(CGPoint)translation;

- (void)panGestureDidEndWithTranslation:(CGPoint)translation
                               velocity:(CGPoint)velocity;

@end

@interface ImageGalleryView : UIView

@property (nonatomic, weak) id<ImageGalleryViewDelegate> delegate;

@property (nonatomic, strong) ImageGalleryLayout *collectionViewLayout;

@property (nonatomic, strong) ImageStack *selectedStack;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, assign) NSInteger imageLimit;

@property (nonatomic, assign) BOOL canFetchImages;

@property (nonatomic, strong) UIView *topSeparator;

@property (nonatomic, assign) CGSize collectionSize;

@property (nonatomic, strong) NSMutableArray *assets;

@property (nonatomic, assign) BOOL shouldTransform;

- (void)updateFrames;

- (void)fetchPhotos:(void (^)(void))completion;

- (void)updateNoImagesLabel;

@end
