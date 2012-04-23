//
//  SensorController.m
//  Sensor_Accessor
//
//  Created by Peter Zhao on 1/21/12.
//  Refactored by Andrew Huynh on 2/16/12.
//  Copyright (c) 2012 CALab. All rights reserved.
//

#import "SensorController.h"

#import "ZipWriteStream.h"

// In seconds
#define SAMPLING_RANGE      5.0

// In seconds, interval of checking for wifi
#define ALERT_INTERVAL      30.0

// In Hertz
#define HF_SAMPLING_RATE    40

// Number of data points collected over ~40Hz * 25 sec
#define HF_NUM_SAMPLES      40 * 25
#define HF_HALF_SAMPLES     HF_NUM_SAMPLES / 2

#define HF_FILE_NAME        @"HF_DATA.txt"

//--// API URLs
#define API_URL         @"http://137.110.112.50/rmw/api/analyze?%@"
#define API_UPLOAD      @"http://137.110.112.50/rmw/api/feedback_upload"
#define API_FEEDBACK    @"http://137.110.112.50/rmw/api/feedback?%@"

#define DEBUG_API_URL           @"http://localhost:5000/api/analyze?%@"
#define DEBUG_API_UPLOAD        @"http://localhost:5000/api/feedback_upload"
#define DEBUG_API_FEEDBACK      @"http://localhost:5000/api/feedback?%@"

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

static NSArray          *supportedActivities = nil;
static float            freeSpaceAvailable = 0;

@implementation SensorController

@synthesize uuid, delegate;
@synthesize isCapacityFull;

//--// Returns a list of supported activities
+ (NSArray*) supportedActivities {
    
    if( supportedActivities == nil ) {
        supportedActivities = [[NSArray alloc] initWithObjects:@"biking", @"driving", @"exercising", @"housework",
                                                                @"party", @"running", @"sitting", @"talking", @"walking",
                                                                nil];
    }
    
    return supportedActivities;
}


//--// Calculates and return the space available for file storage
-(float)getFreeDiskSpace {   
    NSError *error = nil;  
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);  
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];  
    
    if (dictionary) {  
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemFreeSize];  
        freeSpaceAvailable = [fileSystemSizeInBytes floatValue];  
    } else {  
        NSLog(@"Error Obtaining File System Info: Domain = %@, Code = %@", [error domain], [error code]);  
    }  
    return freeSpaceAvailable;
} 


#pragma mark - View lifecycle

- (void) _apiCall:(NSString *)api withParams:(NSDictionary*)params {
    //--// Format the keys and values for the API call
    NSMutableArray *dataValues = [[NSMutableArray alloc] init];
    if( params != nil ) {
        for (NSString* key in [params allKeys]){
            [dataValues addObject: [NSString stringWithFormat:@"%@=%@", key, [params objectForKey:key]]];
        }
    }
    
    //--// Setup final API url
    NSString *api_call = [dataValues componentsJoinedByString:@"&"];
    api_call = [NSString stringWithFormat: api, api_call];
    
    api_call = [api_call stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog( @"RMW API CALL: %@", api_call );
    
    //--// Setup connection
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:api_call] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];                           
    api_connection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self startImmediately:YES];
}

- (id)initWithUUID:(NSString*) deviceId andDelegate:(id<SensorDelegate>) sensorDelegate {
    self = [super init];

    if( self != nil ) {
        // Set up device id / delegate
        [self setUuid: deviceId];
        [self setDelegate: sensorDelegate];
                
        //--// Set up Boolean Variables
        isHalfSample = NO;
        isCapacityFull = NO;

        //--// Set up data list
        dataList = [[NSMutableDictionary alloc] init];
        dataKeys = [[NSArray alloc] initWithObjects: LAT, LNG, SPEED, TIMESTAMP,
                                                        PREV_LAT, PREV_LNG, PREV_SPEED, PREV_TIMESTAMP, 
                                                        ACC_X, ACC_Y, ACC_Z, 
                                                        GYR_X, GYR_Y, GYR_Z, MIC_AVG, MIC_PEAK, nil];
        
        //--// Initialize Datauploader
        myUploader = [[DataUploader alloc] init];
        
        //--// Initialize data list to default values
        for ( NSString* key in dataKeys ) {
            [dataList setObject:@"0.0" forKey: key];
        }            
    }
    
    return self;
}

