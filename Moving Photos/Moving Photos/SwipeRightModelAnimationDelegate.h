//
//  ModelAnimationDelegate.h
//  Moving Photos
//
//  Created by 519968211 on 2019/9/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SwipeRightModelAnimationDelegate : NSObject <UIViewControllerAnimatedTransitioning,UIViewControllerTransitioningDelegate>

 @property (nonatomic, assign) BOOL isPresentAnimationing;
@property (nonatomic, strong) UIView *photoAnimateView;
@property (nonatomic, strong) UIImageView *photoAnimateImageView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *image1;
@property (nonatomic, assign) CGRect dissmissRect;

@end

NS_ASSUME_NONNULL_END
