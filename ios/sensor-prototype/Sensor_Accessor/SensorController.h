//
//  SensorController.h
//  Sensor_Accessor
//
//  Created by Peter Zhao on 1/21/12.
//  Refactored by Andrew Huynh on 2/16/12.
//  Copyright (c) 2012 CALab. All rights reserved.
//  Testing

#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

#import "CoreLocationController.h"
#import "AccelerometerProcessor.h"
#import "SoundWaveProcessor.h"

@protocol SensorDelegate
    - (void) error:(NSString*) errorMessage;    // Handle error messages from sensors/connection
    - (NSArray*) calibrationTags;               // Handle any extra tags we want to send to API
    - (void) detectedTalking;                   // Handle detection of talking/conversation

    - (void) updateActivities:(NSArray*) activities;    // Handle an updated activities listing
    - (void) updatePlaylist:(NSArray *) playlist forActivity:(NSString*)activity;       // Handle an updated playlist listing
@end

@interface SensorController : NSObject <NSURLConnectionDelegate> {
    
    // Handles any errors/info that we want to make public.
    id<SensorDelegate> delegate;
    NSString *uuid;
    int time_interval;
    
    @private
    //--// Data to be sent to API server
    NSMutableDictionary *dataList;
    NSArray             *dataKeys;
    
    //--// Data received from API server
    NSMutableData   *raw_api_data;    
    
    //--// Data management
    NSTimer         *send_data_timer;           // Timer that handles sending data to server
    NSTimer         *collect_data_timer;        // Timer that handles collecting data
    NSURLConnection *api_connection;        // Connection to API server    

    //-// Sensor management
    AccelerometerProcessor *dataProcessor;  // Handles accelerometer sensors
    CoreLocationController *CLController;   // Handles GPS sensor
    SoundWaveProcessor     *soundProcessor; // Handles recording microphone data
    
    //-// HF Data Management
    
    NSURL               *HFFilePath;        //Path that will eventually hold HFDataBundle;
    NSTimer             *HFPackingTimer;    //Dictates manager calling at a set HF Frequency
    NSMutableArray      *HFDataBundle;      //Holds data over entire interval of HF Sampling, sends after full
    NSMutableDictionary *HFDataList;        //Similar to datalist, holds all instance of data and then gets put in HFDataBundle
    
}

@property (nonatomic, copy)     NSString *uuid;
@property (nonatomic, retain)   id<SensorDelegate> delegate;

+ (NSArray*) supportedActivities;

- (id) initWithUUID:(NSString*) deviceId andDelegate:(id<SensorDelegate>)delegate;

- (void) startHFSampling;
- (void) packHFData;

- (void) pauseSampling;
- (void) startSamplingWithInterval:(int)timeInterval;

//Other Handling Functionalities
//- (NSData*) compressData:(NSData*) uncompressedData;

@end