- (void) sendFeedback: (BOOL)isIncorrectActivity 
         withActivity: (NSString *)correctActivity 
             withSong: (NSString *)songId 
           isGoodSong: (BOOL) isGoodSong {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:4];
    [params setObject:self.uuid forKey:@"uuid"];
    [params setObject:[NSNumber numberWithBool:!isIncorrectActivity] forKey:@"is_correct_activity"];
    [params setObject:correctActivity forKey:@"current_activity"];
    [params setObject:songId forKey:@"current_song"];
    [params setObject:[NSNumber numberWithBool:isGoodSong] forKey:@"is_good_song"];
    
    [self _apiCall:API_FEEDBACK withParams:params];
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
    [soundProcessor pauseRecording];  // Microphone
    [dataProcessor stop];             // Accelerometer
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
    if( soundProcessor == nil ) {
        soundProcessor = [[SoundWaveProcessor alloc]init];
    }
    [soundProcessor startRecording];
    
    // Start collecting ACCELEROMETER data
    if( dataProcessor == nil ) {
        dataProcessor = [[AccelerometerProcessor alloc] init];
    }
    [dataProcessor start];
    
    // Start collecting GYROSCOPE data
    if( CLController == nil ) {
        CLController = [[CoreLocationController alloc] init];    
    }
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
    [soundProcessor pauseRecording];    // Microphone
    [dataProcessor stop];               // Accelerometer
    [CLController stop];                // Gyroscope
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
	[soundProcessor.lfRecorder updateMeters];
    
    //--// Record average power for microphone
    NSString *avg = [NSString stringWithFormat:@"%f", [soundProcessor.lfRecorder averagePowerForChannel:0]];
    [dataList setObject:avg forKey: MIC_AVG];
    
    //--// Record peak power of microphone
    NSString *peak = [NSString stringWithFormat:@"%f", [soundProcessor.lfRecorder peakPowerForChannel:0]];
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
        
    //--// Append device id
    [dataList setObject:self.uuid forKey:@"uuid"];
    
    //--// Append calibration tags ( if available )
    NSArray *tags = [delegate calibrationTags];
    if( tags != nil && [tags count] > 0 ) {
        // Append tags to data string
        [dataList setObject:[tags componentsJoinedByString:@","] forKey:@"tags"];
    }
    
    //--// Call the api!
    [self _apiCall:API_URL withParams:dataList];    
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
        NSLog( @"[Sensor Controller] ERROR LOADING" );
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
-(void) startHFSampling:(BOOL) isHalfSampleParam {
    
    isHalfSample = isHalfSampleParam;
    
    NSLog( @"[SensorController]: Starting HF sampling" );
    
    //--// Get user documents folder path
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error = nil;
    NSURL *dataPath = [fileManager URLForDirectory: NSDocumentDirectory 
                                          inDomain: NSUserDomainMask 
                                 appropriateForURL: nil 
                                            create: YES 
                                             error: &error];
    
    //--// Was there an error retreiving the directory path?
    if( error != nil ) {
        NSLog( @"SensorController: ERORR: %@", [error localizedDescription] );
        return;
    }
    
    // Setup HFData array
    if( HFDataBundle == nil ) {
        HFDataBundle    = [[NSMutableArray alloc]init];
    }
    [HFDataBundle removeAllObjects];    
    
    // Enable HF data collection
    [dataProcessor turnOnHF];    
    [soundProcessor startHFRecording];
    
    //--// Append our HF_FILE_NAME to the directory path
    HFFilePath = [[dataPath path] stringByAppendingPathComponent:HF_FILE_NAME];
    
    //--// Schedule timer that will repeatedly call HF Packing
    if( HFPackingTimer != nil && [HFPackingTimer isValid] ) {
        [HFPackingTimer invalidate];
    }

    HFPackingTimer  = [NSTimer scheduledTimerWithTimeInterval: 1.0/HF_SAMPLING_RATE 
                                                       target: self 
                                                     selector: @selector(packHFData) 
                                                     userInfo: nil 
                                                      repeats: YES];
}

-(void) packHFData {

    //--// Pack most recent data and place it within Data Bundle
    int SAMPLE_LIMIT = (isHalfSample) ? HF_HALF_SAMPLES : HF_NUM_SAMPLES;
    
    if( [HFDataBundle count] < SAMPLE_LIMIT ) {
        
        if( [HFDataBundle count] % 100 == 0 ) {
            NSLog( @"[SensorController] Collected %d HF samples", [HFDataBundle count] );
        }
        
        NSMutableDictionary *HFDataList = [[NSMutableDictionary alloc] initWithCapacity:8];
         
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
        [soundProcessor.hfRecorder updateMeters];
        
        //--// Record average power for microphone
        NSString *avg = [NSString stringWithFormat:@"%f", [soundProcessor.hfRecorder averagePowerForChannel:0]];
        [HFDataList setObject:avg forKey: MIC_AVG];
        
        //--// Record peak power of microphone
        NSString *peak = [NSString stringWithFormat:@"%f", [soundProcessor.hfRecorder peakPowerForChannel:0]];
        [HFDataList setObject:peak forKey: MIC_PEAK];
        
        
        [HFDataBundle addObject:HFDataList];
        
    } else {
        
        //--// Convert NSMutableArray into NSData and store in HFFilePath
        NSError *error = nil;
        NSData *HFData = [NSJSONSerialization dataWithJSONObject:HFDataBundle options:0 error:&error];

        if( error != nil ) {
            NSLog( @"[SensorController]: UNABLE TO CONVERT TO JSON DATA" );
            return;
        }   
        
        //--// Create File Manager
        NSFileManager *manager = [NSFileManager defaultManager];
        
        //--// Invalidate Timer and set sampling to regular interval
        [dataProcessor turnOffHF];
        [soundProcessor pauseHFRecording];
        [HFPackingTimer invalidate];
        
        freeSpaceAvailable = [self getFreeDiskSpace];
        
        //--// Checks if there are enough space to save new HFdata packet/Wifi to send old data and create new space
        if(![myUploader haveWifi] && [HFData length] > freeSpaceAvailable)
        {
            //If there are not enough space and ALSO wifi is not available
            NSLog(@"[SensorController]: Not Enough Space, data not saved nor gathered");
            isCapacityFull = YES;
            alertNoSpaceTimer = [NSTimer scheduledTimerWithTimeInterval:ALERT_INTERVAL
                                                                 target:self
                                                               selector:@selector(alertNotEnoughSpace)
                                                               userInfo:nil 
                                                                repeats:YES];
            return;
        }
        else 
        {
            isCapacityFull = NO;
        }
        
        //--// Attempt to save file to location and then send
        BOOL success = [manager createFileAtPath:HFFilePath contents:HFData attributes:nil];
        
        if (!success) 
        {
            NSLog ( @"[SensorController]: UNABLE TO CREATE HF DATA FILE" );
        }
        
        [self compressAndSend];
    }
}

