//
//  ButtonPicker.h
//  ImagePickerDemo
//
//  Created by hanxt on 16/9/21.
//  Copyright © 2016年 hanxt. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN CGFloat const kBorderWidth;
UIKIT_EXTERN CGFloat const kButtonSize;
UIKIT_EXTERN CGFloat const kButtonBorderSize;

@protocol ButtonPickerDelegate <NSObject>

- (void)buttonDidPress;

@end

@interface ButtonPicker : UIButton

@property (nonatomic, weak) id<ButtonPickerDelegate> delegate;

@end
