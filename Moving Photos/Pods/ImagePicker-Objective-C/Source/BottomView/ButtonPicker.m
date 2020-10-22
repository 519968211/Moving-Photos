//
//  ButtonPicker.m
//  ImagePickerDemo
//
//  Created by hanxt on 16/9/21.
//  Copyright © 2016年 hanxt. All rights reserved.
//

#import "ButtonPicker.h"
#import "Configuration.h"
#import "ImageStack.h"

CGFloat const kBorderWidth = 2.f;
CGFloat const kButtonSize = 58.f;
CGFloat const kButtonBorderSize = 68.f;

@interface ButtonPicker()

@property (nonatomic, strong) UILabel *numberLabel;


@end


@implementation ButtonPicker

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%@ dealloc", [self class]);
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    [self addSubview:self.numberLabel];
    [self subscribe];
    [self setupButton];
    [self setupConstraints];
}

- (void)subscribe {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recalculatePhotosCount:) name:kNotificationImageDidPush object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recalculatePhotosCount:) name:kNotificationImageDidDrop object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recalculatePhotosCount:) name:kNotificationStackDidReload object:nil];
}

- (void)setupButton {
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = kButtonSize / 2;
    self.accessibilityLabel = @"拍照";
    [self addTarget:self action:@selector(pickerButtonDidPress:) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(pickerButtonDidHighlight:) forControlEvents:UIControlEventTouchDown];
}

- (void)setupConstraints {
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.numberLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.numberLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
}

#pragma mark - private
- (void)recalculatePhotosCount:(NSNotification *)notification {
    ImageStack *sender = (ImageStack *)notification.object;
    if (!sender) {
        return;
    }
    self.numberLabel.text = sender.assets.count ? [NSString stringWithFormat:@"%lu", (unsigned long)sender.assets.count] : @"";
}

- (void)pickerButtonDidPress:(UIButton *)button {
    self.backgroundColor = [UIColor whiteColor];
    self.numberLabel.textColor = [UIColor blueColor];
    [self.numberLabel sizeToFit];
    if ([self.delegate respondsToSelector:@selector(buttonDidPress)]) {
        [self.delegate buttonDidPress];
    }
}

- (void)pickerButtonDidHighlight:(UIButton *)button {
    self.numberLabel.textColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1];
}

#pragma mark - lazy load
- (UILabel *)numberLabel {
    if (!_numberLabel) {
        _numberLabel = [[UILabel alloc] init];
        _numberLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _numberLabel.font = Config.numberLabelFont;
    }
    return _numberLabel;
}

@end
