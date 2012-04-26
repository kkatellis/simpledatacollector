//
//  AppDelegate.m
//  rockmyworld
//
//  Created by Andrew Huynh on 11/14/11.
//  Copyright (c) 2011 athlabs. All rights reserved.
//

#import "AppDelegate.h"
#import "QuartzCore/CALayer.h"
#import "UIDevice+IdentifierAddition.h"

#define TEST_FLIGHT_TOKEN @"8dfb54954194ce9ea8d8677e95aaeefd_NjU3MDIwMTItMDItMDUgMTc6MDU6NDAuMzc1Mjk0"

// In seconds
#define FEEDBACK_TIMER              60 * 3
#define FEEDBACK_ACTIVITY_CHANGES   2
#define WIFI_TIMER                  30              //Interval between each prompt telling user to get in wifi range

@implementation AppDelegate

@synthesize window = _window;

#pragma mark - Class functions

+ (AppDelegate*) instance {
    return (AppDelegate*)[[UIApplication sharedApplication] delegate];
}

+ (Rdio*) rdioInstance {
    return [UnifiedPlayer rdioInstance];
}

#pragma mark - Instance functions

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        
    //-// Initialize TestFlight SDK
    [TestFlight takeOff:TEST_FLIGHT_TOKEN];
    
    //--// Start collecting data from sensors
    sensorController = [[SensorController alloc] initWithUUID: [[UIDevice currentDevice] uniqueDeviceIdentifier] 
                                                  andDelegate: self ];    
    [sensorController startSamplingWithInterval];

    //--// Setup nav map
    navMap = [[NSMutableDictionary alloc] init];
    
    // TODO: Actually create these views
    // UIViewController *tmp = [[UIViewController alloc] initWithNibName:@"Settings" bundle:nil];
    // [navMap setObject:tmp.view forKey:@"Settings"];
    
    //--// Basic initialization
    [application setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    rootViewController = [[UIViewController alloc] init];
    
    //--// Load tab views
    navigationMenu = [[NavigationMenu alloc] initWithNibName:@"NavigationMenu" bundle:nil];
    
    
    //--// Initialize overview area
    overviewController = [[UIViewController alloc] init];
    
    overviewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed:@"nav-menu-icon"]
                                                                             style: UIBarButtonItemStylePlain
                                                                            target: self
                                                                            action: @selector(showNavMenu)];

    overviewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"Calibrate"
                                                                                           style: UIBarButtonItemStylePlain
                                                                                          target: self
                                                                                          action: @selector(calibrate)];

    //--// Initialize music views
    // Playlist view
    musicViewController = [[MusicViewController alloc] initWithNibName:@"MusicViewController" bundle:nil];
    [musicViewController viewWillAppear:YES];
    [musicViewController centerCurrentlyPlaying];
    
    // Navigation ( to show the nav bar on top )
    musicNavController  = [[RMWNavController alloc] initWithRootViewController: overviewController];    
    
    [overviewController setView:musicViewController.view];
    [navMap setObject:musicViewController.view forKey:@"Now Playing"];
        
    //--// Add the nav view to the bottom
    [[rootViewController view] addSubview: [navigationMenu view]];
    
    //--// Add the music view on top
    [[rootViewController view] addSubview: [musicNavController view]];
    [[musicNavController view] setFrame:CGRectMake(0, -20, self.window.frame.size.width, self.window.frame.size.height)];
        
    //--// Load/Initialize activity view
    activityViewController = [[ActivityViewController alloc] initWithNibName:@"ActivityViewController" bundle:nil];
    [activityViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    
    //--// Show and display our root view
    self.window.rootViewController = rootViewController;
    [self.window makeKeyAndVisible];
    
    //--// Setup alert dialog
    alertViewController = [[RMWAlertViewController alloc] initWithNibName:@"RMWAlertViewController" bundle:nil];
    CGRect frame = [alertViewController.view frame];
    frame.origin.x = ( rootViewController.view.frame.size.width/2 - frame.size.width/2 );
    frame.origin.y = ( rootViewController.view.frame.size.height/2 - frame.size.height/2 );
    alertViewController.parent = rootViewController.view;
    [alertViewController.view setFrame:frame];
    [alertViewController showWithMessage:@"Loading..." andMessageType:RMWMessageTypeLoading];    
    
    //--// Attempt to login to music services
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    //--// Check for RDIO access token in the user settings. If it exists, the user has logged into
    // rdio recently. Thus we want to reuse that token so that the session can continue.
    if( [settings objectForKey:@"RDIO-TOKEN"] != nil ) {
        NSString *token = [settings objectForKey:@"RDIO-TOKEN"];
        [[UnifiedPlayer rdioInstance] authorizeUsingAccessToken:token fromController:overviewController];
    }
    
    //--// Start feedback timer
    waitingForFeedback = NO;
    feedBackTimer = [NSTimer scheduledTimerWithTimeInterval: FEEDBACK_TIMER
                                                     target: self 
                                                   selector: @selector(promptForFeedback) 
                                                   userInfo: nil 
                                                    repeats: NO];
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark - Sensor Controller handler

- (NSArray*) calibrationTags {
    return [calibrateViewController selectedTags];
}

- (void) promptForFeedback {
    
    NSLog( @"PROMPTING FOR FEEDBACK!" );
    if( !waitingForFeedback ) {
        waitingForFeedback = YES;
        
        // Clear the number of activity changes and invalidate timer
        activityChanges = 0;
        [feedBackTimer invalidate];
        
        //--// Start HF sampling before showing prompt. Then show prompt!
        [sensorController startHFSampling:NO];
        [self performSelector:@selector(showActivityView) withObject:nil afterDelay:10];
    }
}
- (void) sendFeedback: (BOOL)isIncorrectActivity 
         withActivity: (NSString *)correctActivity 
             withSong: (NSString *)songId 
           isGoodSong: (BOOL)isGoodSong {
    
    [sensorController sendFeedback: isIncorrectActivity 
                      withActivity: correctActivity 
                          withSong: songId
                        isGoodSong: isGoodSong];
}

- (void) hideAlertView {
    [alertViewController.view removeFromSuperview];
}

- (void) error:(NSString *)errorMessage {
    
    if( [errorMessage isEqualToString:@"Network Error"] ) {
        [sensorController pauseSampling];
    }
    [alertViewController showWithMessage:errorMessage andMessageType:RMWMessageTypeError];
}

- (void) detectedTalking {
    NSLog( @"[AppDelegate] DETECTED TALKING" );
    //[musicViewController lowerVolume];
    
}

- (void) updatePlaylist: (NSArray*) playlist forActivity:(NSString *)activity {
    // Hide loading message if it's still up.
    if( [alertViewController isVisible] ) {
        [alertViewController dismiss];
    }
    
    // TODO: Figure out a friendly way of evicting old playlists
    NSMutableArray *tracks = [musicViewController tracks];
    int tracksLeft = [tracks count] - musicViewController.currentTrackId;

    // Check if the activity is the same as before
    BOOL sameActivityConstraints = [activity isEqualToString: [activityViewController currentActivity]] && tracksLeft < 5;
    BOOL diffActivityConstraints = ![activity isEqualToString: [activityViewController currentActivity]];
    
    // Remove the tracks at the end of the list if we switched to a new activity
    if( diffActivityConstraints ) {
        NSRange aRange = NSMakeRange(musicViewController.currentTrackId + 1, ([tracks count] - (musicViewController.currentTrackId) - 1));
        [tracks removeObjectsInRange:aRange];
    }
    
    // Append the new songs
    if( sameActivityConstraints || diffActivityConstraints ) {
        
        for ( NSDictionary *trackMap in playlist ) {
            Track *newTrack = [[Track alloc] init];
            [newTrack setDbid: [trackMap objectForKey:@"dbid"]];
            [newTrack setArtist: [trackMap objectForKey:@"artist"]];
            [newTrack setRdioId: [trackMap objectForKey:@"rdio_id"]];
            [newTrack setSongTitle: [trackMap objectForKey:@"title"]];
            [newTrack setAlbumArt: [trackMap objectForKey:@"icon"]];
            
            [tracks addObject:newTrack];
        }
        
        [musicViewController reloadPlaylist];   
    }
}

- (void) updateActivities: (NSArray*) activities {
    
    // TODO: Show list of activities somewhere
    NSString *predicted = [activities objectAtIndex:0];
    
    // Register any flip-flopping of activities so we can prompt for feedback.
    if( ![[activityViewController currentActivity] isEqualToString:predicted] ) {
        activityChanges += 1;
        if( activityChanges >= FEEDBACK_ACTIVITY_CHANGES ) {
            [self promptForFeedback];
        }
    }    
        
    // Update activity view
    [activityViewController updateActivity:predicted];    
    
    // Update activity button
    UIImage *activity = [UIImage imageNamed:[NSString stringWithFormat:@"indicator-%@", predicted ]];
    [musicNavController.activityButton setImage:activity forState:UIControlStateNormal];    
}

- (void) calibrate {
    // Lazy load calibration page
    if( calibrateViewController == nil ) {
        calibrateViewController = [[CalibrateViewController alloc] initWithNibName:@"CalibrateViewController" bundle:nil];
    }
    [overviewController presentModalViewController:calibrateViewController animated:YES];
}

#pragma mark - Play music handler!

- (void) playMusic:(id)sender {
    [musicViewController centerCurrentlyPlaying];
}

- (Track*) currentTrack {
    if( musicViewController.currentTrackId >= 0 ) {
        return [[musicViewController tracks] objectAtIndex: musicViewController.currentTrackId ];
    }
    
    return nil;
}

#pragma mark - Stack-esque navigation menu

- (void) navigateTo:(NSString *)view {    
    
    // Handle Rdio login
    if( [view isEqualToString:@"RDIO"] ) {
        
        // Determine whether or not to login
        if( [[UnifiedPlayer rdioInstance] user] == nil ) {
            [[UnifiedPlayer rdioInstance] authorizeFromController: overviewController ];
        } else {
            [[UnifiedPlayer rdioInstance] logout];
        }
        
        [self hideNavMenu];
        return;
    }
    
    //--// Otherwise pass it off to our navigation map
    UIView *newView = [navMap objectForKey:view];
    if( newView == nil ) {
        [overviewController setView:broadcastViewController.view];
    } else {
        [overviewController setView:newView];
    }
    
    [self hideNavMenu];    
}

- (void)handleTapFrom:(UITapGestureRecognizer *)recognizer {
    [self hideNavMenu];
}

- (void) hideNavMenu {
    [navigationMenu viewWillDisappear:YES];
    
    [UIView animateWithDuration:0.1 animations:^{
        musicNavController.view.frame = CGRectMake( 0, 
                                                   -20, 
                                                   self.window.frame.size.width, 
                                                   self.window.frame.size.height );
    }];
    
    [[musicNavController view] removeGestureRecognizer:tapRecognizer];
}

- (void) showNavMenu {
    [navigationMenu viewWillAppear:YES];
    
    [UIView animateWithDuration:0.2 animations:^{
        musicNavController.view.frame = CGRectMake( self.window.frame.size.width - 54, 
                                                   -20, 
                                                   self.window.frame.size.width, 
                                                   self.window.frame.size.height );
    }];
    
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    [tapRecognizer setNumberOfTapsRequired:1];
    [tapRecognizer setDelaysTouchesBegan:YES];
    [tapRecognizer setDelaysTouchesEnded:YES];
    [tapRecognizer setCancelsTouchesInView:YES];
    [musicNavController.view addGestureRecognizer:tapRecognizer];
    
}

#pragma mark - Activity View handlers

- (void) showActivityView {
    
    if( !waitingForFeedback ) {
        waitingForFeedback = YES;
        [sensorController startHFSampling:TRUE];
    }
    
    [self.window.rootViewController presentModalViewController:activityViewController animated:YES];
}

- (void) hideActivityView {
    [self.window.rootViewController dismissModalViewControllerAnimated:YES];
    
    //--// Start up feedback timer again
    waitingForFeedback = NO;
    feedBackTimer = [NSTimer scheduledTimerWithTimeInterval: FEEDBACK_TIMER
                                                     target: self 
                                                   selector: @selector(promptForFeedback) 
                                                   userInfo: nil 
                                                    repeats: NO];
}

@end
