//
//  TopView.m
//  ImagePickerDemo
//
//  Created by hanxt on 16/9/22.
//  Copyright © 2016年 hanxt. All rights reserved.
//

#import "TopView.h"
#import "AssetManager.h"
#import "Configuration.h"

static CGFloat const kLeftOffset = 11.f;
static CGFloat const kRightOffset = 7.f;
CGFloat const kTopViewHeight = 34.f;

@interface TopView()

@property (nonatomic, assign) NSInteger currentFlashIndex;

@property (nonatomic, copy) NSArray *flashButtonTitles;

@end


@implementation TopView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    NSMutableArray *buttons = [NSMutableArray arrayWithObject:self.flashButton];
    
    if (Config.canRotateCamera) {
        [buttons addObject:self.rotateCamera];
    }
    
    for (UIButton *button in buttons) {
        button.layer.shadowColor = [UIColor blackColor].CGColor;
        button.layer.shadowOpacity = 0.5;
        button.layer.shadowOffset = CGSizeMake(0, 1);
        button.layer.shadowRadius = 1;
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:button];
    }
    
    [self setupConstraints];
}

- (void)setupConstraints {
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.flashButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:kLeftOffset]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.flashButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.flashButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:55]];
    
    if (Config.canRotateCamera) {
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.rotateCamera attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:kRightOffset]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.rotateCamera attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.rotateCamera attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:55]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.rotateCamera attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:55]];
    }
}

- (void)rotateCameraButtonDidPress:(UIButton *) button{
    if ([self.delegate respondsToSelector:@selector(rotateDeviceDidPress)]) {
        [self.delegate rotateDeviceDidPress];
    }
}

- (void)flashButtonDidPress:(UIButton *)button {
    self.currentFlashIndex += 1;
    self.currentFlashIndex = self.currentFlashIndex % self.flashButtonTitles.count;
    
    switch (self.currentFlashIndex) {
        case 1:
            [button setTitleColor:[UIColor colorWithRed:0.98 green:0.98 blue:0.45 alpha:1] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithRed:0.52 green:0.52 blue:0.24 alpha:1] forState:UIControlStateHighlighted];
            break;
            
        default:
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            break;
    }
    
    NSString *newTitle = self.flashButtonTitles[self.currentFlashIndex];
    
    [button setImage:[AssetManager getImage:newTitle] forState:UIControlStateNormal];
    [button setTitle:newTitle forState:UIControlStateNormal];
    
    if ([self.delegate respondsToSelector:@selector(flashButtonDidPress:)]) {
        [self.delegate flashButtonDidPress:newTitle];
    }
}

- (UIButton *)flashButton {
    if (!_flashButton) {
        _flashButton = [[UIButton alloc] init];
        [_flashButton setImage:[AssetManager getImage:@"AUTO"] forState:UIControlStateNormal];
        [_flashButton setTitle:@"AUTO" forState:UIControlStateNormal];
        _flashButton.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0);
        [_flashButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_flashButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        _flashButton.titleLabel.font = Config.flashButton;
        [_flashButton addTarget:self action:@selector(flashButtonDidPress:) forControlEvents:UIControlEventTouchUpInside];
        _flashButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }
    return _flashButton;
}

- (UIButton *)rotateCamera {
    if (!_rotateCamera) {
        _rotateCamera = [[UIButton alloc] init];
        [_rotateCamera setImage:[AssetManager getImage:@"cameraIcon"] forState:UIControlStateNormal];
        [_rotateCamera addTarget:self action:@selector(rotateCameraButtonDidPress:) forControlEvents:UIControlEventTouchUpInside];
        _rotateCamera.imageView.contentMode = UIViewContentModeCenter;
    }
    return _rotateCamera;
}




@end
