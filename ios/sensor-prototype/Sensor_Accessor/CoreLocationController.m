//
//  CoreLocationController.m
//  Sensor_Accessor
//
//  Created by Peter Zhao on 1/21/12.
//  Copyright (c) 2012 CALab. All rights reserved.
//

#import "CoreLocationController.h"

@implementation CoreLocationController

@synthesize currentLocation, previousLocation;

- (id)init{
    self = [super init];
    
	if(self != nil) {
        currentLocation = nil;
        locManager = [[CLLocationManager alloc] init];
	}
    
	return self;
}

- (void) start {
    [locManager startUpdatingLocation];
}

- (void) stop {
    [locManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self setPreviousLocation: self.currentLocation];
    [self setCurrentLocation: newLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog( @"[CoreLocationController] ERROR: %@", [error localizedDescription] );
}

@end
