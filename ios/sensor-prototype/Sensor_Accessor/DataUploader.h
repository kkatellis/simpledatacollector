//
//  DataUploader.h
//  Sensor_Accessor
//
//  Created by Andrew Huynh on 4/11/12.
//  Copyright (c) 2012 CALab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataUploader : NSObject {
    NSURL *serverURL;
    
    NSString *filePath, *fileName;
    id delegate;
    SEL doneSelector;
    SEL errorSelector;
    
    BOOL uploadDidSucceed;
}

-   (id)initWithURL: (NSURL *)serverURL 
           filePath: (NSString *)filePath
           fileName: (NSString *)fileName
           delegate: (id)delegate 
       doneSelector: (SEL)doneSelector 
      errorSelector: (SEL)errorSelector;

-   (NSString *)filePath;
-   (NSString *)fileName;

@end