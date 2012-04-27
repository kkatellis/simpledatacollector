//
//  AccelerometerProcessor.m
//  Sensor_Accessor
//
//  Created by Peter Zhao on 2/8/12.
//  Copyright (c) 2012 Calab. All rights reserved.
//


#import "AccelerometerProcessor.h"
#import <stdio.h>
#import <math.h>

#define NUM_SAMPLES 11
#define HF_NUM_SAMPLES 950
#define SAMPLING_RATE 2 // In Hertz
#define HF_SAMPLING_RATE 40 //In Hertz

//--// Used to isolate the user accleration on iPhone 3GS and below.
#define filteringFactor 0.1

@implementation AccelerometerProcessor

@synthesize avgx, avgy, avgz;
@synthesize avgRotationX, avgRotationY, avgRotationZ;

@synthesize rawAx, rawAy, rawAz;
@synthesize rawRx, rawRy, rawRz;

-(id)init {
    self = [super init];
    
    if( self != nil ) {
        //Variable initialization
        rawAx = @"0.0";
        rawAy = @"0.0";
        rawAz = @"0.0";
        
        rawRx = @"0.0";
        rawRy = @"0.0";
        rawRz = @"0.0";
        
        avgx = @"0.0";
        avgy = @"0.0";
        avgz = @"0.0";
        
        avgRotationX = @"0.0";
        avgRotationY = @"0.0";
        avgRotationZ = @"0.0";
        
        accel[0] = 0;
        accel[1] = 0;
        accel[2] = 0;
        
        axholder = [[NSMutableArray alloc]init];
        ayholder = [[NSMutableArray alloc]init];
        azholder = [[NSMutableArray alloc]init];
        
        gxholder = [[NSMutableArray alloc]init];
        gyholder = [[NSMutableArray alloc]init];
        gzholder = [[NSMutableArray alloc]init];
        
        
        
        // Start collecting data
        motionManager = [[CMMotionManager alloc] init];
        isHFGathering = FALSE;
        [self start];
        
    }
    
	return self;
}


//Collect data ONCE, should be called with timer/iterative method
- (void) startDeviceMotion{
    
    NSNumber *x, *y, *z;
    NSNumber *gx, *gy, *gz;
    
    //Averaging Accelerometer Data
    // iPhone 4 and up
    if( motionManager.deviceMotionAvailable ) {
        x = [NSNumber numberWithDouble: motionManager.deviceMotion.userAcceleration.x];
        y = [NSNumber numberWithDouble: motionManager.deviceMotion.userAcceleration.y];
        z = [NSNumber numberWithDouble: motionManager.deviceMotion.userAcceleration.z];
    
    // iPhone 3GS and below
    } else {
        // Method used from to extract user acceleration from iPhone 3GS and below:
        // https://developer.apple.com/library/ios/#documentation/EventHandling/Conceptual/EventHandlingiPhoneOS/MotionEvents/MotionEvents.html
        
        CMAcceleration acceleration = motionManager.accelerometerData.acceleration;

        // Subtract the low-pass value from the current value to get a simplified high-pass filter
        accel[0] = acceleration.x - ( (acceleration.x * filteringFactor) + (accel[0] * (1.0 - filteringFactor)) );
        accel[1] = acceleration.y - ( (acceleration.y * filteringFactor) + (accel[1] * (1.0 - filteringFactor)) );
        accel[2] = acceleration.z - ( (acceleration.z * filteringFactor) + (accel[2] * (1.0 - filteringFactor)) );

        x = [NSNumber numberWithDouble: acceleration.x - accel[0] ];
        y = [NSNumber numberWithDouble: acceleration.y - accel[1] ];
        z = [NSNumber numberWithDouble: acceleration.z - accel[2] ];    
        
    }
    
    if( [axholder count] < NUM_SAMPLES ) {
        [axholder addObject:x];
        [ayholder addObject:y];
        [azholder addObject:z];
    }
    else {
        avgx = [NSString stringWithFormat:@"%f", [self avgAccels:axholder]];
        avgy = [NSString stringWithFormat:@"%f", [self avgAccels:ayholder]];
        avgz = [NSString stringWithFormat:@"%f", [self avgAccels:azholder]];
                
        [axholder removeAllObjects];
        [ayholder removeAllObjects];
        [azholder removeAllObjects];
    }
    
    //Average Gyroscope Data
    gx = [NSNumber numberWithDouble: motionManager.deviceMotion.rotationRate.x];
    gy = [NSNumber numberWithDouble: motionManager.deviceMotion.rotationRate.y];
    gz = [NSNumber numberWithDouble: motionManager.deviceMotion.rotationRate.z];
    
    if( [gxholder count] < NUM_SAMPLES ) {
        [gxholder addObject:gx];
        [gyholder addObject:gy];
        [gzholder addObject:gz];
    }
    else {
        avgRotationX = [NSString stringWithFormat:@"%f", [self avgGyro:gxholder]];
        avgRotationY = [NSString stringWithFormat:@"%f", [self avgGyro:gyholder]];
        avgRotationZ = [NSString stringWithFormat:@"%f", [self avgGyro:gzholder]];        
        
        [gxholder removeAllObjects];
        [gyholder removeAllObjects];
        [gzholder removeAllObjects];
    }
    
    rawAx = [x stringValue];
    rawAy = [y stringValue];
    rawAz = [z stringValue];
    
    rawRx = [gx stringValue];
    rawRy = [gy stringValue];
    rawRz = [gz stringValue];
}


