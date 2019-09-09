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
      locationManager.pausesLocationUpdatesAutomatically = NO;
      locationManager.activityType = CLActivityTypeFitness;
      motionManager = [[CMMotionManager alloc] init];
      managerQueue = [[NSOperationQueue alloc] init];
      [managerQueue setQualityOfService:NSQualityOfServiceBackground];
  }
  return self;
}

- (void)start {
    CLAuthorizationStatus locationManagerStatus = [CLLocationManager authorizationStatus];
    if (locationManagerStatus == kCLAuthorizationStatusNotDetermined) {
        [locationManager requestWhenInUseAuthorization];
    } else {
        [locationManager startUpdatingLocation];
    }

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
        [self delegateError:@"I need authorization to use the GPS!!!"];
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
        unsigned long last = locations.count - 1;
        CLLocation* latest = locations[last];
        [self executeWeatherSearchWithLat:latest.coordinate.latitude andWithLong:latest.coordinate.longitude];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate locatedOnLat:latest.coordinate.latitude andLong:latest.coordinate.longitude];
        });
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self delegateError:error.localizedDescription];
}

- (void)executeWeatherSearchWithLat:(double)latitude andWithLong:(double)longitude {
    NSString *urlString = [NSString stringWithFormat:@"https://api.openweathermap.org/data/2.5/forecast?appid=5d5fb2abfc152ac8380b7c62c2b0e8cd&units=imperial&lat=%lf&lon=%lf",latitude,longitude];
    NSURL *url = [[NSURL alloc] initWithString:urlString];

    if (url != NULL) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"Get";
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

        [managerQueue addOperationWithBlock:^{
            NSURLSessionDataTask *task = [[NSURLSession sharedSession]
                                          dataTaskWithRequest:request
                                          completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                              if ((error != nil) && (response != nil)){
                                                  [self delegateError:error.localizedDescription];
                                              } else {
                                                  if ((response != nil) && (data != nil)){
                                                      [self.delegate received:data];
                                                  }
                                              }
                                          }];
            [task resume];
        }];
    }
}
@end
