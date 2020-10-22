//
//  Configuration.h
//  ImagePickerDemo
//
//  Created by hanxt on 16/9/21.
//  Copyright © 2016年 hanxt. All rights reserved.
//

#import <UIKit/UIKit.h>

#define Config ([Configuration sharedConfiguration])

@interface Configuration : NSObject

+ (Configuration *)sharedConfiguration;

//颜色
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *mainColor;
@property (nonatomic, strong) UIColor *noImagesColor;
@property (nonatomic, strong) UIColor *noCameraColor;
@property (nonatomic, strong) UIColor *settingsColor;

//字体
@property (nonatomic, strong) UIFont *numberLabelFont;
@property (nonatomic, strong) UIFont *doneButton;
@property (nonatomic, strong) UIFont *flashButton;
@property (nonatomic, strong) UIFont *noImagesFont;
@property (nonatomic, strong) UIFont *noCameraFont;
@property (nonatomic, strong) UIFont *settingsFont;

//标题
@property (nonatomic, copy) NSString *OKButtonTitle;
@property (nonatomic, copy) NSString *cancelButtonTitle;
@property (nonatomic, copy) NSString *doneButtonTitle;
@property (nonatomic, copy) NSString *noImagesTitle;
@property (nonatomic, copy) NSString *noCameraTitle;
@property (nonatomic, copy) NSString *settingsTitle;
@property (nonatomic, copy) NSString *requestPermissionTitle;
@property (nonatomic, copy) NSString *requestPermissionMessage;

//
@property (nonatomic, assign) CGFloat cellSpacing;
@property (nonatomic, assign) CGFloat indicatorWidth;
@property (nonatomic, assign) CGFloat indicatorHeight;

//自定义
@property (nonatomic, assign) BOOL canRotateCamera;
@property (nonatomic, assign) BOOL collapseCollectionViewWhileShot;
@property (nonatomic, assign) BOOL recordLocation;

@property (nonatomic, strong) UIView *indicatorView;

@end
