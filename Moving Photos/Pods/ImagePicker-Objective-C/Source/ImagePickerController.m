//
//  ImagePickerController.m
//  ImagePickerDemo
//
//  Created by hanxt on 16/9/21.
//  Copyright © 2016年 hanxt. All rights reserved.
//

#import "ImagePickerController.h"
#import "ImageGalleryView.h"
#import "TopView.h"
#import "CameraView.h"
#import <MediaPlayer/MediaPlayer.h>
#import <Photos/Photos.h>
#import "ImageStack.h"
#import "BottomContainerView.h"
#import "Configuration.h"
#import "ImageGalleryLayout.h"
#import "ButtonPicker.h"
#import "ImageStackView.h"
#import "AssetManager.h"
#import "Helper.h"

static CGFloat const kMaximumHeight = 200.f;
static CGFloat const kMinimumHeight = 125.f;
static CGFloat const kVelocity = 100.f;

@interface ImagePickerController () <ImageGalleryViewDelegate, TopViewDelegate, CameraViewDelegate, BottomContainerViewDelegate>

@property (nonatomic, strong) ImageGalleryView *galleryView;

@property (nonatomic, strong) BottomContainerView *bottomContainer;

@property (nonatomic, strong) ImageStack *stack;

@property (nonatomic, assign) NSInteger imageLimit;

@property (nonatomic, strong) TopView *topView;

@property (nonatomic, strong) CameraView *cameraController;

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

@property (nonatomic, strong) MPVolumeView *volumeView;

@property (nonatomic, assign) CGFloat volume;

@property (nonatomic, assign) CGSize preferredImageSize;

@property (nonatomic, assign) CGSize totalSize;

@property (nonatomic, assign) CGRect initialFrame;

@property (nonatomic, assign) CGPoint initialContentOffset;

@property (nonatomic, assign) NSInteger numberOfCells;

@property (nonatomic, assign) BOOL statusBarHidden;

@property (nonatomic, assign) BOOL isTakingPicture;

@property (nonatomic, copy) NSString *doneButtonTitle;

@end

@implementation ImagePickerController

- (void)dealloc {
    [[AVAudioSession sharedInstance] setActive:NO error:NULL];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%@ dealloc", [self class]);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.volume = [[AVAudioSession sharedInstance] outputVolume];
    self.stack = [[ImageStack alloc] init];
    self.imageLimit = 0;
    self.totalSize = [UIScreen mainScreen].bounds.size;
    
    [@[self.cameraController.view, self.galleryView, self.bottomContainer, self.topView] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.view addSubview:view];
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }];
    
    [self.view addSubview:self.volumeView];
    [self.view sendSubviewToBack:self.volumeView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = Config.mainColor;
    
    [self.cameraController.view addGestureRecognizer:self.panGestureRecognizer];
    
    [self subscribe];
    [self setupConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[AVAudioSession sharedInstance] setActive:YES error:NULL];
    
    self.statusBarHidden = [UIApplication sharedApplication].statusBarHidden;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    CGFloat galleryHeight = 0;
    if ([UIScreen mainScreen].nativeBounds.size.height == 960) {
        galleryHeight = kGalleryBarHeight;
    } else {
        galleryHeight = kMinimumHeight;
    }
    
    self.galleryView.collectionView.transform = CGAffineTransformIdentity;
    self.galleryView.collectionView.contentInset = UIEdgeInsetsZero;
    
    self.galleryView.frame = CGRectMake(0, self.totalSize.height - self.bottomContainer.frame.size.height - galleryHeight, self.totalSize.width, galleryHeight);
    
    [self.galleryView updateFrames];
    [self checkStatus];
    
    self.initialFrame = self.galleryView.frame;
    self.initialContentOffset = self.galleryView.collectionView.contentOffset;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:self.statusBarHidden withAnimation:UIStatusBarAnimationFade];
}

- (void)resetAssets {
    [self.stack resetAssets:@[]];
}

- (void)checkStatus {
    PHAuthorizationStatus currentStatus = [PHPhotoLibrary authorizationStatus];
    if (currentStatus != PHAuthorizationStatusAuthorized) {
        return;
    }
    if (currentStatus == PHAuthorizationStatusNotDetermined) {
        [self hideViews];
    }
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == PHAuthorizationStatusDenied) {
                [self presentAskPermissionAlert];
            } else if (status == PHAuthorizationStatusAuthorized) {
                [self permissionGranted];
            }
        });
    }];
}

