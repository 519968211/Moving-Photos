//
//  CameraMan.h
//  ImagePickerDemo
//
//  Created by hanxt on 16/9/21.
//  Copyright © 2016年 hanxt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@class CameraMan;
@class CLLocation;

@protocol CameraManDelegate <NSObject>

- (void)cameraManNotAvailable:(CameraMan *)cameraMan;
- (void)cameraManDidStart:(CameraMan *)cameraMan;
- (void)cameraMan:(CameraMan *)cameraMan didChangeInput:(AVCaptureDeviceInput *)input;

@end

@interface CameraMan : NSObject

@property (nonatomic, weak) id<CameraManDelegate> delegate;

@property (nonatomic, strong) AVCaptureSession *session;

- (void)setup;

- (void)switchCameraWithCompletion:(void (^)(void))completion;

- (void)flash:(AVCaptureFlashMode)mode;

- (void)focus:(CGPoint)point;

- (void)takePhoto:(AVCaptureVideoPreviewLayer *)previewLayer location:(CLLocation *)location completion:(void (^)(void))completion;
@end
