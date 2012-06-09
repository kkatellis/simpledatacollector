//
//  DataUploader.m
//  Sensor_Accessor
//
//  Created by Andrew Huynh on 4/11/12.
//  Copyright (c) 2012 CALab. All rights reserved.
//

#import "DataUploader.h"
#import "JSONKit.h"
#import <zlib.h>

static NSString * const BOUNDRY = @"0xKhTmLbOuNdArY";
static NSString * const FORM_FLE_INPUT = @"file";

#define BACKED_UP_INTERVAL  5

@interface DataUploader (Private)

- (void) upload:(NSString*) path;
- (NSURLRequest *)postRequestWithURL: (NSURL *)url
                             boundry: (NSString *)boundry
                                data: (NSData *)data
                            fileName: (NSString *)fileName;

- (NSData *)compress: (NSData *)data;
- (void) uploadSucceeded: (BOOL)success;
- (void) connectionDidFinishLoading:(NSURLConnection *)connection;

@end

#pragma mark - Public methods

@implementation DataUploader

@synthesize delegate, currentFile;

#pragma mark - Class methods

/**
 
 Returns the storage path for data files waiting to be uploaded.
 
 @returns NSURL Path URL representating the storage path.
 
 */
+ (NSURL*) storagePath {
    
    // Only have one instance of the storage path.
    static NSURL *storage = nil;
    
    // If the storage path has not been set, use the file manager to find it. 
    if( storage == nil ) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        storage = [fileManager URLForDirectory: NSDocumentDirectory
                                      inDomain: NSUserDomainMask
                             appropriateForURL: nil
                                        create: YES
                                         error: nil];
    }
    
    return storage;
}

#pragma mark - Instance methods

- (id) initWithURL:(NSURL *)uploadURL {
    self = [super init];
    
    if( self != nil ) {
        serverURL = uploadURL;
        
        //--// Setting up appropriate boolean variables:
        uploadDidSucceed    =   NO;
        activeHFUploading   =   NO;
        
        //--// Set up reachability class for wifi check
        wifiReachable = [Reachability reachabilityForLocalWiFi];
    
        //--// Set up queue management
        dataQueue = [[NSMutableArray alloc] init];
        
        //--// Set up wifi checker/data sending when data gets backed up
        sendBackedupTimer = [NSTimer scheduledTimerWithTimeInterval: BACKED_UP_INTERVAL 
                                                             target: self 
                                                           selector: @selector(sendBackedUpData) 
                                                           userInfo: nil 
                                                            repeats: YES];
        
        //--// Placing all created zip files within queue during initialization, enabling persistence;
        NSURL *dataPath = [DataUploader storagePath];

        // Get all files in the directory and filter for only "zip" files.
        NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: [dataPath path] 
                                                                                   error: nil];
        NSPredicate *filter  = [NSPredicate predicateWithFormat:@"self ENDSWITH '.zip'"];
        NSArray *onlyZips    = [dirContents filteredArrayUsingPredicate: filter];
        
        // Add to dataqueue if there are any files
        if( [onlyZips count] > 0 ) {
            [dataQueue addObjectsFromArray:onlyZips];
        }
    }
    
    return self;
}

/**
 
    Method that starts the setup of data uploading

 */
- (void)startUploadWithFileName: (NSString *)aFileName {
    
    NSAssert( aFileName, @"" );
    
    activeHFUploading = YES;
    
    // Put the file name into the queue
    [dataQueue enqueue: aFileName];
    
    // Check to see if we can upload data
    if( [wifiReachable currentReachabilityStatus] == ReachableViaWiFi ) {
      
        // Let's start sending stuff
        while( ![dataQueue empty] ) {
            
            [self upload: [dataQueue dequeue]];     
            
        }
        
    }
    
    activeHFUploading = NO;
}

// -- // Constant background queue depletion to prevent size issue
- (void) sendBackedUpData {
    
    // Checks for BOTH wifi and queue isn't already being sent actively
    if( [wifiReachable currentReachabilityStatus] == ReachableViaWiFi && !activeHFUploading ) {
        
        while( ![dataQueue empty] ) {
            
            // While sending elements in queue, first make sure all class variables correspond to the current file being sent
            [self upload: [dataQueue dequeue]];       
        }
        
    }
    
}

@end // Uploader

#pragma mark - Private methods

@implementation DataUploader (Private)

