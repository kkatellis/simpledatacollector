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

@interface DataUploader : NSObject {
    NSURL *serverURL;
    
    NSString *filePath, *fileName, *rootPath;
    id delegate;
    SEL doneSelector;
    SEL errorSelector;
    
    BOOL                uploadDidSucceed;   // If upload succeeded or not
    BOOL                isHavingWifi;       // If wifi is available
    BOOL                activeHFUploading;  // True if class is uploading HF data, use to check when running background queue depletion, avoid conflicts

    
    NSMutableArray      *dataQueue;         // Queue Object for our packet management
    
    NSTimer             *sendBackedupTimer; // Checks periodically and makes sure backed up data are sent when wifi available
    
    Reachability        *wifiReachable;     // Object for wifi reach testing

}
//--// Initializers:
-   (id)init;

//--// Parameter Getters
-   (NSString *)filePath;
-   (NSString *)fileName;
-   (NSString *)rootPath;
-   (BOOL)      haveWifi;

//--// Wifi Checking
-   (void) updateInterfaceWithReachability: (Reachability*) curReach;
-   (void) reachabilityChanged: (NSNotification* )note;

//--// Readying Data for upload
-   (void) startUploadWithURL: (NSURL *)serverURL 
                     rootPath: (NSString *)rootPath
                     fileName: (NSString *)fileName
                     delegate: (id)delegate 
                 doneSelector: (SEL)doneSelector 
                errorSelector: (SEL)errorSelector;

//--// Background Constant Queue Depletion
-   (void) sendBackedUpData;
@end