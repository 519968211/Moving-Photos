//
//  BottomContainerView.m
//  ImagePickerDemo
//
//  Created by hanxt on 16/9/21.
//  Copyright © 2016年 hanxt. All rights reserved.
//

#import "BottomContainerView.h"
#import "ButtonPicker.h"
#import "Configuration.h"
#import "ImageStackView.h"

CGFloat const kBottomContainerViewHeight = 101.f;

@interface BottomContainerView() <ButtonPickerDelegate>

@property (nonatomic, strong) UIView *borderPickerButton;

@property (nonatomic, strong) UIView *topSeparator;

@property (nonatomic, assign) NSInteger pastCount;

@end

@implementation BottomContainerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    [self addSubview:self.borderPickerButton];
    self.borderPickerButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.pickerButton];
    self.pickerButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.doneButton];
    self.doneButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.stackView];
    self.stackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.topSeparator];
    self.topSeparator.translatesAutoresizingMaskIntoConstraints = NO;
    [self setupConstraints];
}

- (void)setupConstraints {
    
    //self.pickerButton
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.pickerButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.pickerButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.pickerButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:kButtonSize]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.pickerButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:kButtonSize]];
    
    //self.borderPickerButton
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.borderPickerButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.borderPickerButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.borderPickerButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:kButtonBorderSize]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.borderPickerButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:kButtonBorderSize]];
    
    //self.topSeparator
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.topSeparator attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.topSeparator attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.topSeparator attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.topSeparator attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:1]];
    
    //self.stackView
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.stackView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:kImageSize]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.stackView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:kImageSize]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.stackView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:-2]];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.stackView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:width/4 - kButtonBorderSize/3]];
    
    //self.doneButton
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.doneButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.doneButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:-(width - (kButtonBorderSize + width)/2)/2]];
}

#pragma mark - private
- (void)doneButtonDidPress:(UIButton *)button {
    if ([button.currentTitle isEqualToString:Config.cancelButtonTitle]) {
        if ([self.delegate respondsToSelector:@selector(cancelButtonDidPress)]) {
            [self.delegate cancelButtonDidPress];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(doneButtonDidPress)]) {
            [self.delegate doneButtonDidPress];
        }
    }
}

- (void)handleTapGestureRecognizer:(UITapGestureRecognizer *)recognizer {
    if ([self.delegate respondsToSelector:@selector(imageStackViewDidPress)]) {
        [self.delegate imageStackViewDidPress];
    }
}

- (void)animateImageView:(UIImageView *)imageView {
    imageView.transform = CGAffineTransformMakeScale(0, 0);
    
    [UIView animateWithDuration:0.3f animations:^{
        imageView.transform = CGAffineTransformMakeScale(1.05f, 1.05f);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            imageView.transform = CGAffineTransformIdentity;
        }];
    }];
}

#pragma mark - lazy load

- (UITapGestureRecognizer *)tapGestureRecognizer {
    if (!_tapGestureRecognizer) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
        [_tapGestureRecognizer addTarget:self action:@selector(handleTapGestureRecognizer:)];
    }
    return _tapGestureRecognizer;
}

- (UIView *)topSeparator {
    if (!_topSeparator) {
        _topSeparator = [[UIView alloc] init];
        _topSeparator.backgroundColor = Config.backgroundColor;
    }
    return _topSeparator;
}

- (ImageStackView *)stackView {
    if (!_stackView) {
        _stackView = [[ImageStackView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    }
    return _stackView;
}

- (UIButton *)doneButton {
    if (!_doneButton) {
        _doneButton = [[UIButton alloc] init];
        [_doneButton setTitle:Config.cancelButtonTitle forState:UIControlStateNormal];
        _doneButton.titleLabel.font = Config.doneButton;
        [_doneButton addTarget:self action:@selector(doneButtonDidPress:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneButton;
}

- (UIView *)borderPickerButton {
    if (!_borderPickerButton) {
        _borderPickerButton = [[UIView alloc] initWithFrame:CGRectZero];
        _borderPickerButton.backgroundColor = [UIColor clearColor];
        _borderPickerButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _borderPickerButton.layer.borderWidth = kBorderWidth;
        _borderPickerButton.layer.cornerRadius = kButtonBorderSize / 2;
    }
    return _borderPickerButton;
}

- (ButtonPicker *)pickerButton {
    if (!_pickerButton) {
        _pickerButton = [[ButtonPicker alloc] init];
        _pickerButton.delegate = self;
        [_pickerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _pickerButton;
}

#pragma mark - ButtonPickerDelegate delegate
- (void)buttonDidPress {
    if ([self.delegate respondsToSelector:@selector(pickerButtonDidPress)]) {
        [self.delegate pickerButtonDidPress];
    }
}

@end
