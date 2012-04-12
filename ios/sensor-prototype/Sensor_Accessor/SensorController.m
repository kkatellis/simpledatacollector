//
//  SensorController.m
//  Sensor_Accessor
//
//  Created by Peter Zhao on 1/21/12.
//  Refactored by Andrew Huynh on 2/16/12.
//  Copyright (c) 2012 CALab. All rights reserved.
//

#import "SensorController.h"

// In seconds
#define SAMPLING_RANGE      5.0
// In Hertz
#define HF_SAMPLING_RATE    40
// Number of data points collected over ~40Hz * 25 sec
#define HF_NUM_SAMPLES_MORE 950
#define HF_NUM_SAMPLES_LESS 450


//--// API URLs
#define API_URL         @"http://7c-c3-a1-72-3d-e7.dynamic.ucsd.edu/rmw/api/analyze?%@"
#define DEBUG_API_URL   @"http://localhost:5000/api/analyze?%@"

//--// API data keys
#define LAT             @"lat"
#define LNG             @"long"
#define SPEED           @"speed"
#define TIMESTAMP       @"timestamp"

#define PREV_LAT        @"prev_lat"
#define PREV_LNG        @"prev_long"
#define PREV_SPEED      @"prev_speed"
#define PREV_TIMESTAMP  @"prev_timestamp"

#define ACC_X           @"acc_x"
#define ACC_Y           @"acc_y"
#define ACC_Z           @"acc_z"

#define GYR_X           @"gyro_x"
#define GYR_Y           @"gyro_y"
#define GYR_Z           @"gyro_z"

#define MIC_AVG         @"mic_avg_db"
#define MIC_PEAK        @"mic_peak_db"

static NSArray *supportedActivities = nil;

@implementation SensorController

@synthesize uuid, delegate;

//--// Returns a list of supported activities
+ (NSArray*) supportedActivities {
    
    if( supportedActivities == nil ) {
        supportedActivities = [[NSArray alloc] initWithObjects:@"biking", @"driving", @"exercising", @"housework",
                                                                @"party", @"running", @"sitting", @"talking", @"walking",
                                                                nil];
    }
    
    return supportedActivities;
}

#pragma mark - View lifecycle

- (id)initWithUUID:(NSString*) deviceId andDelegate:(id<SensorDelegate>) sensorDelegate {
    self = [super init];

    if( self != nil ) {
        // Set up device id / delegate
        [self setUuid: deviceId];
        [self setDelegate: sensorDelegate];
                
        //--// Default assuming user doesn't have active feedback
        isUserAsking = FALSE;
        
        //--// Set up data list
        dataList = [[NSMutableDictionary alloc] init];
        HFDataList = [[NSMutableDictionary alloc] init];
        dataKeys = [[NSArray alloc] initWithObjects: LAT, LNG, SPEED, TIMESTAMP,
                                                        PREV_LAT, PREV_LNG, PREV_SPEED, PREV_TIMESTAMP, 
                                                        ACC_X, ACC_Y, ACC_Z, 
                                                        GYR_X, GYR_Y, GYR_Z, MIC_AVG, MIC_PEAK, nil];
        
        // Initialize data list to default values
        for ( NSString* key in dataKeys ) {
            [dataList setObject:@"0.0" forKey: key];
        }            
    }
    
    return self;
}

- (void) continueSampling {
    NSLog( @"[SensorController] Continued Sampling" );
    // Stop recording sensor data
    [soundProcessor startRecording];    // Microphone
    [dataProcessor start];              // Accelerometer
    
    // Stop sampling after the sampling range
    [NSTimer scheduledTimerWithTimeInterval:SAMPLING_RANGE target:self selector:@selector(finishSampling) userInfo:nil repeats:NO];            
}

- (void) finishSampling {
    NSLog( @"[SensorController] Finished Sampling" );
    // Stop recording sensor data
    [soundProcessor endRecording];  // Microphone
    [dataProcessor stop];           // Accelerometer
}

- (void) startSamplingWithInterval:(int)timeInterval {
    
    // Check if we're already sending data. No need to start again if we're already started.
    if( [send_data_timer isValid] ) {
        return;
    }
    
    time_interval = timeInterval;
    
    //--// Sensor Collection Class Initializations
    send_data_timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(sendData) userInfo:nil repeats:YES];
    
    // Start collecting MICROPHONE data
    soundProcessor = [[SoundWaveProcessor alloc]init];
    
    // Start collecting ACCELEROMETER data
    dataProcessor = [[AccelerometerProcessor alloc] init];
    [dataProcessor start];
    
    // Start collecting GYROSCOPE data
    CLController = [[CoreLocationController alloc] init];    
    [CLController start];
    
    // Stop collecting after 5 seconds and send data immediately afterwards
    collect_data_timer = [NSTimer scheduledTimerWithTimeInterval:SAMPLING_RANGE target:self selector:@selector(finishSampling) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:SAMPLING_RANGE+1 target:self selector:@selector(sendData) userInfo:nil repeats:NO];
    
}