-(void) alertNotEnoughSpace
{
    if(isCapacityFull)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Warning"
                                                       message:@"You are currently out of wifi range and running low on storage space, data gathering will pause until you reacquire wifi."
                                                      delegate:self 
                                             cancelButtonTitle:@"Ok"
                                             otherButtonTitles:nil];
        [alert show];
    }
    else 
    {
        [alertNoSpaceTimer invalidate];
    }
}

-(void) compressAndSend {
    
    //--// Get current timestamp and combine with UUID to form a unique zip file path
    NSDate *past = [NSDate date];
    NSString *zipFileName = [NSString stringWithFormat:@"%0.0f-%@.zip", [past timeIntervalSince1970], self.uuid];
    
    //--// Get the user's document directory path
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSURL *dataPath = [fileManager URLForDirectory: NSDocumentDirectory 
                                          inDomain: NSUserDomainMask 
                                 appropriateForURL: nil 
                                            create: YES 
                                             error: &error];
    
    //--// Was there an error retreiving the directory path?
    if( error != nil ) {
        NSLog( @"SensorController: ERORR: %@", [error localizedDescription] );
        return;
    }
    
    //--// Setup the paths to the data files
    NSString *soundFilePath = [[dataPath path] stringByAppendingPathComponent: [SoundWaveProcessor hfSoundFileName]]; 
    
    //--// Create zip file
    NSString *zipFile = [[dataPath path] stringByAppendingPathComponent: zipFileName];    
    ZipFile *zipper = [[ZipFile alloc] initWithFileName:zipFile mode:ZipFileModeCreate];
    
    //--// Write the HF sound file
    ZipWriteStream *stream = [zipper writeFileInZipWithName:HF_FILE_NAME compressionLevel:ZipCompressionLevelFastest];
    [stream writeData:[NSData dataWithContentsOfURL:[NSURL fileURLWithPath:HFFilePath]]];
    [stream finishedWriting];

    stream = [zipper writeFileInZipWithName: [SoundWaveProcessor hfSoundFileName] 
                           compressionLevel: ZipCompressionLevelFastest];
    
    [stream writeData:[NSData dataWithContentsOfURL:[NSURL fileURLWithPath:soundFilePath]]];
    [stream finishedWriting];
     
    //--// Write zip file
    [zipper close];
    
    //-// Send data to server/queue data up if no wifi present
    [myUploader startUploadWithURL:[NSURL URLWithString:API_UPLOAD]
                                               rootPath:[dataPath path]
                                               fileName:zipFileName
                                               delegate:self
                                           doneSelector:@selector(onUploadDone:) 
                                          errorSelector:@selector(onUploadError:)];
    
    /*
    BOOL temp = [fileManager fileExistsAtPath:[[dataPath path] stringByAppendingPathComponent: zipFileName]];
    
    NSLog(@"Does files exist at this path? %@", temp ? @"YES" : @"NO");
    NSLog(@"And the path used previously is %@", [[dataPath path] stringByAppendingPathComponent: zipFileName]);
     */
}

- (void) onUploadDone:(DataUploader*)dataUploader {
    NSLog( @"[SensorController] Successfully uploaded feedback. Removing zip file." );
    
    // Finished uploading? Awesome. Let's delete the old file.
    NSError *error = nil;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:[dataUploader filePath] error:&error];
    
    if( error != nil ) {
        NSLog( @"[SensorController] Error removing zip file: %@", [error localizedDescription] );
    }
}

- (void) onUploadError:(DataUploader*)dataUploader {
    NSLog( @"[SensorController] Error uploading feedback file." );
}


@end
