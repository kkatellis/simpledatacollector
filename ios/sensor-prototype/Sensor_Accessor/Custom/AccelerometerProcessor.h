//
//  AccelerometerProcessor.h
//  Sensor_Accessor
//
//  Created by Peter Zhao on 2/8/12.
//  Copyright (c) 2012 Calab. All rights reserved.


#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

@interface AccelerometerProcessor : NSObject {
    // Holds the average accelerometer values
    NSString *avgx, *avgy, *avgz;
    float accel[3]; // Used on iPhone 3GS and below
    
    // Holds the rotation rates
    NSString *avgRotationX, *avgRotationY, *avgRotationZ;
    
    // Hold the last n sensor samples
    NSMutableArray *axholder;
    NSMutableArray *ayholder;
    NSMutableArray *azholder;
    
    NSMutableArray *gxholder;
    NSMutableArray *gyholder;
    NSMutableArray *gzholder;
    
    // Handles collecting the data
    CMMotionManager *motionManager;
    NSTimer *deviceMotionTimer;
    
    //For HF Data Gathering
    BOOL isHFGathering;
    NSString *rawAx, *rawAy, *rawAz;
    NSString *rawRx, *rawRy, *rawRz;
}

//Background Data Sampling
@property (readonly) NSString *avgx;
@property (readonly) NSString *avgy;
@property (readonly) NSString *avgz;

@property (readonly) NSString *avgRotationX;
@property (readonly) NSString *avgRotationY;
@property (readonly) NSString *avgRotationZ;

//HF Data Sampling
@property (readonly) NSString *rawAx;
@property (readonly) NSString *rawAy;
@property (readonly) NSString *rawAz;

@property (readonly) NSString *rawRx;
@property (readonly) NSString *rawRy;
@property (readonly) NSString *rawRz;

- (double) avgAccels: (NSMutableArray *)data;
- (double) avgGyro: (NSMutableArray *)data;

- (void) turnOnHF;
- (void) turnOffHF;

- (void) start;
- (void) stop;

@end
