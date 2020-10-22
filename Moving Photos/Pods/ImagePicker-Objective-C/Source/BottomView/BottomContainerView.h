//
//  BottomContainerView.h
//  ImagePickerDemo
//
//  Created by hanxt on 16/9/21.
//  Copyright © 2016年 hanxt. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ButtonPicker;
@class ImageStackView;

UIKIT_EXTERN CGFloat const kBottomContainerViewHeight;

@protocol BottomContainerViewDelegate <NSObject>

- (void)pickerButtonDidPress;
- (void)doneButtonDidPress;
- (void)cancelButtonDidPress;
- (void)imageStackViewDidPress;

@end

@interface BottomContainerView : UIView

@property (nonatomic, weak) id<BottomContainerViewDelegate> delegate;

@property (nonatomic, strong) UIButton *doneButton;

@property (nonatomic, strong) ButtonPicker *pickerButton;

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic, strong) ImageStackView *stackView;

@end