- (void)presentAskPermissionAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:Config.requestPermissionTitle message:Config.requestPermissionMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:Config.OKButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:settingsURL];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:Config.cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alertController addAction:alertAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)permissionGranted {
    [self.galleryView fetchPhotos:nil];
    self.galleryView.canFetchImages = NO;
    [self enableGestures:YES];
}

- (void)hideViews {
    [self enableGestures:NO];
}

- (void)subscribe {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustButtonTitle:) name:kNotificationImageDidPush object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustButtonTitle:) name:kNotificationImageDidDrop object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReloadAssets:) name:kNotificationStackDidReload object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRotation:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)didReloadAssets:(NSNotification *)notification {
    [self adjustButtonTitle:notification];
    [self.galleryView.collectionView reloadData];
    [self.galleryView.collectionView setContentOffset:CGPointZero animated:NO];
}

- (void)volumeChanged:(NSNotification *)notification {
    NSString *changeReason = (NSString *)notification.userInfo[@"AVSystemController_AudioVolumeChangeReasonNotificationParameter"];
    UISlider *slider = nil;
    for (UIView *subview in self.volumeView.subviews) {
        if ([subview isKindOfClass:[UISlider class]]) {
            slider = (UISlider *)subview;
        }
    }
    if (!slider || ![changeReason isEqualToString:@"ExplicitVolumeChange"]) {
        return;
    }
    [slider setValue:self.volume animated:NO];
    [self takePicture];
}


- (void)adjustButtonTitle:(NSNotification *)notification {
    ImageStack *sender = (ImageStack*)notification.object;
    if (!sender) {
        return;
    }
    NSString *title = sender.assets.count ? Config.doneButtonTitle : Config.cancelButtonTitle;
    [self.bottomContainer.doneButton setTitle:title forState:UIControlStateNormal];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)collapseGalleryView:(void (^)(void))completion {
    [self.galleryView.collectionViewLayout invalidateLayout];
    [UIView animateWithDuration:0.3 animations:^{
        [self updateGalleryViewFrames:self.galleryView.topSeparator.frame.size.height];
        self.galleryView.collectionView.transform = CGAffineTransformIdentity;
        self.galleryView.collectionView.contentInset = UIEdgeInsetsZero;
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

- (void)showGalleryView {
    [self.galleryView.collectionViewLayout invalidateLayout];
    [UIView animateWithDuration:0.3 animations:^{
        [self updateGalleryViewFrames:kMinimumHeight];
        self.galleryView.collectionView.transform = CGAffineTransformIdentity;
        self.galleryView.collectionView.contentInset = UIEdgeInsetsZero;
    }];
}

- (void)expandGalleryView {
    [self.galleryView.collectionViewLayout invalidateLayout];
    [UIView animateWithDuration:0.3 animations:^{
        [self updateGalleryViewFrames:kMaximumHeight];
        
        CGFloat scale = (kMaximumHeight - kGalleryBarHeight) / (kMinimumHeight - kGalleryBarHeight);
        self.galleryView.collectionView.transform = CGAffineTransformMakeScale(scale, scale);
        
        CGFloat value = self.view.frame.size.width * (scale - 1) /scale;
        self.galleryView.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, value);
    }];
}

- (void)updateGalleryViewFrames:(CGFloat)constant {
    self.galleryView.frame = CGRectMake(self.galleryView.frame.origin.x, self.totalSize.height - self.bottomContainer.frame.size.height - constant, self.galleryView.frame.size.width, constant);
}

- (void)enableGestures:(BOOL)enabled {
    self.galleryView.alpha = enabled ? 1 : 0;
    self.bottomContainer.pickerButton.enabled = enabled;
    self.bottomContainer.tapGestureRecognizer.enabled = enabled;
    self.topView.flashButton.enabled = enabled;
    self.topView.rotateCamera.enabled = Config.canRotateCamera;
}

- (BOOL)isBelowImageLimit {
    return (self.imageLimit ==0 || self.imageLimit > self.galleryView.selectedStack.assets.count);
}

- (void)takePicture {
    if (![self isBelowImageLimit] || self.isTakingPicture) {
        return;
    }
    self.isTakingPicture = YES;
    self.bottomContainer.pickerButton.enabled = NO;
    [self.bottomContainer.stackView startLoader];
    void(^action)(void) = ^(void) {
        [self.cameraController takePicture:^{
            self.isTakingPicture = NO;
        }];
    };
    
    if (Config.collapseCollectionViewWhileShot) {
        [self collapseGalleryView:action];
    } else {
        action();
    }
}

#pragma mark - BottomContainerViewDelegate methods
- (void)pickerButtonDidPress {
    [self takePicture];
}

- (void)doneButtonDidPress {
    NSArray *images = nil;
    if (!CGSizeEqualToSize(self.preferredImageSize, CGSizeZero)) {
        images = [AssetManager resolveAssets:self.stack.assets size:self.preferredImageSize];
    } else {
        images = [AssetManager resolveAssets:self.stack.assets size:CGSizeZero];
    }
    
    if ([self.delegate respondsToSelector:@selector(doneButtonDidPress:images:)]) {
        [self.delegate doneButtonDidPress:self images:images];
    }
}

- (void)cancelButtonDidPress {
    [self dismissViewControllerAnimated:YES completion:nil];
    if ([self.delegate respondsToSelector:@selector(cancelButtonDidPress:)]) {
        [self.delegate cancelButtonDidPress:self];
    }
}

- (void)imageStackViewDidPress {
    NSArray *images = nil;
    if (!CGSizeEqualToSize(self.preferredImageSize, CGSizeZero)) {
        images = [AssetManager resolveAssets:self.stack.assets size:self.preferredImageSize];
    } else {
        images = [AssetManager resolveAssets:self.stack.assets size:CGSizeZero];
    }
    
    if ([self.delegate respondsToSelector:@selector(wrapperDidPress:images:)]) {
        [self.delegate wrapperDidPress:self images:images];
    }
}

#pragma mark - CameraViewDelegate methods
- (void)setFlashButtonHidden:(BOOL)hidden {
    self.topView.flashButton.hidden = hidden;
}

- (void)imageToLibrary {
    if (CGSizeEqualToSize(self.galleryView.collectionSize, CGSizeZero)) {
        return;
    }
    
    [self.galleryView fetchPhotos:^{
        PHAsset *asset = self.galleryView.assets.firstObject;
        if (!asset) {
            return;
        }
        [self.stack pushAsset:asset];
    }];
    
    self.galleryView.shouldTransform = YES;
    self.bottomContainer.pickerButton.enabled = YES;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.galleryView.collectionView.transform = CGAffineTransformMakeTranslation(self.galleryView.collectionSize.width, 0);
    } completion:^(BOOL finished) {
        self.galleryView.collectionView.transform = CGAffineTransformIdentity;
    }];
}

