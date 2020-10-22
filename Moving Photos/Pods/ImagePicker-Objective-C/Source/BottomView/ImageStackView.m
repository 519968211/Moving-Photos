//
//  ImageStackView.m
//  ImagePickerDemo
//
//  Created by hanxt on 16/9/21.
//  Copyright © 2016年 hanxt. All rights reserved.
//

#import "ImageStackView.h"
#import <Photos/Photos.h>
#import "ImageStack.h"
#import "AssetManager.h"

CGFloat const kImageSize = 58.f;

@interface ImageStackView()

@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@property (nonatomic, strong) NSMutableArray<UIImageView *> *views;


@end


@implementation ImageStackView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%@ dealloc", [self class]);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:(CGRect)frame];
    if (self) {
        [self subscribe];
        [self.views enumerateObjectsUsingBlock:^(UIImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self addSubview:obj];
        }];
        [self addSubview:self.activityView];
        self.views.firstObject.alpha = 1.f;
    }
    return self;
}

- (void)subscribe {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageDidPushWithNotification:) name:kNotificationImageDidPush object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageStackDidChangeContentWithNotification:) name:kNotificationImageDidDrop object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageStackDidChangeContentWithNotification:) name:kNotificationStackDidReload object:nil];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat step = - 3.f;
    CGFloat scale = 0.8f;
    CGSize viewSize = CGSizeMake(self.frame.size.width * scale, self.frame.size.height * scale);
    
    CGFloat offset = -step * self.views.count;
    CGPoint origin = CGPointMake(offset, offset);
    
    for (UIImageView *view in self.views) {
        origin.x += step;
        origin.y += step;
        view.frame = CGRectMake(origin.x, origin.y, viewSize.width, viewSize.height);
    }
}

- (void)startLoader {
    UIView *firstVisibleView = nil;
    for (UIView *subview in self.views) {
        if (subview.alpha == 1.0) {
            firstVisibleView = subview;
            break;
        }
    }
    if (firstVisibleView) {
        self.activityView.frame = CGRectMake(firstVisibleView.center.x, firstVisibleView.center.y, self.activityView.frame.size.width, self.activityView.frame.size.height);
    }
    
    [self.activityView startAnimating];
    [UIView animateWithDuration:0.3 animations:^{
        self.activityView.alpha = 1.0f;
    }];
}

#pragma mark - lazy load
- (NSMutableArray *)views {
    if (!_views) {
        _views = [NSMutableArray array];
        for (int i = 0; i < 3; i++) {
            UIImageView *view = [[UIImageView alloc] init];
            view.layer.cornerRadius = 3.f;
            view.layer.borderColor = [UIColor whiteColor].CGColor;
            view.layer.borderWidth = 1.f;
            view.contentMode = UIViewContentModeScaleAspectFit;
            view.clipsToBounds = YES;
            view.alpha = 0.f;
            [_views addObject:view];
        }
    }
    return _views;
}

- (UIActivityIndicatorView *)activityView {
    if (!_activityView) {
        _activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
        _activityView.alpha = 0.f;
    }
    return _activityView;
}

#pragma mark - notification

- (void)imageDidPushWithNotification:(NSNotification *)notification {
    UIImageView *emptyView = nil;
    for (UIImageView *view in self.views) {
        if (!view.image) {
            emptyView = view;
            break;
        }
    }
    
    if (emptyView) {
        [self animateImageView:emptyView];
    }
    
    ImageStack *sender = (ImageStack *)notification.object;
    if (sender) {
        [self renderViewsWithAssets:sender.assets];
        [self.activityView stopAnimating];
    }
}

- (void)imageStackDidChangeContentWithNotification:(NSNotification *)notification {
    ImageStack *sender = (ImageStack *)notification.object;
    if (sender) {
        [self renderViewsWithAssets:sender.assets];
        [self.activityView stopAnimating];
    }
    
}

- (void)renderViewsWithAssets:(NSArray<PHAsset *> *)assets {
    if (assets.count <= 0) {
        UIImageView *firstView = self.views.firstObject;
        for (UIImageView *view in self.views) {
            view.image = nil;
            view.alpha = 0;
        }
        firstView.alpha = 1.f;
        return;
    }
    
    NSArray *photos = nil;
    
    if (assets.count <= 4) {
        photos = [assets copy];
    } else {
        photos = [assets subarrayWithRange:NSMakeRange(0, 3)];
    }
    
    [self.views enumerateObjectsUsingBlock:^(UIImageView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx <= photos.count - 1) {
            [AssetManager resolveAsset:photos[idx] size:CGSizeMake(kImageSize, kImageSize) completion:^(UIImage *image) {
                view.image = image;
            }];
            view.alpha = 1.f;
        } else {
            view.image = nil;
            view.alpha = 0.f;
        }
        
        if (idx == photos.count) {
            [UIView animateWithDuration:0.3f animations:^{
                self.activityView.frame = CGRectMake(view.center.x + 3, view.center.x + 3, self.activityView.frame.size.width, self.activityView.frame.size.height);
            }];
        }
    }];
}

- (void)animateImageView:(UIImageView *)imageView {
    imageView.transform = CGAffineTransformMakeScale(0.f, 0.f);
    
    [UIView animateWithDuration:0.3f animations:^{
        imageView.transform = CGAffineTransformMakeScale(1.05f, 1.05f);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            self.activityView.alpha = 0.0;
            imageView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [self.activityView stopAnimating];
        }];
    }];
}

@end
