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
#import <UIKit/UIKit.h>

#import "AccelerometerProcessor.h"
#import "CoreLocationController.h"
#import "DataUploader.h"
#import "Reachability.h"
#import "SoundWaveProcessor.h"
#import "ZipFile.h"

@protocol SensorDelegate
    - (void) error:(NSString*) errorMessage;    // Handle error messages from sensors/connection
    - (NSArray*) calibrationTags;               // Handle any extra tags we want to send to API
    - (void) detectedTalking;                   // Handle detection of talking/conversation

    - (void) updateActivities:(NSArray*) activities;    // Handle an updated activities listing
    - (void) updatePlaylist:(NSArray *) playlist forActivity:(NSString*)activity;       // Handle an updated playlist listing
@end

@interface SensorController : NSObject <NSURLConnectionDelegate, DataUploaderDelegate> {
    
    //--// Monitors WiFi availability
    Reachability *reachability;
    
    // Handles any errors/info that we want to make public.
    id<SensorDelegate> delegate;
    NSString *uuid;
    
    @private
    //--// Data to be sent to API server
    NSMutableDictionary *dataList;
    NSArray             *dataKeys;
    
    //--// Data received from API server
    NSMutableData   *raw_api_data;    
    
    //--// Passive Data management
    NSTimer         *send_data_timer;           // Timer that handles sending data to server
    NSTimer         *collect_data_timer;        // Timer that handles collecting data
    NSURLConnection *api_connection;        // Connection to API server    

    //-// Sensor management
    AccelerometerProcessor *dataProcessor;  // Handles accelerometer sensors
    CoreLocationController *CLController;   // Handles GPS sensor
    SoundWaveProcessor     *soundProcessor; // Handles recording microphone data
    
    //-// HF Data Management
    DataUploader        *myUploader;        // Class wide instance of dataUploader, allowing wifi-checking/queue management etc.
    BOOL                isHalfSample;       // Only collect half of the HF samples ( active user feedback case ).
    BOOL                isCapacityFull;     // True if no more room for HF data packets
    NSString            *HFFilePath;        // Path that will eventually hold HFDataBundle;
    NSTimer             *HFPackingTimer;    // Dictates manager calling at a set HF Frequency
    NSTimer             *alertNoSpaceTimer; // Timer that repeatedly creates alerts when no wifi/space is available
    NSMutableArray      *HFDataBundle;      // Holds data over entire interval of HF Sampling, sends after full
    
    
}

@property (nonatomic, copy)     NSString *uuid;
@property (nonatomic, retain)   id<SensorDelegate> delegate;
@property (nonatomic)           BOOL isCapacityFull;

- (float)   getFreeDiskSpace;

- (id) initWithUUID:(NSString*) deviceId andDelegate:(id<SensorDelegate>)delegate;

//--// HF Data gathering stages
- (void) startHFPreSample;
- (void) startHFFeedbackSample;
- (void) startHFPostSample;
- (void) endHFSample;

- (void) packHFData;

- (void) pauseSampling;
- (void) startSamplingWithInterval;

- (void) alertNotEnoughSpace;
- (void) compressAndSend;

- (void) sendFeedback: (NSDictionary*) feedback withPredictedActivity: (NSString*) activity;

@end
