//
//  CameraMan.m
//  ImagePickerDemo
//
//  Created by hanxt on 16/9/21.
//  Copyright © 2016年 hanxt. All rights reserved.
//

#import "CameraMan.h"
#import <CoreLocation/CoreLocation.h>
#import "Helper.h"
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface CameraMan()

@property (nonatomic, strong) dispatch_queue_t queue;

@property (nonatomic, strong) AVCaptureDeviceInput *backCamera;

@property (nonatomic, strong) AVCaptureDeviceInput *frontCamera;

@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;

@property (nonatomic, strong) AVCaptureDeviceInput *currentInput;


@end


@implementation CameraMan

- (void)dealloc {
    [self stop];
    NSLog(@"%@ dealloc", [self class]);
}

- (void)setup {
    [self checkPermission];
}

- (void)setupDevices {
    
    // Input
    for (AVCaptureDevice *device in [AVCaptureDevice devices]) {
        if ([device hasMediaType:AVMediaTypeVideo]) {
            switch (device.position) {
                case AVCaptureDevicePositionFront:
                    self.frontCamera = [[AVCaptureDeviceInput alloc] initWithDevice:device error:NULL];
                    break;
                case AVCaptureDevicePositionBack:
                    self.backCamera = [[AVCaptureDeviceInput alloc] initWithDevice:device error:NULL];
                    break;
                default:
                    break;
            }
        }
    }
    
    // Output
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    self.stillImageOutput.outputSettings = @{AVVideoCodecKey: AVVideoCodecJPEG};
}

- (void)addInput:(AVCaptureDeviceInput *)input {
    [self configurePreset:input];
    
    if ([self.session canAddInput:input]) {
        [self.session addInput:input];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(cameraMan:didChangeInput:)]) {
                [self.delegate cameraMan:self didChangeInput:input];
            }
        });
    }
}

#pragma mark - Permission
- (void)checkPermission {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    switch (status) {
        case AVAuthorizationStatusAuthorized:
            [self start];
            break;
        case AVAuthorizationStatusNotDetermined:
            [self requestPermission];
            break;
        default:
            if ([self.delegate respondsToSelector:@selector(cameraManNotAvailable:)]) {
                [self.delegate cameraManNotAvailable:self];
            }
            break;
    }
}

- (void)requestPermission {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                [self start];
            } else {
                if ([self.delegate respondsToSelector:@selector(cameraManNotAvailable:)]) {
                    [self.delegate cameraManNotAvailable:self];
                }
            }
        });
    }];
}

#pragma mark - Session
- (AVCaptureDeviceInput *)currentInput {
    return (AVCaptureDeviceInput *)self.session.inputs.firstObject;
}

- (void)start {
    // Devices
    [self setupDevices];
    
    AVCaptureDeviceInput *input = self.backCamera;
    AVCaptureStillImageOutput *output = self.stillImageOutput;
    if (!input || !output) {
        return;
    }
    
    [self addInput:input];
    
    if ([self.session canAddOutput:output]) {
        [self.session addOutput:output];
    }
    
    dispatch_async(self.queue, ^{
        [self.session startRunning];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(cameraManDidStart:)]) {
                [self.delegate cameraManDidStart:self];
            }
        });
    });
}

- (void)stop {
    [self.session stopRunning];
}

- (void)switchCameraWithCompletion:(void (^)(void))completion {
    if (!self.currentInput) {
        completion();
        return;
    }
    dispatch_async(self.queue, ^{
        AVCaptureDeviceInput *input = nil;
        if (self.currentInput == self.backCamera) {
            input = self.frontCamera;
        } else {
            input = self.backCamera;
        }
        if (!input) {
            completion();
            return;
        }
        
        [self configure:^{
            [self.session removeInput:self.currentInput];
            [self.session addInput:input];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
    });
    
};

- (void)takePhoto:(AVCaptureVideoPreviewLayer *)previewLayer location:(CLLocation *)location completion:(void (^)(void))completion {
    AVCaptureConnection *connection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!connection) {
        return;
    }
    
    connection.videoOrientation = [Helper videoOrientation];
    
    dispatch_async(self.queue, ^{
        [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            UIImage *image = nil;
            if (!error && imageDataSampleBuffer && CMSampleBufferIsValid(imageDataSampleBuffer)) {
                NSData *data = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                image = [UIImage imageWithData:data];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion();
                });
                return;
            }
            
            [self savePhoto:image location:location completion:completion];
        }];
    });
}

- (void)savePhoto:(UIImage *)image location:(CLLocation *)location completion:(void (^)(void))completion {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        request.creationDate = [NSDate date];
        request.location = location;
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
    }];
}

- (void)flash:(AVCaptureFlashMode)mode {
    AVCaptureDevice *device = self.currentInput.device;
    if (![device isFlashModeSupported:mode]) {
        return;
    }
    dispatch_async(self.queue, ^{
        [self lock:^{
            device.flashMode = mode;
        }];
    });
}

- (void)focus:(CGPoint)point {
    AVCaptureDevice *device = self.currentInput.device;
    if (![device isFocusModeSupported:AVCaptureFocusModeLocked]) {
        return;
    }
    
    dispatch_async(self.queue, ^{
        [self lock:^{
            device.focusPointOfInterest = point;
        }];
    });
}

#pragma mark - lock
- (void)lock:(void (^)(void))block {
    AVCaptureDevice *device = self.currentInput.device;
    if ([device lockForConfiguration:NULL]) {
        block();
        [device unlockForConfiguration];
    }
}

#pragma mark - Configure
- (void)configure:(void (^)(void))block {
    [self.session beginConfiguration];
    block();
    [self.session commitConfiguration];
}

#pragma mark - preset
- (void)configurePreset:(AVCaptureDeviceInput *)input {
    for (NSString *asset in @[AVCaptureSessionPresetHigh, AVCaptureSessionPresetMedium, AVCaptureSessionPresetLow]) {
        if ([input.device supportsAVCaptureSessionPreset:asset] && [self.session canSetSessionPreset:asset]) {
            self.session.sessionPreset = asset;
            return;
        }
    }
}

- (dispatch_queue_t)queue {
    if (!_queue) {
        _queue = dispatch_queue_create("no.hyper.ImagePicker.Camera.SessionQueue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0));
    }
    return _queue;
}

- (AVCaptureSession *)session {
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
    }
    return _session;
}
@end
