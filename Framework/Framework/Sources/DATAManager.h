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
- (void)locatedOn:(double)latitude andOn:(double)longtitude;
- (void)acceleratedOn:(double)a andOn:(double)y andOn:(double)z;
- (void)received:(NSData *) data;

@optional
- (void)gotError:(NSString *)description;

@end


@interface DATAManager : NSObject {
    
}

@property (weak) id<DATAManagerDelegate> delegate;

+ (id)sharedInstance;
- (void)start;
- (void)stop;
- (void)executeiTunesSearchWith:(NSString *)term;

@end

NS_ASSUME_NONNULL_END