- (void)cameraNotAvailable {
    self.topView.flashButton.hidden = true;
    self.topView.rotateCamera.hidden = true;
    self.bottomContainer.pickerButton.enabled = false;
}

#pragma mark - Rotation
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)handleRotation:(NSNotification *)notification {
    CGAffineTransform rotate = [Helper rotationTransform];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.topView.rotateCamera.transform = rotate;
        self.bottomContainer.pickerButton.transform = rotate;
        self.bottomContainer.stackView.transform = rotate;
        self.bottomContainer.doneButton.transform = rotate;
        
        [self.galleryView.collectionViewLayout invalidateLayout];
        
        CGAffineTransform translate = CGAffineTransformIdentity;
        if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight) {
            translate = CGAffineTransformMakeTranslation(-20, 15);
        } else {
            translate = CGAffineTransformIdentity;
        }
        
        self.topView.flashButton.transform = CGAffineTransformConcat(rotate, translate);
    }];
}

#pragma mark - TopViewDelegate methods
- (void)flashButtonDidPress:(NSString *)title {
    [self.cameraController flashCamera:title];
}

- (void)rotateDeviceDidPress {
    [self.cameraController rotateCamera];
}

#pragma mark - Pan gesture handler
- (void)panGestureDidStart {
    if (CGSizeEqualToSize(self.galleryView.collectionSize, CGSizeZero)) {
        return;
    }
    self.initialFrame = self.galleryView.frame;
    self.initialContentOffset = self.galleryView.collectionView.contentOffset;
    
    if (!CGPointEqualToPoint(self.initialContentOffset, CGPointZero)) {
        self.numberOfCells = (int)(self.initialContentOffset.x / self.initialContentOffset.y);
    }
}

