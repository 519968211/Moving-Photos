//
//  ImageGalleryView.m
//  ImagePickerDemo
//
//  Created by hanxt on 16/9/21.
//  Copyright © 2016年 hanxt. All rights reserved.
//

#import "ImageGalleryView.h"
#import "ImageGalleryLayout.h"
#import "Configuration.h"
#import "ImageStack.h"
#import <Photos/Photos.h>
#import "ImageGalleryViewCell.h"
#import "AssetManager.h"

CGFloat const kGalleryHeight = 160.f;
CGFloat const kGalleryBarHeight = 24.f;

static NSString *const kReusableIdentifier = @"imagesReusableIdentifier";

@interface ImageGalleryView() <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

@property (nonatomic, strong) UILabel *noImagesLabel;

@property (nonatomic, assign) NSInteger imagesBeforeLoading;

@property (nonatomic, strong) PHFetchResult *fetchResult;

@end

@implementation ImageGalleryView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.shouldTransform = NO;
    self.imagesBeforeLoading = 0;
    self.canFetchImages = NO;
    self.imageLimit = 0;
    
    self.backgroundColor = Config.mainColor;
    [self.collectionView registerClass:[ImageGalleryViewCell class] forCellWithReuseIdentifier:kReusableIdentifier];
    [self addSubview:self.collectionView];
    [self addSubview:self.topSeparator];
    [self.topSeparator addSubview:Config.indicatorView];
    
    [self fetchPhotos:nil];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateNoImagesLabel];
}

- (void)updateFrames {
    CGFloat totalWidth = [UIScreen mainScreen].bounds.size.width;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, totalWidth, self.frame.size.height);
    CGFloat collectionFrame = 0.f;
    if (self.frame.size.height == kGalleryBarHeight) {
        collectionFrame = 100 + kGalleryBarHeight;
    } else {
        collectionFrame = self.frame.size.height;
    }
    self.topSeparator.frame = CGRectMake(0, 0, totalWidth, kGalleryBarHeight);
    self.topSeparator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    Config.indicatorView.frame = CGRectMake((totalWidth - Config.indicatorWidth) / 2, (self.topSeparator.frame.size.height - Config.indicatorHeight) / 2, Config.indicatorWidth, Config.indicatorHeight);
    self.collectionView.frame = CGRectMake(0, self.topSeparator.frame.size.height, totalWidth, collectionFrame - self.topSeparator.frame.size.height);
    self.collectionSize = CGSizeMake(self.collectionView.frame.size.height, self.collectionView.frame.size.height);
    [self.collectionView reloadData];
}

- (void)updateNoImagesLabel {
    CGFloat height = self.bounds.size.height;
    CGFloat threshold = kGalleryBarHeight * 2;
    
    [UIView animateWithDuration:0.25 animations:^{
        if (threshold > height || self.collectionView.alpha != 0) {
            self.noImagesLabel.alpha = 0;
        } else {
            self.noImagesLabel.center = CGPointMake(self.bounds.size.width / 2 , height / 2);
            self.noImagesLabel.alpha = (height > threshold) ? 1 : (height - kGalleryHeight)/threshold;
        }
    }];
}

#pragma mark - Photos handler
- (void)fetchPhotos:(void (^)(void))completion {
    [AssetManager fetchWithCompletion:^(NSArray<PHAsset *> *assets) {
        [self.assets removeAllObjects];
        [self.assets addObjectsFromArray:assets];
        [self.collectionView reloadData];
        if (completion) {
            completion();
        }
    }];
}

- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)gesture {
    UIView *superView = self.superview;
    if (!superView) {
        return;
    }
    
    CGPoint translation = [gesture translationInView:superView];
    CGPoint velocity = [gesture velocityInView:superView];
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            if ([self.delegate respondsToSelector:@selector(panGestureDidStart)]) {
                [self.delegate panGestureDidStart];
            }
            break;
        case UIGestureRecognizerStateChanged:
            if ([self.delegate respondsToSelector:@selector(panGestureDidChangeWithTranslation:)]) {
                [self.delegate panGestureDidChangeWithTranslation:translation];
            }
            break;
        case UIGestureRecognizerStateEnded:
            if ([self.delegate respondsToSelector:@selector(panGestureDidEndWithTranslation:velocity:)]) {
                [self.delegate panGestureDidEndWithTranslation:translation velocity:velocity];
            }
            break;
        default:
            break;
    }
}

- (void)displayNoImagesMessage:(BOOL)hideCollectionView {
    self.collectionView.alpha = hideCollectionView ? 0 : 1;
    [self updateNoImagesLabel];
}

