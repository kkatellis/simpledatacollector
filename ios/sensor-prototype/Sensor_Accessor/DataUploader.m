//
//  DataUploader.m
//  Sensor_Accessor
//
//  Created by Andrew Huynh on 4/11/12.
//  Copyright (c) 2012 CALab. All rights reserved.
//

#import "DataUploader.h"
#import <zlib.h>

static NSString * const BOUNDRY = @"0xKhTmLbOuNdArY";
static NSString * const FORM_FLE_INPUT = @"file";

#define ASSERT(x) NSAssert(x, @"")

#define BACKED_UP_INTERVAL  5

@interface DataUploader (Private)

- (void)upload;
- (NSURLRequest *)postRequestWithURL: (NSURL *)url
                             boundry: (NSString *)boundry
                                data: (NSData *)data;

- (NSData *)compress: (NSData *)data;
- (void)uploadSucceeded: (BOOL)success;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

@end

@implementation DataUploader

/*
 * For NSFileManager : http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSFileManager_Class/Reference/Reference.html
 *
 * For filters : 
 * http://stackoverflow.com/questions/499673/getting-a-list-of-files-in-a-directory-with-a-glob
 *
 */

- (id) init {
    self = [super init];
    
    /*
    //--// Placing all created zip files within queue during initialization, enabling persistence;
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSURL *dataPath = [fm URLForDirectory: NSDocumentDirectory 
                                 inDomain: NSUserDomainMask 
                        appropriateForURL: nil 
                                   create: YES 
                                    error: nil];
    
    // gets all file NAMES in memory (so like: data.zip, pic.jpeg etc.)
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:[dataPath absoluteString] error:nil];
    
    // filters out everything except for .zip
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.zip'"];
    
    // array of ONLY .zip files in directory
    NSArray *onlyZIPs = [dirContents filteredArrayUsingPredicate:fltr];
    
    // insert these into the class-wide queue
     //KIRSTEN'S STUFF - NEEDS CHECKING!!
    */
    
    //--// Setting up appropriate boolean variables:
    isHavingWifi        =   NO;
    uploadDidSucceed    =   NO;
    activeHFUploading   =   NO;
    
    //--// Set up reachability classes for wifi check
    internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];
    
    hostReachable     = [Reachability reachabilityWithHostName:@"www.google.com"];
    [hostReachable startNotifier];    
    
    wifiReachable     = [Reachability reachabilityForLocalWiFi];
    [wifiReachable startNotifier];
    
    //--// Set up queue management
    dataQueue = [[NSMutableArray alloc] init];
    
    //--// Set up wifi checker/data sending when data gets backed up
    sendBackedupTimer = [NSTimer scheduledTimerWithTimeInterval:BACKED_UP_INTERVAL 
                                                         target:self 
                                                       selector:@selector(sendBackedUpData) 
                                                       userInfo:nil 
                                                        repeats:YES];
    return self;
}



/*
 *-----------------------------------------------------------------------------
 *
 * -[Uploader dealloc] --
 *
 *      Destructor.
 *
 * Results:
 *      None
 *
 * Side effects:
 *      None
 *
 *-----------------------------------------------------------------------------
 */

- (void)dealloc {
    serverURL = nil;
    filePath = nil;
    delegate = nil;
    doneSelector = NULL;
    errorSelector = NULL;
}

/*
 *-----------------------------------------------------------------------------
 *
 * -[Uploader filePath] --
 *
 *      Gets the path of the file this object is uploading.
 *
 * Results:
 *      Path to the upload file.
 *
 * Side effects:
 *      None
 *
 *-----------------------------------------------------------------------------
 */

- (NSString *)filePath {
    return filePath;
}

- (NSString *)fileName {
    return fileName;
}

- (BOOL) haveWifi{
    return isHavingWifi;
}

// -- // Method that starts the setup of data uploading

