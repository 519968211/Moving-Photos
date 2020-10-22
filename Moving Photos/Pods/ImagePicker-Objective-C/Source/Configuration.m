//
//  Configuration.m
//  ImagePickerDemo
//
//  Created by hanxt on 16/9/21.
//  Copyright © 2016年 hanxt. All rights reserved.
//

#import "Configuration.h"

@implementation Configuration

static Configuration *_instance;

+ (Configuration *)sharedConfiguration {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ \
        _instance = [[self alloc] init];
        [_instance initialize];
    });
    return _instance;
}

- (void)initialize {
   
    //颜色
    _instance.backgroundColor = [UIColor colorWithRed:0.15 green:0.19 blue:0.24 alpha:1.f];
    _instance.mainColor = [UIColor colorWithRed:0.09 green:0.11 blue:0.13 alpha:1.f];
    _instance.noImagesColor = [UIColor colorWithRed:0.86 green:0.86 blue:0.86 alpha:1.f];
    _instance.noCameraColor = [UIColor colorWithRed:0.86 green:0.86 blue:0.86 alpha:1.f];
    _instance.settingsColor = [UIColor whiteColor];

    //字体
    _instance.numberLabelFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:19.f];
    _instance.doneButton = [UIFont fontWithName:@"HelveticaNeue-Medium" size:19.f];
    _instance.flashButton = [UIFont fontWithName:@"HelveticaNeue-Medium" size:12.f];
    _instance.noImagesFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18.f];
    _instance.noCameraFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18.f];
    _instance.settingsFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.f];
    
    //标题
    _instance.OKButtonTitle = @"OK";
    _instance.cancelButtonTitle = @"Cancel";
    _instance.doneButtonTitle = @"Done";
    _instance.noImagesTitle = @"No images available";
    _instance.noCameraTitle = @"Camera is not available";
    _instance.settingsTitle = @"Settings";
    _instance.requestPermissionTitle = @"Permission denied";
    _instance.requestPermissionMessage = @"Please, allow the application to access to your photo library.";
    
    _instance.cellSpacing = 2.f;
    _instance.indicatorWidth = 41.f;
    _instance.indicatorHeight = 8.f;
    
    _instance.canRotateCamera = YES;
    _instance.collapseCollectionViewWhileShot = YES;
    _instance.recordLocation = YES;
    
    _instance.indicatorView = [[UIView alloc] initWithFrame:CGRectZero];
    _instance.indicatorView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    _instance.indicatorView.layer.cornerRadius = 4.f;
    _instance.indicatorView.translatesAutoresizingMaskIntoConstraints = NO;
}

+ (id)allocWithZone:(NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
        [_instance initialize];
    });
    return _instance; \
}

@end
