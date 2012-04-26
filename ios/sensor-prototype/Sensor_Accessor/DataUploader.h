//
//  DataUploader.h
//  Sensor_Accessor
//
//  Created by Andrew Huynh on 4/11/12.
//  Copyright (c) 2012 CALab. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Reachability.h"
#import "NSQueue.h"

@protocol DataUploaderDelegate <NSObject>

- (void) onUploadDoneWithFile:(NSString *)file;
- (void) onUploadErrorWithFile:(NSString *)file;

@end

@interface DataUploader : NSObject {
    NSURL *serverURL;
    
    NSString *currentFile;
    
    id<DataUploaderDelegate> delegate;

    BOOL                uploadDidSucceed;   // If upload succeeded or not
    BOOL                activeHFUploading;  // True if class is uploading HF data, use to check when running background queue depletion, avoid conflicts

    
    NSMutableArray      *dataQueue;         // Queue Object for our packet management
    
    NSTimer             *sendBackedupTimer; // Checks periodically and makes sure backed up data are sent when wifi available
    
    Reachability        *wifiReachable;     // Object for wifi reach testing
}

@property (nonatomic, retain) id delegate;
@property (nonatomic, readonly) NSString *currentFile;

+ (NSURL*) storagePath;

//--// Initializers:
-   (id)initWithURL:(NSURL*)uploadURL;

//--// Readying Data for upload
-   (void) startUploadWithFileName: (NSString *)fileName;

//--// Background Constant Queue Depletion
-   (void) sendBackedUpData;
@end