- (void)startUploadWithURL: (NSURL *)aServerURL
                  rootPath: (NSString *)aRootPath
                  fileName: (NSString *)aFileName
                  delegate: (id)aDelegate
              doneSelector: (SEL)aDoneSelector
             errorSelector: (SEL)anErrorSelector
{
    activeHFUploading = YES;
    
    ASSERT(aServerURL);
    ASSERT(aRootPath);
    ASSERT(aDelegate);
    ASSERT(aDoneSelector);
    ASSERT(anErrorSelector);
        
    //Creating zip file path from root path:
    NSString *actualFilePath = [aRootPath stringByAppendingPathComponent: aFileName];    
    
    serverURL = aServerURL;
    rootPath = aRootPath;
    filePath = actualFilePath;
    fileName = aFileName;
    delegate = aDelegate;
    doneSelector = aDoneSelector;
    errorSelector = anErrorSelector;
        
    
    if(isHavingWifi)
    {
        if([dataQueue empty])
        {
            [self upload];
        }
        else 
        {
            // flush entire queue first
            while (![dataQueue empty])
            {
                //While sending elements in queue, first make sure all class variables correspond to the present file element being sent
                fileName = [dataQueue dequeue];
                filePath = [aRootPath stringByAppendingPathComponent: fileName];
                [self upload];
            }
            
            // sends item just collected
            fileName = aFileName;
            filePath = [aRootPath stringByAppendingPathComponent: fileName];
            [self upload];
        }
    }
    else  //wifi NOT available
    {
        [dataQueue enqueue:aFileName];
    }
    activeHFUploading = NO;
}


// -- // Wifi checking/reachability class management

- (void) reachabilityChanged: (NSNotification* )note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    [self updateInterfaceWithReachability: curReach];
}

- (void) updateInterfaceWithReachability: (Reachability*) curReach
{
    if(curReach == wifiReachable)
    {
        isHavingWifi = YES;
    }
    else 
    {
        isHavingWifi = NO;
    }
}

- (BOOL)checkIfWifi
{
    //--// called after network status changes
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus)
    {
        case NotReachable:
        {
            NSLog(@"The internet is down.");
            isHavingWifi = NO;
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"The internet is working via WIFI.");
            isHavingWifi = YES;
            
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"The internet is working via WWAN.");
            isHavingWifi = NO;
            
            break;
        }
    }
    
    NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
    switch (hostStatus)
    {
        case NotReachable:
        {
            NSLog(@"A gateway to the host server is down.");
            isHavingWifi = NO;
            
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"A gateway to the host server is working via WIFI.");
            isHavingWifi = YES;
            
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"A gateway to the host server is working via WWAN.");
            isHavingWifi = NO;
            
            break;
        }
    }
    return isHavingWifi;
    
}



// -- // Constant background queue depletion to prevent size issue
-(void) sendBackedUpData{
    // checks for BOTH wifi and queue isn't already being sent actively
    if(isHavingWifi && !activeHFUploading)
    {
        if(![dataQueue empty])
        {
            while (![dataQueue empty])
            {
                //While sending elements in queue, first make sure all class variables correspond to the current file being sent
                fileName = [dataQueue dequeue];
                filePath = [rootPath stringByAppendingPathComponent: fileName];
                [self upload];
            }
        }
    }
    else 
    {
        NSLog(@"[SensorController]: DOES NOT SEE WIFI");
    }
}



@end // Uploader


@implementation DataUploader (Private)


/*
 *-----------------------------------------------------------------------------
 *
 * -[Uploader(Private) upload] --
 *
 *      Uploads the given file. The file is compressed before beign uploaded.
 *      The data is uploaded using an HTTP POST command.
 *
 * Results:
 *      None
 *
 * Side effects:
 *      None
 *
 *-----------------------------------------------------------------------------
 */

