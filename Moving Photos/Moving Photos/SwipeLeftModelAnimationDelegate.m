//
//  ModelAnimationDelegate.m
//  Moving Photos
//
//  Created by 519968211 on 2019/9/7.
//

#import "SwipeLeftModelAnimationDelegate.h"

@implementation SwipeLeftModelAnimationDelegate

- (void)presentViewAnimation:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    // 获取容器view
    UIView *containerView = [transitionContext containerView];
    
    // 获取目标view
    _photoAnimateView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _photoAnimateView.backgroundColor = [UIColor blackColor];
    [containerView addSubview:_photoAnimateView];
    
    CGFloat height = _image.size.height*[[UIScreen mainScreen] bounds].size.width/_image.size.width;
    _photoAnimateImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, ([[UIScreen mainScreen] bounds].size.height-height)/2.0, [[UIScreen mainScreen] bounds].size.width, height)];
    _photoAnimateImageView.center = _photoAnimateView.center;
    _photoAnimateImageView.image = _image;
    [_photoAnimateView addSubview:_photoAnimateImageView];
    
    UIView *destinationView = [transitionContext viewForKey:UITransitionContextToViewKey];
//    destinationView.alpha = 0;
    // 将目标view添加到容器view
    [containerView addSubview:destinationView];
    
    // 获取动画开始位置大小
    destinationView.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    
    // 执行过渡动画
    __weak SwipeLeftModelAnimationDelegate *weakSelf = self;
    [UIView animateWithDuration:1.0 animations:^{
        weakSelf.photoAnimateView.frame = CGRectMake(-[[UIScreen mainScreen] bounds].size.width, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
        destinationView.frame = [[UIScreen mainScreen] bounds];
    } completion:^(BOOL finished) {
        [weakSelf.photoAnimateView removeFromSuperview];
        [transitionContext completeTransition:YES];
    }];
    
}

//  视图消失
- (void)dismissViewAnimation:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    // 获取容器view
    UIView *containerView = [transitionContext containerView];
    
    // 获取目标view
    _photoAnimateView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _photoAnimateView.backgroundColor = [UIColor blackColor];
    [containerView addSubview:_photoAnimateView];
    
    CGFloat height = _image1.size.height*[[UIScreen mainScreen] bounds].size.width/_image1.size.width;
    _photoAnimateImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, ([[UIScreen mainScreen] bounds].size.height-height)/2.0, [[UIScreen mainScreen] bounds].size.width, height)];
    _photoAnimateImageView.center = _photoAnimateView.center;
    _photoAnimateImageView.image = _image1;
    [_photoAnimateView addSubview:_photoAnimateImageView];
    
//    UIView *destinationView = [transitionContext viewForKey:UITransitionContextToViewKey];
//    //    destinationView.alpha = 0;
//    // 将目标view添加到容器view
//    [containerView addSubview:destinationView];
//
//    // 获取动画开始位置大小
//    destinationView.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    
    // 执行过渡动画
    __weak SwipeLeftModelAnimationDelegate *weakSelf = self;
    [UIView animateWithDuration:1.0 animations:^{
        weakSelf.photoAnimateImageView.frame = weakSelf.dissmissRect;
//        destinationView.frame = [[UIScreen mainScreen] bounds];
    } completion:^(BOOL finished) {
        [weakSelf.photoAnimateView removeFromSuperview];
        [transitionContext completeTransition:YES];
    }];
}





- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return 1.0;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    _isPresentAnimationing ?  [self presentViewAnimation:transitionContext] : [self dismissViewAnimation:transitionContext];
    
}

#pragma mark UIViewControllerTransitioningDelegate

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    _isPresentAnimationing = YES;
    return self;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    _isPresentAnimationing = NO;
    return self;
    
}

@end
