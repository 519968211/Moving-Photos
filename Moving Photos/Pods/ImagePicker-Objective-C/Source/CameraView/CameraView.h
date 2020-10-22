//
//  CameraView.h
//  ImagePickerDemo
//
//  Created by hanxt on 16/9/21.
//  Copyright © 2016年 hanxt. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CameraViewDelegate <NSObject>

- (void)setFlashButtonHidden:(BOOL)hidden;
- (void)imageToLibrary;
- (void)cameraNotAvailable;

@end

@interface CameraView : UIViewController

@property (nonatomic, weak) id<CameraViewDelegate> delegate;

- (void)takePicture:(void (^)(void))completion;

- (void)flashCamera:(NSString *)title;

- (void)rotateCamera;

@end
