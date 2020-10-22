//
//  ImagePickerController.h
//  ImagePickerDemo
//
//  Created by hanxt on 16/9/21.
//  Copyright © 2016年 hanxt. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ImagePickerController;
@class ImageGalleryView;

@protocol ImagePickerDelegate <NSObject>

- (void)wrapperDidPress:(ImagePickerController *)imagePicker
                 images:(NSArray<UIImage *> *)images;

- (void)doneButtonDidPress:(ImagePickerController *)imagePicker
                    images:(NSArray<UIImage *> *)images;

- (void)cancelButtonDidPress:(ImagePickerController *)imagePicker;

@end

@interface ImagePickerController : UIViewController

@property (nonatomic, weak) id<ImagePickerDelegate> delegate;

@end
