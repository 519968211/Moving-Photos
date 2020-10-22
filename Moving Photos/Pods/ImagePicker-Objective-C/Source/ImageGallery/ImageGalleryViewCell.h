//
//  ImageGalleryViewCell.h
//  ImagePickerDemo
//
//  Created by hanxt on 16/9/21.
//  Copyright © 2016年 hanxt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageGalleryViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *selectedImageView;

- (void)configureCell:(UIImage *)image;

@end