/** 
 
    Uploads the given file. The file is compressed before beign uploaded.
    The data is uploaded using an HTTP POST command.
 
 */
- (void) upload:(NSString *) file {
    
    currentFile = file;
      
    NSURL *storagePath = [DataUploader storagePath];
    NSString *fullPath = [[storagePath path] stringByAppendingPathComponent:file];
    
    NSLog( @"[DataUploader] Attempting to upload %@", fullPath );
    NSData *data = [NSData dataWithContentsOfFile: fullPath];
    
    if( !data ) {
        [self uploadSucceeded:NO];
        return;
    }
    
    if( [data length] == 0 ) {
        // There's no data, treat this the same as no file.
        [self uploadSucceeded:YES];
        return;
    }
    
    NSURLRequest *urlRequest = [self postRequestWithURL: serverURL
                                                boundry: BOUNDRY
                                                   data: data 
                                               fileName: file];
    if( !urlRequest ) {
        [self uploadSucceeded:NO];
        return;
    }
    
    NSURLConnection * connection = [[NSURLConnection alloc] initWithRequest: urlRequest 
                                                                   delegate: self];
    
    if (!connection) {
        [self uploadSucceeded:NO];
    }
    
    // Now wait for the URL connection to call us back.
}

/** 
    
    Creates a HTML POST request.

 */
- (NSURLRequest *)postRequestWithURL: (NSURL *)url
                             boundry: (NSString *)boundry
                                data: (NSData *)data 
                            fileName: (NSString *) fileName {
    
    // From http://www.cocoadev.com/index.pl?HTTPFileUpload
    NSMutableURLRequest *urlRequest =
    [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue: [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundry]
      forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *postData =
    [NSMutableData dataWithCapacity:[data length] + 512];
    [postData appendData: [[NSString stringWithFormat:@"--%@\r\n", boundry] dataUsingEncoding: NSUTF8StringEncoding]];
    
    [postData appendData: [[NSString stringWithFormat:
       @"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n\r\n", FORM_FLE_INPUT, fileName]
      dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postData appendData:data];
    [postData appendData:
     [[NSString stringWithFormat:@"\r\n--%@--\r\n", boundry] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [urlRequest setHTTPBody:postData];
    return urlRequest;
}

/**
    
    Uses zlib to compress the given data.

    @returns Compressed data in the form of a NSData object
 
 */
- (NSData *)compress: (NSData *)data {
    if (!data || [data length] == 0)
        return nil;
    
    // zlib compress doc says destSize must be 1% + 12 bytes greater than source.
    uLong destSize = [data length] * 1.001 + 12;
    NSMutableData *destData = [NSMutableData dataWithLength:destSize];
    
    int error = compress([destData mutableBytes],
                         &destSize,
                         [data bytes],
                         [data length]);
    if (error != Z_OK) {
        NSLog(@"%s: self:0x%p, zlib error on compress:%d\n",__func__, self, error);
        return nil;
    }
    
    [destData setLength:destSize];
    return destData;
}


/**
 
    Used to notify the delegate that the upload did or did not succeed.
 
 */
- (void)uploadSucceeded: (BOOL)success {
    
    if( self.delegate ) {
        if( success ) {
            [delegate onUploadDoneWithFile: currentFile];
        } else {
            [delegate onUploadErrorWithFile: currentFile];
        }
    }

    currentFile = nil;
}

/**
 
    Called when the upload is complete. We judge the success of the upload
    based on the reply we get from the server.
 
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    connection = nil;
    [self uploadSucceeded:uploadDidSucceed];
}


/**

    Called when the upload failed (probably due to a lack of network
    connection).
 
 */
- (void) connection: (NSURLConnection *)connection
   didFailWithError: (NSError *)error {
    
    connection = nil;
    [self uploadSucceeded:NO];

}

/**
 
    Called when we have data from the server. We expect the server to reply
    with a "YES" if the upload succeeded or "NO" if it did not.

 */
- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data {
    
    NSString *reply = [[NSString alloc] initWithData: data
                                            encoding: NSUTF8StringEncoding];
    
    NSDictionary *response = [[reply dataUsingEncoding: NSUTF8StringEncoding] objectFromJSONData];    
    if( [[response objectForKey:@"success"] boolValue] == TRUE ) {
        uploadDidSucceed = YES;
    }
}

@end