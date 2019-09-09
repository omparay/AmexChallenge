//
//  DATAManager.h
//  Framework
//
//  Created by Oliver Paray on 9/8/19.
//  Copyright © 2019 Oliver Paray. All rights reserved.
//

#import <CoreLocation/Corelocation.h>
#import <CoreMotion/CoreMotion.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DATAManagerDelegate <NSObject>

@required
- (void)locatedOnLat:(double)latitude andLong:(double)longitude;
- (void)acceleratedOnX:(double)x andOnY:(double)y andOnZ:(double)z;
- (void)received:(NSData *) data;

@optional
- (void)gotError:(NSString *)description;

@end


@interface DATAManager : NSObject {
    
}

@property (weak) id<DATAManagerDelegate> delegate;

+ (instancetype)sharedInstance;
- (void)start;
- (void)stop;
- (void)executeWeatherSearchWith:(double)latitude andWith:(double)longitude;

@end

NS_ASSUME_NONNULL_END