- (void)panGestureDidChangeWithTranslation:(CGPoint)translation {
    if (CGRectEqualToRect(self.initialFrame, CGRectZero)) {
        return;
    }
    CGFloat galleryHeight = self.initialFrame.size.height - translation.y;
    
    if (galleryHeight >= kMaximumHeight) {
        return;
    }
    
    if (galleryHeight <= kGalleryBarHeight) {
        [self updateGalleryViewFrames:kGalleryBarHeight];
    } else if (galleryHeight >= kMinimumHeight) {
        CGFloat scale = (galleryHeight - kGalleryBarHeight) / (kMinimumHeight - kGalleryBarHeight);
        self.galleryView.collectionView.transform = CGAffineTransformMakeScale(scale, scale);
        self.galleryView.frame = CGRectMake(self.galleryView.frame.origin.x, self.initialFrame.origin.y + translation.y, self.galleryView.frame.size.width, self.initialFrame.size.height - translation.y);
        
        CGFloat value = self.view.frame.size.width * (scale - 1) / scale;
        self.galleryView.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, value);
    } else {
        self.galleryView.frame = CGRectMake(self.galleryView.frame.origin.x, self.initialFrame.origin.y + translation.y, self.galleryView.frame.size.width, self.initialFrame.size.height - translation.y);
    }
    
    [self.galleryView updateNoImagesLabel];
}

- (void)panGestureDidEndWithTranslation:(CGPoint)translation velocity:(CGPoint)velocity {
    if (CGRectEqualToRect(self.initialFrame, CGRectZero)) {
        return;
    }
    
    CGFloat galleryHeight = self.initialFrame.size.height - translation.y;
    if (self.galleryView.frame.size.height < kMinimumHeight && velocity.y < 0) {
        [self showGalleryView];
    } else if (velocity.y < -kVelocity) {
        [self expandGalleryView];
    } else if (velocity.y > kVelocity || galleryHeight < kMinimumHeight) {
        [self collapseGalleryView:nil];
    }
}

- (void)panGestureRecognizerHandler:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self.view];
    CGPoint velocity = [gesture velocityInView:self.view];
    
    if ([gesture locationInView:self.view].y > self.galleryView.frame.origin.y - 25) {
        if (gesture.state == UIGestureRecognizerStateBegan) {
            [self panGestureDidStart];
        } else {
            [self panGestureDidChangeWithTranslation:translation];
        }
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self panGestureDidEndWithTranslation:translation velocity:velocity];
    }
}


- (void)setupConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomContainer attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomContainer attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomContainer attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomContainer attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:kBottomContainerViewHeight]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraController.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraController.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraController.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraController.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1 constant:-kBottomContainerViewHeight]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.topView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.topView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.topView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.topView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:kTopViewHeight]];
}

- (void)setDoneButtonTitle:(NSString *)doneButtonTitle {
    if (!doneButtonTitle) {
        return;
    }
    [self.bottomContainer.doneButton setTitle:doneButtonTitle forState:UIControlStateNormal];
}

- (BottomContainerView *)bottomContainer {
    if (!_bottomContainer) {
        _bottomContainer = [[BottomContainerView alloc] init];
        _bottomContainer.backgroundColor = [UIColor colorWithRed:0.09 green:0.11 blue:0.13 alpha:1];
        _bottomContainer.delegate = self;
    }
    return _bottomContainer;
}

- (MPVolumeView *)volumeView {
    if (!_volumeView) {
        _volumeView = [[MPVolumeView alloc] init];
        _volumeView.frame = CGRectMake(0, 0, 1, 1);
    }
    return _volumeView;
}

- (UIPanGestureRecognizer *)panGestureRecognizer {
    if (!_panGestureRecognizer) {
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] init];
        [_panGestureRecognizer addTarget:self action:@selector(panGestureRecognizerHandler:)];
    }
    return _panGestureRecognizer;
}

- (ImageGalleryView *)galleryView {
    if (!_galleryView) {
        _galleryView = [[ImageGalleryView alloc] init];
        _galleryView.delegate = self;
        _galleryView.selectedStack = self.stack;
        _galleryView.collectionView.layer.anchorPoint = CGPointMake(0, 0);
        _galleryView.imageLimit = self.imageLimit;
    }
    return _galleryView;
}

- (TopView *)topView {
    if (!_topView) {
        _topView = [[TopView alloc] init];
        _topView.backgroundColor = [UIColor clearColor];
        _topView.delegate = self;
    }
    return _topView;
}

- (CameraView *)cameraController {
    if (!_cameraController) {
        _cameraController = [[CameraView alloc] init];
        _cameraController.delegate = self;
    }
    return  _cameraController;
}

@end
