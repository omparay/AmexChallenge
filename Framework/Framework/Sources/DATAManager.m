//
//  DATAManager.m
//  Framework
//
//  Created by Oliver Paray on 9/8/19.
//  Copyright © 2019 Oliver Paray. All rights reserved.
//

#import "DATAManager.h"

@interface DATAManager ()  <CLLocationManagerDelegate> {
    CLLocationManager* locationManager;
    CMMotionManager* motionManager;
    NSOperationQueue* managerQueue;
}

@end

@implementation DATAManager

+ (instancetype)sharedInstance {
    static DATAManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (instancetype)init {
  if (self = [super init]) {
      locationManager = [[CLLocationManager alloc] init];
      locationManager.delegate = self;
      locationManager.pausesLocationUpdatesAutomatically = YES;
      locationManager.activityType = CLActivityTypeFitness;
      motionManager = [[CMMotionManager alloc] init];
      managerQueue = [[NSOperationQueue alloc] init];
      [managerQueue setQualityOfService:NSQualityOfServiceBackground];
  }
  return self;
}

- (void)start {
    [locationManager requestWhenInUseAuthorization];
    [motionManager startAccelerometerUpdatesToQueue:managerQueue withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
        if (error != NULL) {
            [self delegateError:error.localizedDescription];
        }
        if ((self.delegate != NULL) && ([self.delegate respondsToSelector:@selector(acceleratedOnX:andOnY:andOnZ:)])) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate
                 acceleratedOnX:accelerometerData.acceleration.x
                 andOnY:accelerometerData.acceleration.y
                 andOnZ:accelerometerData.acceleration.z];
            });
        }
    }];
}

- (void)stop {
    [locationManager stopUpdatingLocation];
    [motionManager stopAccelerometerUpdates];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    CLAuthorizationStatus locationManagerStatus = [CLLocationManager authorizationStatus];
    if (locationManagerStatus != kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.delegate gotError:@"I need authorization to use GPS!!!"];
    } else {
        [locationManager startUpdatingLocation];
    }
}

- (void)delegateError:(NSString *)description {
    if ((self.delegate != NULL) && ([self.delegate respondsToSelector:@selector(gotError:)])) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate gotError:description];
        });
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if ((self.delegate != NULL) && ([self.delegate respondsToSelector:@selector(locatedOnLat:andLong:)])) {
        dispatch_async(dispatch_get_main_queue(), ^{
            unsigned long last = locations.count - 1;
            CLLocation* latest = locations[last];
            [self.delegate locatedOnLat:latest.coordinate.latitude andLong:latest.coordinate.longitude];
        });
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self delegateError:error.localizedDescription];
}

- (void)executeWeatherSearchWith:(double)latitude andWith:(double)longitude {
    
}

@end
