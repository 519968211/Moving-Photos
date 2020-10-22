//
//  LocationManager.m
//  ImagePickerDemo
//
//  Created by hanxt on 16/9/21.
//  Copyright © 2016年 hanxt. All rights reserved.
//

#import "LocationManager.h"
#import <CoreLocation/CoreLocation.h>

@interface LocationManager() <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@end


@implementation LocationManager

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager requestWhenInUseAuthorization];
}

- (void)startUpdatingLocation {
    [self.locationManager startUpdatingLocation];
}

- (void)stopUpdatingLocation {
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    self.latestLocation = [locations sortedArrayUsingComparator:^NSComparisonResult(CLLocation  *obj1, CLLocation  *obj2) {
        return obj1.horizontalAccuracy < obj2.horizontalAccuracy;
    }].firstObject;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager startUpdatingLocation];
    } else {
        [self.locationManager stopUpdatingLocation];
    }
}

@end
