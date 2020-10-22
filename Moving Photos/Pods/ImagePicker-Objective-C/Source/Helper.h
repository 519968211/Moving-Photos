//
//  Helper.h
//  ImagePickerDemo
//
//  Created by hanxt on 16/9/21.
//  Copyright © 2016年 hanxt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface Helper : NSObject

+ (CGAffineTransform)rotationTransform;
+ (AVCaptureVideoOrientation)videoOrientation;
@end
