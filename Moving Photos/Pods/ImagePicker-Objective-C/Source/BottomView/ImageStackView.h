//
//  ImageStackView.h
//  ImagePickerDemo
//
//  Created by hanxt on 16/9/21.
//  Copyright © 2016年 hanxt. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN CGFloat const kImageSize;

@protocol ImageStackViewDelegate <NSObject>

- (void)imageStackViewDidPress;

@end

@interface ImageStackView : UIView

@property (nonatomic, weak) id<ImageStackViewDelegate> delegate;

- (void)startLoader;

@end