- (void)upload
{
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    ASSERT(data);
    if (!data) {
        [self uploadSucceeded:NO];
        return;
    }
    if ([data length] == 0) {
        // There's no data, treat this the same as no file.
        [self uploadSucceeded:YES];
        return;
    }
    
    //  NSData *compressedData = [self compress:data];
    //  ASSERT(compressedData && [compressedData length] != 0);
    //  if (!compressedData || [compressedData length] == 0) {
    //      [self uploadSucceeded:NO];
    //      return;
    //  }
    
    NSURLRequest *urlRequest = [self postRequestWithURL:serverURL
                                                boundry:BOUNDRY
                                                   data:data];
    if (!urlRequest) {
        [self uploadSucceeded:NO];
        return;
    }
    
    NSURLConnection * connection =
    [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    if (!connection) {
        [self uploadSucceeded:NO];
    }
    
    // Now wait for the URL connection to call us back.
}


/*
 *-----------------------------------------------------------------------------
 *
 * -[Uploader(Private) postRequestWithURL:boundry:data:] --
 *
 *      Creates a HTML POST request.
 *
 * Results:
 *      The HTML POST request.
 *
 * Side effects:
 *      None
 *
 *-----------------------------------------------------------------------------
 */

- (NSURLRequest *)postRequestWithURL: (NSURL *)url        // IN
                             boundry: (NSString *)boundry // IN
                                data: (NSData *)data      // IN
{
    // from http://www.cocoadev.com/index.pl?HTTPFileUpload
    NSMutableURLRequest *urlRequest =
    [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:
     [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundry]
      forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *postData =
    [NSMutableData dataWithCapacity:[data length] + 512];
    [postData appendData:
     [[NSString stringWithFormat:@"--%@\r\n", boundry] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:
     [[NSString stringWithFormat:
       @"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n\r\n", FORM_FLE_INPUT, self.fileName]
      dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:data];
    [postData appendData:
     [[NSString stringWithFormat:@"\r\n--%@--\r\n", boundry] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [urlRequest setHTTPBody:postData];
    return urlRequest;
}

/*
 *-----------------------------------------------------------------------------
 *
 * -[Uploader(Private) compress:] --
 *
 *      Uses zlib to compress the given data.
 *
 * Results:
 *      The compressed data as a NSData object.
 *
 * Side effects:
 *      None
 *
 *-----------------------------------------------------------------------------
 */

- (NSData *)compress: (NSData *)data // IN
{
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


/*
 *-----------------------------------------------------------------------------
 *
 * -[Uploader(Private) uploadSucceeded:] --
 *
 *      Used to notify the delegate that the upload did or did not succeed.
 *
 * Results:
 *      None
 *
 * Side effects:
 *      None
 *
 *-----------------------------------------------------------------------------
 */

- (void)uploadSucceeded: (BOOL)success // IN
{
    [delegate performSelector:success ? doneSelector : errorSelector
                   withObject:self];
}


/*
 *-----------------------------------------------------------------------------
 *
 * -[Uploader(Private) connectionDidFinishLoading:] --
 *
 *      Called when the upload is complete. We judge the success of the upload
 *      based on the reply we get from the server.
 *
 * Results:
 *      None
 *
 * Side effects:
 *      None
 *
 *-----------------------------------------------------------------------------
 */

- (void)connectionDidFinishLoading:(NSURLConnection *)connection // IN 
{
    NSLog(@"%s: self:0x%p\n", __func__, self);
    connection = nil;
    [self uploadSucceeded:uploadDidSucceed];
}


/*
 *-----------------------------------------------------------------------------
 *
 * -[Uploader(Private) connection:didFailWithError:] --
 *
 *      Called when the upload failed (probably due to a lack of network
 *      connection).
 *
 * Results:
 *      None
 *
 * Side effects:
 *      None
 *
 *-----------------------------------------------------------------------------
 */

- (void)connection:(NSURLConnection *)connection // IN
  didFailWithError:(NSError *)error              // IN
{
    NSLog(@"%s: self:0x%p, connection error:%s\n",
          __func__, self, [[error description] UTF8String]);
    connection = nil;
    [self uploadSucceeded:NO];
}


/*
 *-----------------------------------------------------------------------------
 *
 * -[Uploader(Private) connection:didReceiveResponse:] --
 *
 *      Called as we get responses from the server.
 *
 * Results:
 *      None
 *
 * Side effects:
 *      None
 *
 *-----------------------------------------------------------------------------
 */

-(void)       connection:(NSURLConnection *)connection // IN
      didReceiveResponse:(NSURLResponse *)response     // IN
{
    NSLog(@"%s: self:0x%p\n", __func__, self);
}


/*
 *-----------------------------------------------------------------------------
 *
 * -[Uploader(Private) connection:didReceiveData:] --
 *
 *      Called when we have data from the server. We expect the server to reply
 *      with a "YES" if the upload succeeded or "NO" if it did not.
 *
 * Results:
 *      None
 *
 * Side effects:
 *      None
 *
 *-----------------------------------------------------------------------------
 */

- (void)connection:(NSURLConnection *)connection // IN
    didReceiveData:(NSData *)data                // IN
{
    NSString *reply = [[NSString alloc] initWithData:data
                                             encoding:NSUTF8StringEncoding];
    
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData: [reply dataUsingEncoding:NSUTF8StringEncoding] 
                                                             options: NSJSONReadingMutableContainers 
                                                               error:nil];
    
    if( [[response objectForKey:@"success"] boolValue] == TRUE ) {
        uploadDidSucceed = YES;
    }
}

@end