#pragma mark - CollectionViewFlowLayout delegate methods
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (CGSizeEqualToSize(self.collectionSize, CGSizeZero)) {
        return CGSizeZero;
    }
    return self.collectionSize;
}

#pragma mark - CollectionView delegate methods
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageGalleryViewCell *cell = (ImageGalleryViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (!cell) {
        return;
    }
    PHAsset *asset = self.assets[indexPath.row];
    
    [AssetManager resolveAsset:asset size:CGSizeZero completion:^(UIImage *image) {
        if (!image) {
            return;
        }
        
        if (cell.selectedImageView.image) {
            [UIView animateWithDuration:0.2 animations:^{
                cell.selectedImageView.transform = CGAffineTransformMakeScale(0.1, 0.1);
            } completion:^(BOOL finished) {
                cell.selectedImageView.image = nil;
            }];
            
            [self.selectedStack dropAsset:asset];
        } else if (self.imageLimit == 0 || self.imageLimit > self.selectedStack.assets.count) {
            cell.selectedImageView.image = [AssetManager getImage:@"selectedImageGallery"];
            cell.selectedImageView.transform = CGAffineTransformMakeScale(0, 0);
            [UIView animateWithDuration:0.2f animations:^{
                cell.selectedImageView.transform = CGAffineTransformIdentity;
            }];
            [self.selectedStack pushAsset:asset];
        }
    }];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!(indexPath.row + 10 >= self.assets.count && indexPath.row < self.fetchResult.count && self.canFetchImages)) {
        return;
    }
    [self fetchPhotos:nil];
    self.canFetchImages = false;
}

#pragma mark - CollectionView datasource methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    [self displayNoImagesMessage:!self.assets.count];
    return self.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageGalleryViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kReusableIdentifier forIndexPath:indexPath];
    if (!cell) {
        return [[UICollectionViewCell alloc] init];
    }
    PHAsset *asset = self.assets[indexPath.row];
    [AssetManager resolveAsset:asset size:CGSizeMake(160, 240) completion:^(UIImage *image) {
        if (image) {
            [cell configureCell:image];
            
            if (indexPath.row == 0 && self.shouldTransform) {
                cell.transform = CGAffineTransformMakeScale(0, 0);
                [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    cell.transform = CGAffineTransformIdentity;
                } completion:^(BOOL finished) {
                    self.shouldTransform = NO;
                }];
            }
            
            if ([self.selectedStack containsAsset:asset]) {
                cell.selectedImageView.image = [AssetManager getImage:@"selectedImageGallery"];
                cell.selectedImageView.alpha = 1;
                cell.selectedImageView.transform = CGAffineTransformIdentity;
            } else {
                cell.selectedImageView.image = nil;
            }
        }
    }];
    
    return cell;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.collectionViewLayout];
        _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        _collectionView.backgroundColor = Config.mainColor;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
    }
    return _collectionView;
}

- (ImageGalleryLayout *)collectionViewLayout {
    if (!_collectionViewLayout) {
        _collectionViewLayout = [[ImageGalleryLayout alloc] init];
        _collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionViewLayout.minimumInteritemSpacing = Config.cellSpacing;
        _collectionViewLayout.minimumLineSpacing = 2;
        _collectionViewLayout.sectionInset = UIEdgeInsetsZero;
    }
    return _collectionViewLayout;
}

- (UIView *)topSeparator {
    if (!_topSeparator) {
        _topSeparator = [[UIView alloc] init];
        _topSeparator.translatesAutoresizingMaskIntoConstraints = NO;
        [_topSeparator addGestureRecognizer:self.panGestureRecognizer];
        _topSeparator.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    }
    return _topSeparator;
}

- (UIPanGestureRecognizer *)panGestureRecognizer {
    if (!_panGestureRecognizer) {
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] init];
        [_panGestureRecognizer addTarget:self action:@selector(handlePanGestureRecognizer:)];
    }
    return _panGestureRecognizer;
}

- (UILabel *)noImagesLabel {
    if (!_noImagesLabel) {
        _noImagesLabel = [[UILabel alloc] init];
        _noImagesLabel.font = Config.noCameraFont;
        _noImagesLabel.textColor = Config.noImagesColor;
        _noImagesLabel.text = Config.noImagesTitle;
        _noImagesLabel.alpha = 0;
        [_noImagesLabel sizeToFit];
        [self addSubview:_noImagesLabel];
    }
    return _noImagesLabel;
}

- (NSMutableArray *)assets {
    if (!_assets) {
        _assets = [NSMutableArray array];
    }
    return _assets;
}

@end
