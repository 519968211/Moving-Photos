//
//  CameraView.m
//  ImagePickerDemo
//
//  Created by hanxt on 16/9/21.
//  Copyright © 2016年 hanxt. All rights reserved.
//

#import "CameraView.h"
#import <CoreLocation/CoreLocation.h>
#import "CameraMan.h"
#import "AssetManager.h"
#import "Configuration.h"
#import "LocationManager.h"

@interface CameraView () <CLLocationManagerDelegate, CameraManDelegate>

@property (nonatomic, strong) UIVisualEffectView *blurView;

@property (nonatomic, strong) UIImageView *focusImageView;

@property (nonatomic, strong) UIView *capturedImageView;

@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) UILabel *noCameraLabel;

@property (nonatomic, strong) UIButton *noCameraButton;

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic, strong) CameraMan *cameraMan;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, strong) NSTimer *animationTimer;

@property (nonatomic, strong) LocationManager *locationManager;

@end

@implementation CameraView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (Config.recordLocation) {
        self.locationManager = [[LocationManager alloc] init];
    }
    
    self.view.backgroundColor = Config.mainColor;
    
    [self.view addSubview:self.containerView];
    [self.containerView addSubview:self.blurView];
    
    [self.view addSubview:self.focusImageView];
    [self.view addSubview:self.capturedImageView];
    
    [self.view addGestureRecognizer:self.tapGestureRecognizer];
    
    self.cameraMan.delegate = self;
    [self.cameraMan setup];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.previewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    [self.locationManager startUpdatingLocation];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.locationManager startUpdatingLocation];
}

- (void)setupPreviewLayer {
    AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:self.cameraMan.session];
    if (!layer) {
        return;
    }
    
    layer.backgroundColor = Config.mainColor.CGColor;
    layer.autoreverses = YES;
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [self.view.layer insertSublayer:layer atIndex:0];
    layer.frame = self.view.layer.frame;
    self.view.clipsToBounds = YES;
    
    self.previewLayer = layer;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat centerX = self.view.bounds.size.width / 2;
    
    self.noCameraLabel.center = CGPointMake(centerX, self.view.bounds.size.height/2 - 80);
    self.noCameraButton.center = CGPointMake(centerX, CGRectGetMaxY(self.noCameraLabel.frame) + 20);
    self.blurView.frame = self.view.bounds;
    self.blurView.frame = self.view.bounds;
    self.capturedImageView.frame = self.view.bounds;
}

#pragma mark - actions
- (void)settingsButtonDidTap {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURL *settingURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if (settingURL) {
            [[UIApplication sharedApplication] openURL:settingURL];
        }
    });
}

#pragma mark - Camera actions
- (void)rotateCamera {
    [UIView animateWithDuration:0.3 animations:^{
        self.containerView.alpha = 1.f;
    } completion:^(BOOL finished) {
        [self.cameraMan switchCameraWithCompletion:^{
            [UIView animateWithDuration:0.7f animations:^{
                self.containerView.alpha = 0;
            }];
        }];
    }];
}

- (void)flashCamera:(NSString *)title {
    AVCaptureFlashMode mode = AVCaptureFlashModeAuto;
    
    if ([title isEqualToString:@"ON"]) {
        mode = AVCaptureFlashModeOn;
    } else if ([title isEqualToString:@"OFF"]) {
        mode = AVCaptureFlashModeOff;
    }
    [self.cameraMan flash:mode];
}

- (void)takePicture:(void (^)(void))completion {
    if (!self.previewLayer) {
        return;
    }
    
    [UIView animateWithDuration:0.1 animations:^{
        self.capturedImageView.alpha = 1.f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1f animations:^{
            self.capturedImageView.alpha = 0.f;
        }];
    }];
    
    [self.cameraMan takePhoto:self.previewLayer location:self.locationManager.latestLocation completion:^{
        completion();
        if ([self.delegate respondsToSelector:@selector(imageToLibrary)]) {
            [self.delegate imageToLibrary];
        }
    }];
}

#pragma mark - Timer methods
- (void)timerDidFire {
    [UIView animateWithDuration:0.3 animations:^{
        self.focusImageView.alpha = 0.f;
    } completion:^(BOOL finished) {
        self.focusImageView.transform = CGAffineTransformIdentity;
    }];
}