- (void) pauseSampling {
    // Stop sending data
    [send_data_timer invalidate];
    [collect_data_timer invalidate];
    
    // Stop recording sensor data
    [soundProcessor pauseRecording];  // Microphone
    [dataProcessor stop];           // Accelerometer
    [CLController stop];            // Gyroscope
}

- (void) packData {
    NSLog( @"[SensorController] Packing data" );
    //--// Pack most recent data
    
    // Set previous lat/lng, speed, & timestamp
    [dataList setObject: [dataList objectForKey: LAT] forKey: PREV_LAT];
    [dataList setObject: [dataList objectForKey: LNG] forKey: PREV_LNG];
    [dataList setObject: [dataList objectForKey: SPEED] forKey: PREV_SPEED];
    [dataList setObject: [dataList objectForKey: TIMESTAMP] forKey: PREV_TIMESTAMP];
    
    if( CLController.currentLocation != nil ) {    
        // Set current lat/lng
        [dataList setObject: [NSString stringWithFormat:@"%f", CLController.currentLocation.coordinate.latitude] 
                     forKey: LAT];
        [dataList setObject: [NSString stringWithFormat:@"%f", CLController.currentLocation.coordinate.longitude] 
                     forKey: LNG];    

        // Set current speed
        [dataList setObject: [NSString stringWithFormat:@"%f", CLController.currentLocation.speed] 
                     forKey: SPEED];
        
        // Set location timestamp
        [dataList setObject: [NSString stringWithString:[CLController.currentLocation.timestamp description]] 
                     forKey: TIMESTAMP];
    }
    
    // Set acceleromter and gyroscope data
    [dataList setObject: [dataProcessor avgx] forKey: ACC_X];
    [dataList setObject: [dataProcessor avgy] forKey: ACC_Y];
    [dataList setObject: [dataProcessor avgz] forKey: ACC_Z];
        
    [dataList setObject: [dataProcessor avgRotationX] forKey: GYR_X];
    [dataList setObject: [dataProcessor avgRotationY] forKey: GYR_Y];
    [dataList setObject: [dataProcessor avgRotationZ] forKey: GYR_Z];
    
    // Set microphone data
	[soundProcessor.myRecorder updateMeters];
    
    //--// Record average power for microphone
    NSString *avg = [NSString stringWithFormat:@"%f", [soundProcessor.myRecorder averagePowerForChannel:0]];
    [dataList setObject:avg forKey: MIC_AVG];
    
    //--// Record peak power of microphone
    NSString *peak = [NSString stringWithFormat:@"%f", [soundProcessor.myRecorder peakPowerForChannel:0]];
    [dataList setObject:peak forKey: MIC_PEAK];
    
    // Start collecting data again!
    if( [collect_data_timer isValid] ) {
        [collect_data_timer invalidate];
    }
    
    // Continue sampling SAMPLING_RANGE+1 seconds before we send data again
    collect_data_timer = [NSTimer scheduledTimerWithTimeInterval: time_interval - ( SAMPLING_RANGE + 1 ) 
                                                          target: self 
                                                        selector: @selector(continueSampling) 
                                                        userInfo: nil 
                                                         repeats: NO];
}

#pragma mark - Sending/Receiving data management
-(void)sendData{
    [self packData];
    
    NSLog( @"[SensorController] Sending data to server" );
    
    //--// Format the keys and values for the API call
    NSMutableArray *dataValues = [[NSMutableArray alloc] init];
    for (NSString* key in [dataList allKeys]){
        [dataValues addObject: [NSString stringWithFormat:@"%@=%@", key, [dataList objectForKey:key]]];
    }
    
    //--// Append device id
    [dataValues addObject: [NSString stringWithFormat:@"%@=%@", @"udid", self.uuid]];
    
    //--// Append calibration tags ( if available )
    NSArray *tags = [delegate calibrationTags];
    if( tags != nil && [tags count] > 0 ) {
        // Append tags to data string
        [dataValues addObject: [NSString stringWithFormat:@"%@=%@", @"tags", [tags componentsJoinedByString:@","]]];
    }
    
    //--// Setup final API url
    NSString *api_call = [dataValues componentsJoinedByString:@"&"];
    
    //api_call = [NSString stringWithFormat: DEBUG_API_URL, api_call];    
     api_call = [NSString stringWithFormat: API_URL, api_call];
    
    api_call = [api_call stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog( @"%@", api_call );
    
    //--// Setup connection
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:api_call] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];                           
    api_connection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self startImmediately:YES];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    raw_api_data = [[NSMutableData alloc] init];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [raw_api_data appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog( @"[SensorController] ERROR: %@", [error localizedDescription] );
    [self.delegate error:@"Network Error"];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {    
    //--// Parse the raw api data into a JSON container
    NSError *error;
    NSDictionary *api_response = [NSJSONSerialization JSONObjectWithData: raw_api_data 
                                                                 options: NSJSONReadingMutableContainers 
                                                                   error: &error];
    if( error != nil ) {
        NSLog( @"JSON DATA: %@", [[NSString alloc] initWithData:raw_api_data encoding:NSUTF8StringEncoding] );
        NSLog( @"[Sensor Controller] ERROR: %@", [error localizedDescription] );
    }
    
    if( self.delegate ) {
        NSArray *activities = [api_response objectForKey:@"activities"];
        
        if( [activities count] > 0 ) {
            
            [self.delegate updateActivities: activities];
            [self.delegate updatePlaylist:[api_response objectForKey:@"playlist"] forActivity:[activities objectAtIndex:0]];
            
            if([[activities objectAtIndex:0] isEqualToString: @"talking"] ) {
                [self.delegate detectedTalking];
            } 
        }
    }
}
 

// HF Data Processing/Gathering Methods
-(void) startHFSampling {
    //Make file path - Right place to store data??
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    HFFilePath = [NSURL fileURLWithPath:directory];
    
    //Schedule timer that will repeatedly call HF Packing
    [dataProcessor turnOnHF];
    HFDataBundle = [[NSMutableArray alloc]init];
    
    HFPackingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/HF_SAMPLING_RATE target:self selector:@selector(packHFData) userInfo:nil repeats:YES];
}

