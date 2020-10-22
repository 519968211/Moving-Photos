//
//  Helper.m
//  ImagePickerDemo
//
//  Created by hanxt on 16/9/21.
//  Copyright © 2016年 hanxt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Helper.h"

@implementation Helper

+ (CGAffineTransform)rotationTransform {
    switch ([[UIDevice currentDevice] orientation]) {
        case UIDeviceOrientationLandscapeLeft:
            return CGAffineTransformMakeRotation(M_PI_2);
            break;
        case UIDeviceOrientationLandscapeRight:
            return CGAffineTransformMakeRotation(-M_PI_2);
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            return CGAffineTransformMakeRotation(M_PI);
            break;
        default:
            return CGAffineTransformIdentity;
    }
}

+ (AVCaptureVideoOrientation)videoOrientation {
    switch ([[UIDevice currentDevice] orientation]) {
        case UIDeviceOrientationPortrait:
            return AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationLandscapeLeft:
            return AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            return AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            return AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            return AVCaptureVideoOrientationPortrait;
            break;
    }
}

@end