#pragma mark - Camera methods
- (void)focusTo:(CGPoint)point {
    CGPoint convertedPoint = CGPointMake(point.x / [UIScreen mainScreen].bounds.size.width, point.y / [UIScreen mainScreen].bounds.size.height);
    
    [self.cameraMan focus:convertedPoint];
    self.focusImageView.center = point;
    [UIView animateWithDuration:0.5 animations:^{
        self.focusImageView.alpha = 1.f;
        self.focusImageView.transform = CGAffineTransformMakeScale(0.6, 0.6);
    } completion:^(BOOL finished) {
        self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(timerDidFire) userInfo:nil repeats:NO];
    }];
}

#pragma mark - tap
- (void)tapGestureRecognizerHandler:(UITapGestureRecognizer *)gesture {
    CGPoint touch = [gesture locationInView:self.view];
    
    self.focusImageView.transform = CGAffineTransformIdentity;
    [self.animationTimer invalidate];
    [self focusTo:touch];
}

#pragma mark - private
- (void)showNoCamera:(BOOL)show {
    if (show) {
        [self.view addSubview:self.noCameraButton];
        [self.view addSubview:self.noCameraLabel];
    } else {
        [self.noCameraButton removeFromSuperview];
        [self.noCameraLabel removeFromSuperview];
    }
}

#pragma mark - CameraManDelegate
- (void)cameraManNotAvailable:(CameraMan *)cameraMan {
    [self showNoCamera:YES];
    self.focusImageView.hidden = YES;
    if ([self.delegate respondsToSelector:@selector(cameraNotAvailable)]) {
        [self.delegate cameraNotAvailable];
    }
}

- (void)cameraMan:(CameraMan *)cameraMan didChangeInput:(AVCaptureDeviceInput *)input {
    if ([self.delegate respondsToSelector:@selector(setFlashButtonHidden:)]) {
        [self.delegate setFlashButtonHidden:!input.device.hasFlash];
    }
}

- (void)cameraManDidStart:(CameraMan *)cameraMan {
    [self setupPreviewLayer];
}

#pragma mark - lazy load
- (UIVisualEffectView *)blurView {
    if (!_blurView) {
        _blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    }
    return _blurView;
}

- (UIImageView *)focusImageView {
    if (!_focusImageView) {
        _focusImageView = [[UIImageView alloc] init];
        _focusImageView.image = [AssetManager getImage:@"focusIcon"];
        _focusImageView.backgroundColor = [UIColor clearColor];
        _focusImageView.frame = CGRectMake(0, 0, 110, 110);
        _focusImageView.alpha = 0;
    }
    return _focusImageView;
}

- (UIView *)capturedImageView {
    if (!_capturedImageView) {
        _capturedImageView = [[UIView alloc] init];
        _capturedImageView.backgroundColor = [UIColor blueColor];
        _capturedImageView.alpha = 0;
    }
    return _capturedImageView;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.alpha = 0;
    }
    return _containerView;
}

- (UILabel *)noCameraLabel {
    if (!_noCameraLabel) {
        _noCameraLabel = [[UILabel alloc] init];
        _noCameraLabel.font = Config.noCameraFont;
        _noCameraLabel.textColor = Config.noCameraColor;
        _noCameraLabel.text = Config.noCameraTitle;
        [_noCameraLabel sizeToFit];
    }
    return _noCameraLabel;
}

- (UIButton *)noCameraButton {
    if (!_noCameraButton) {
        _noCameraButton = [UIButton buttonWithType:UIButtonTypeSystem];
        NSAttributedString *title = [[NSAttributedString alloc] initWithString:Config.settingsTitle attributes:@{NSFontAttributeName : Config.settingsFont, NSForegroundColorAttributeName : Config.settingsColor}];
        [_noCameraButton setAttributedTitle:title forState:UIControlStateNormal];
        _noCameraButton.contentEdgeInsets = UIEdgeInsetsMake(5.f, 10.f, 5.f, 10.f);
        [_noCameraButton sizeToFit];
        _noCameraButton.layer.borderColor = Config.settingsColor.CGColor;
        _noCameraButton.layer.borderWidth = 1.f;
        _noCameraButton.layer.cornerRadius = 4.f;
        [_noCameraButton addTarget:self action:@selector(settingsButtonDidTap) forControlEvents:UIControlEventTouchUpInside];
    }
    return _noCameraButton;
}

- (UITapGestureRecognizer *)tapGestureRecognizer {
    if (!_tapGestureRecognizer) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
        [_tapGestureRecognizer addTarget:self action:@selector(tapGestureRecognizerHandler:)];
    }
    return _tapGestureRecognizer;
}

- (CameraMan *)cameraMan {
    if (!_cameraMan) {
        _cameraMan = [[CameraMan alloc] init];
    }
    return _cameraMan;
}

@end
