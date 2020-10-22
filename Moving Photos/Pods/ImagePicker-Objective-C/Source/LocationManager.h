//
//  LocationManager.h
//  ImagePickerDemo
//
//  Created by hanxt on 16/9/21.
//  Copyright © 2016年 hanxt. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CLLocation;

@interface LocationManager : NSObject

@property (nonatomic, strong) CLLocation *latestLocation;

- (void)startUpdatingLocation;

- (void)stopUpdatingLocation;

@end
