//
//  TopView.h
//  ImagePickerDemo
//
//  Created by hanxt on 16/9/22.
//  Copyright © 2016年 hanxt. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN CGFloat const kTopViewHeight;

@protocol TopViewDelegate <NSObject>

- (void)flashButtonDidPress:(NSString *)title;
- (void)rotateDeviceDidPress;

@end

@interface TopView : UIView

@property (nonatomic, weak) id<TopViewDelegate> delegate;

@property (nonatomic, strong) UIButton *flashButton;

@property (nonatomic, strong) UIButton *rotateCamera;

@end
