//
//  CoreLocationController.h
//  Sensor_Accessor
//
//  Created by Peter Zhao on 1/21/12.
//  Copyright (c) 2012 CALab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface CoreLocationController : NSObject <CLLocationManagerDelegate> {
    CLLocationManager *locManager;

    CLLocation *currentLocation;
}

@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic, retain) CLLocation *previousLocation;

- (void) start;
- (void) stop;

@end