-(void) packHFData {
    int max =0;
    if(isUserAsking == TRUE)
    {
        max = HF_NUM_SAMPLES_LESS;
    }
    else 
    {
        max = HF_NUM_SAMPLES_MORE;
    }
    if([HFDataBundle count] <= max)
    {
        //--// Pack most recent data and place it within Data Bundle
         
        if( CLController.currentLocation != nil ) {    
            // Set current lat/lng
            [HFDataList setObject: [NSString stringWithFormat:@"%f", CLController.currentLocation.coordinate.latitude] 
                         forKey: LAT];
            [HFDataList setObject: [NSString stringWithFormat:@"%f", CLController.currentLocation.coordinate.longitude] 
                         forKey: LNG];    
            
            // Set current speed
            [HFDataList setObject: [NSString stringWithFormat:@"%f", CLController.currentLocation.speed] 
                         forKey: SPEED];
            
            // Set location timestamp
            [HFDataList setObject: [NSString stringWithString:[CLController.currentLocation.timestamp description]] 
                         forKey: TIMESTAMP];
        }
        
        // Set acceleromter and gyroscope data
        [HFDataList setObject: [dataProcessor rawAx] forKey: ACC_X];
        [HFDataList setObject: [dataProcessor rawAy] forKey: ACC_Y];
        [HFDataList setObject: [dataProcessor rawAz] forKey: ACC_Z];
        
        [HFDataList setObject: [dataProcessor rawRx] forKey: GYR_X];
        [HFDataList setObject: [dataProcessor rawRy] forKey: GYR_Y];
        [HFDataList setObject: [dataProcessor rawRz] forKey: GYR_Z];
        
        // Set microphone data
        [soundProcessor.myRecorder updateMeters];
        
        //--// Record average power for microphone
        NSString *avg = [NSString stringWithFormat:@"%f", [soundProcessor.myRecorder averagePowerForChannel:0]];
        [HFDataList setObject:avg forKey: MIC_AVG];
        
        //--// Record peak power of microphone
        NSString *peak = [NSString stringWithFormat:@"%f", [soundProcessor.myRecorder peakPowerForChannel:0]];
        [HFDataList setObject:peak forKey: MIC_PEAK];
        
        
        [HFDataBundle addObject:HFDataList];
    }
    else
    {
        //convert NSMutableArray into NSData and store in HFFilePath
        NSData *HFData = [NSKeyedArchiver archivedDataWithRootObject:HFDataBundle];
        NSFileManager *manager = [NSFileManager defaultManager];
        [manager createFileAtPath:[HFFilePath absoluteString] contents:HFData attributes:nil];
        
        //Invalidate Timer and set sampling to regular interval
        [dataProcessor turnOffHF];
        [HFPackingTimer invalidate];
        
        NSLog(@"HF Finished Collection. This is the total HFData Length %u",[HFData length]);
    }

}

/*
-(NSData*) compressData (NSData* uncompressedData) 
{
    if ([uncompressedData length] == 0) return uncompressedData;
    
    z_stream strm;
    
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    strm.total_out = 0;
    strm.next_in=(Bytef *)[uncompressedData bytes];
    strm.avail_in = (unsigned int)[uncompressedData length];
    
    // Compresssion Levels:
    //   Z_NO_COMPRESSION
    //   Z_BEST_SPEED
    //   Z_BEST_COMPRESSION
    //   Z_DEFAULT_COMPRESSION
    
    if (deflateInit2(&strm, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY) != Z_OK) return nil;
    
    NSMutableData *compressed = [NSMutableData dataWithLength:16384];  // 16K chunks for expansion
    
    do {
        
        if (strm.total_out >= [compressed length])
            [compressed increaseLengthBy: 16384];
        
        strm.next_out = [compressed mutableBytes] + strm.total_out;
        strm.avail_out = (unsigned int)([compressed length] - strm.total_out);
        
        deflate(&strm, Z_FINISH);  
        
    } while (strm.avail_out == 0);
    
    deflateEnd(&strm);
    
    [compressed setLength: strm.total_out];
    return [NSData dataWithData:compressed];
}
*/

@end