//Set actual sensor getter frequency, should only be called once
- (void) start {    
    // iPhone 4 and up
    if( motionManager.deviceMotionAvailable && !isHFGathering ) {
        
        [motionManager setDeviceMotionUpdateInterval: 1.0 / SAMPLING_RATE];
        [motionManager startDeviceMotionUpdates];
    
    // iPhone 3GS and below
    } else if( motionManager.accelerometerAvailable && !isHFGathering ) {
        
        [motionManager setAccelerometerUpdateInterval: 1.0 / SAMPLING_RATE];
        [motionManager startAccelerometerUpdates];
        
    }
    
    deviceMotionTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(startDeviceMotion) userInfo:nil repeats:YES];           
}

- (void) stop {
    
    // Turn off updates
    if( motionManager.isDeviceMotionActive && !isHFGathering ) {
        [motionManager stopDeviceMotionUpdates];
    }
    
    if( motionManager.isAccelerometerActive && !isHFGathering ) {
        [motionManager stopAccelerometerUpdates];
    }
    
    // Invalidate timer
    [deviceMotionTimer invalidate];
    deviceMotionTimer = nil;
}

-(double) avgAccels:(NSMutableArray *)data {
    double result = 0;
    
    for( int counter = 0; counter < [data count]; counter++) {
        result += fabs( [[data objectAtIndex:counter] doubleValue] );
    }
    return ( result / [data count] );
}

-(double) avgGyro:(NSMutableArray *)data {
    double result = 0;
    
    for( int counter = 0; counter < [data count]; counter++) {
        result += fabs( [[data objectAtIndex:counter] doubleValue] );
    }
    return ( result / [data count] );
}
                                                        

//Change the rate in which data is being gathered.
- (void) turnOnHF {
    
    isHFGathering = TRUE;
    
    if( motionManager.deviceMotionAvailable ) {
        
        [motionManager setDeviceMotionUpdateInterval: 1.0 / HF_SAMPLING_RATE];
        
        // iPhone 3GS and below
    } else if( motionManager.accelerometerAvailable ) {
        
        [motionManager setAccelerometerUpdateInterval: 1.0 / HF_SAMPLING_RATE];
        
    }
}

- (void) turnOffHF {
    
    isHFGathering = FALSE;
    
    if( motionManager.deviceMotionAvailable ) {
        
        [motionManager setDeviceMotionUpdateInterval: 1.0 / SAMPLING_RATE];
        
    } else if( motionManager.accelerometerAvailable ) {
        
        [motionManager setAccelerometerUpdateInterval: 1.0 / SAMPLING_RATE];
        
    }
}
@end
