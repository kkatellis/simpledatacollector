//
//  DataUploader.h
//  Sensor_Accessor
//
//  Created by Andrew Huynh on 4/11/12.
//  Copyright (c) 2012 CALab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface DataUploader : NSObject {
    NSURL *serverURL;
    
    NSString *filePath, *fileName;
    id delegate;
    SEL doneSelector;
    SEL errorSelector;
    
    BOOL uploadDidSucceed;
    BOOL isHavingWifi;
    
    NSTimer             *sendBackedupTimer; // Checks periodically and makes sure backed up data are sent when wifi available
    
    Reachability        *internetReachable; // Object for internet reach testing
    Reachability        *hostReachable;     // Object for Host reach testing

}
//--// Initializers:
-   (id)initWithURL: (NSURL *)serverURL 
           filePath: (NSString *)filePath
           fileName: (NSString *)fileName
           delegate: (id)delegate 
       doneSelector: (SEL)doneSelector 
      errorSelector: (SEL)errorSelector;

-   (NSString *)filePath;
-   (NSString *)fileName;


-   (BOOL) checkIfWifi;
-   (void) sendBackedUpData;
//Methods that still need to be implemented:
//check wifi, check if space is full, queue implementation

@end