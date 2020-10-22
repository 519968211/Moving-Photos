//
//  ImageGalleryLayout.m
//  ImagePickerDemo
//
//  Created by hanxt on 16/9/21.
//  Copyright © 2016年 hanxt. All rights reserved.
//

#import "ImageGalleryLayout.h"
#import "Helper.h"

@implementation ImageGalleryLayout

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
    
    if (attributes) {
        for (UICollectionViewLayoutAttributes *attribute in attributes) {
            attribute.transform = [Helper rotationTransform];
        }
    }
    
    return attributes;
}

@end
