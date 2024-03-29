//
//  AppDelegate.m
//  rockmyworld
//
//  Created by Andrew Huynh on 11/14/11.
//  Copyright (c) 2011 athlabs. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>
#import <Parse/Parse.h>
#import <stdlib.h>

#import "AppDelegate.h"
#import "JSONKit.h"
#import "QuartzCore/CALayer.h"
#import "UIDevice+IdentifierAddition.h"

#define TEST_FLIGHT_TOKEN @"8dfb54954194ce9ea8d8677e95aaeefd_NjU3MDIwMTItMDItMDUgMTc6MDU6NDAuMzc1Mjk0"

// Prompt will show up after this many seconds
#define FEEDBACK_TIMER_DEFAULT      60 * 5
// Prompt will disappear after this many seconds
#define FEEDBACK_HIDE_INTERVAL      15
// Prompt will show up after this many activity changes
#define FEEDBACK_ACTIVITY_CHANGES   3  
// how long to wait before killing the app in the background
#define BACKGROUND_TIMER            60 * 30

@implementation AppDelegate

@synthesize window = _window;
@synthesize musicNavController;

#pragma mark - Class functions

+ (AppDelegate*) instance {
    return (AppDelegate*)[[UIApplication sharedApplication] delegate];
}

+ (Rdio*) rdioInstance {
    return [UnifiedPlayer rdioInstance];
}

#pragma mark - Instance functions

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Registering for Remote Notifications
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:  UIRemoteNotificationTypeBadge |
                                                                            UIRemoteNotificationTypeAlert |
                                                                            UIRemoteNotificationTypeSound ];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    // Ensure we don't have any leftover local notifications from before ( now using push notifications to achieve
    // the same deal ).
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
        
    // Handle launching from a notification
    feedNotification = [[UILocalNotification alloc] init];
    [feedNotification setSoundName: UILocalNotificationDefaultSoundName ];
    [feedNotification setAlertBody: @"Please provide feedback now!"];
    
    //--// Initialize Parse SDK
    [Parse setApplicationId: @"D55ULIo2tJiuquYpIM90h8Tswnkusor9U9AssZcw"
                  clientKey: @"8CWi6SaFf5mah5rjCJxmCd3qvTC5aOwPD0Kc1wYQ"];
    
    //--// Initialize TestFlight SDK
    [TestFlight takeOff: TEST_FLIGHT_TOKEN];
    
    //--// Start collecting data from sensors
    sensorController = [[SensorController alloc] initWithUUID: [[UIDevice currentDevice] uniqueDeviceIdentifier] 
                                                  andDelegate: self ];

    //--// Setup nav map
    navMap = [[NSMutableDictionary alloc] init];
    
    //--// Basic initialization
    [application setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    rootViewController = [[UIViewController alloc] init];
    
    //--// Load tab views
    navigationMenu = [[NavigationMenu alloc] initWithNibName:@"NavigationMenu" bundle:nil];
    
    //--// Initialized InfoView
    infoViewController = [[InfoViewController alloc] initWithNibName:@"InfoViewController" bundle:nil];

    
    //--// Initialize overview area
    overviewController = [[UIViewController alloc] init];
    
    overviewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] 
                                                                    initWithImage: [UIImage imageNamed:@"nav-menu-icon"]
                                                                            style: UIBarButtonItemStylePlain
                                                                           target: self
                                                                           action: @selector(showNavMenu)];
    
    overviewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] 
                                                                     initWithImage: [UIImage imageNamed:@"silent-on"]
                                                                             style: UIBarButtonItemStylePlain
                                                                            target: self
                                                                            action: @selector(toggleSilentMode)];
    
    //--// Initialize music views
    // Playlist view
    musicViewController = [[MusicViewController alloc] initWithNibName:@"MusicViewController" bundle:nil];
    [musicViewController viewWillAppear:YES];
    [musicViewController centerCurrentlyPlaying];
    
    // Navigation ( to show the nav bar on top )
    musicNavController  = [[RMWNavController alloc] initWithRootViewController: overviewController];    
    
    [[overviewController view] addSubview:musicViewController.view];
    [navMap setObject: musicViewController.view  forKey:@"Now Playing"];
    [navMap setObject: infoViewController.view   forKey:@"Test Info"];
        
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
    
    //--// Attempt to login to music services
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    //--// Check for RDIO access token in the user settings. If it exists, the user has logged into
    // rdio recently. Thus we want to reuse that token so that the session can continue.
    if( [settings objectForKey:@"RDIO-TOKEN"] != nil ) {
        NSString *token = [settings objectForKey:@"RDIO-TOKEN"];
        [[UnifiedPlayer rdioInstance] authorizeUsingAccessToken:token fromController:overviewController];
    }
    
    //--// Start feedback timer
    feedbackState       = kFeedbackHidden;
    dontBotherAmount    = 0;
    
    //--// Initialize playlist
    NSData *jsonData = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"default_playlist" 
                                                                                       ofType: @"json"]];
    NSArray *playlist = [jsonData mutableObjectFromJSONData];
    [self updatePlaylist:playlist forActivity:@"SITTING"];
    
    //--// We are running on silent mode
    isSilent = YES;    
    if ( isSilent ) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Hello!" 
                                                       message:@"Welcome to RMW! Currently silent mode is ON so you "
                                                                "can collect activity data with ease! Turn silent "
                                                                "mode off for music!"
                                                      delegate:self 
                                             cancelButtonTitle:@"ok!"
                                             otherButtonTitles:nil, nil];
        [alert show];
    }
    
    [musicViewController    setSilent:   isSilent];
    [activityViewController setIsSilent: isSilent];
    
    return YES;
}

- (void) getChannelsCallback:(NSSet *)channels error:(NSError *)error {
    // channels is an NSSet with all the subscribed channels
    if (error == nil) {
        NSLog(@"THESE ARE THE CHANNELS BEING SUBSCRIBED!!: %@", channels);
    } else {
        NSLog(@"THERE IS AN ERROR: %@", error);
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of 
     temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and 
     it begins the transition to the background state.
     
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use 
     this method to pause the game.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was 
     previously in the background, optionally refresh the user interface.
     */
    // Start up sampling and feedback again
    [sensorController startSamplingWithInterval];
    [feedBackTimer invalidate];
    feedBackTimer = [NSTimer scheduledTimerWithTimeInterval: FEEDBACK_TIMER_DEFAULT
                                                     target: self 
                                                   selector: @selector(promptForFeedback) 
                                                   userInfo: nil 
                                                    repeats: NO];    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state 
     information to restore your application to its current state in case it is terminated later. 
     
     If your application supports background execution, this method is called instead of applicationWillTerminate: when 
     the user quits.
     */
    waitingToKill = [NSTimer scheduledTimerWithTimeInterval: BACKGROUND_TIMER
                                                     target: self 
                                                   selector: @selector(callExit) 
                                                   userInfo: nil 
                                                    repeats: NO];
}

- (void) applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    
    NSLog( @"[AppDelegate]: Registered for Remote Notifications!" );
    // Tell Parse about the device token.
    [PFPush storeDeviceToken:newDeviceToken];
    
    // Subscribe to the global broadcast channel.
    [PFPush subscribeToChannelInBackground:@"development"];
    //[PFPush subscribeToChannelInBackground:@"testers"];
    
}

// Handling notification calls when device is Active
- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    NSLog( @"[AppDelegate]: RECEIVED REMOTE NOTIFICATION!" );
    [PFPush handlePush:userInfo];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    if( [error code] == 3010 ) {
        NSLog(@"Push notifications don't work in the simulator!");
    } else {
        NSLog(@"didFailToRegisterForRemoteNotificationsWithError: %@", error);
    }
    
}

- (void) callExit {
    exit(0);
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes 
     made on entering the background.
     */

    if( waitingToKill != nil ) {
        [waitingToKill invalidate];
    }
    
}

- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)notif {
    
    // Handle the notificaton when the app is running
    if( notif ) {
        static SystemSoundID soundID = 0;
        if( soundID == 0 ) {
            NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"alert" ofType:@"wav"];
            AudioServicesCreateSystemSoundID( (__bridge CFURLRef)[NSURL fileURLWithPath:soundPath], &soundID );    
        }
        
        UInt32 changeDefaultRoute = 1, speakerRoute = kAudioSessionOverrideAudioRoute_Speaker;
        
        // Use the default speaker because play & record sessions routes music to a different speaker
        //
        // More info on why we need to set this: 
        // http://www.iphonedevsdk.com/forum/iphone-sdk-development/48605-avaudioplayer-volume-problems.html
        CFStringRef audioRoute;
        UInt32 propSize = sizeof( audioRoute );
        AudioSessionGetProperty( kAudioSessionProperty_AudioRoute, &propSize, &audioRoute );
        
        NSString *route = (__bridge NSString*)audioRoute;
        if( [route isEqualToString:@"ReceiverAndMicrophone"] ) {
            AudioSessionSetProperty( kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, 
                                    sizeof( changeDefaultRoute ), 
                                    &changeDefaultRoute );
            
            AudioSessionSetProperty( kAudioSessionProperty_OverrideAudioRoute, 
                                    sizeof( speakerRoute ), 
                                    &speakerRoute );            
        }
        
        [[AVAudioSession sharedInstance] setActive:YES error:nil];   
        
        AudioServicesPlayAlertSound( soundID );
    }
    
}

#pragma mark - Remote Control Events

- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    // Let the audio player handle these events
    [musicViewController remoteControlReceivedWithEvent: receivedEvent];
}

#pragma mark - Sensor Controller handler

- (void) toggleSilentMode {
    
    if( !isSilent ) {
        
        UIAlertView *warning = [[UIAlertView alloc] initWithTitle: @"Silent ON" 
                                                          message: @"You've turned on silent mode! In this mode ONLY "
                                                                    "activity oriented questions will be asked, and no "
                                                                    "music will be played!"
                                                         delegate: self 
                                                cancelButtonTitle: @"Ok" 
                                                otherButtonTitles: nil, nil];
        [warning show];
        
        isSilent = YES;
        
        overviewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed:@"silent-on"]
                                                                                                style: UIBarButtonItemStylePlain
                                                                                               target: self
                                                                                               action: @selector(toggleSilentMode)];
        [activityViewController setIsSilent:YES];
        [musicViewController    setSilent:YES];
        
    } else {
        
        UIAlertView *warning = [[UIAlertView alloc] initWithTitle: @"Silent OFF" 
                                                          message: @"You've turned off silent mode, music will resume "
                                                                    "and prompts will appear normally" 
                                                         delegate: self 
                                                cancelButtonTitle: @"Ok" 
                                                otherButtonTitles: nil, nil];
        [warning show];
        
        isSilent = FALSE;
        
        overviewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed:@"music-note"]
                                                                                                style: UIBarButtonItemStylePlain
                                                                                               target: self
                                                                                               action: @selector(toggleSilentMode)];
        [activityViewController setIsSilent:NO];
        [musicViewController    setSilent:NO];
        
    }
}

- (NSArray*) calibrationTags { return nil; }

- (void) setDontBotherAmount:(int)minutes {

    // Multiply be 60 since NSTimeIntervals are expressed in seconds
    dontBotherAmount = minutes * 60;
    dontBotherStartDate = [NSDate date];
    NSLog(@"Don't Bother set to %d",dontBotherAmount);

}

- (void)  feedbackInitiated {
    if( feedbackState != kFeedbackUsing ) {
        NSLog( @"User has initiated feedback!" );
        feedbackState = kFeedbackUsing;
    }
}

- (void) promptForFeedback {

    NSLog( @"PROMPTING FOR FEEDBACK!" );
    
    // If we're not already waiting for feedback AND not already collecting data, start up the feedback
    // prompt and data collection.
    if( feedbackState == kFeedbackHidden && ![sensorController isCollectingPostData] ) {
        
        feedbackState = kFeedbackWaiting;

        // Clear the number of activity changes and invalidate timer
        activityChanges = 0;
        [feedBackTimer invalidate];
        
        //--// Start HF sampling before showing prompt. Then show prompt!
        [sensorController startHFPreSample];
        [self performSelector:@selector(showActivityView) withObject:nil afterDelay:10];
    }
}

- (void) sendFeedback: (NSDictionary*) feedback {
    feedbackState = kFeedbackFinished;
    [sensorController sendFeedback: feedback 
             withPredictedActivity: [activityViewController currentActivity]];
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
        
        //--// First check if the user has this track on their iPod.
        MPMediaQuery *query = [MPMediaQuery songsQuery];        
        NSArray *songs = [query items];

        if( [songs count] > 0 ) {
               
            for( int i = 0; i < [playlist count]; i++ ) {

                // Choose a random song to play!
                MPMediaItem *song = [songs objectAtIndex: ( arc4random() % [songs count] )];

                Track *newTrack = [[Track alloc] init];
                [newTrack setArtist: [song valueForProperty: MPMediaItemPropertyArtist]];
                [newTrack setSongTitle: [song valueForProperty: MPMediaItemPropertyTitle]];
                [newTrack setDbid: [NSString stringWithFormat:@"%@-%@", newTrack.artist, newTrack.songTitle]];
                                
                [tracks addObject:newTrack];
                
            }
        
        } else {
            
            // If the user has no songs if their library, simply use the RDIO recommendations.
            for( NSDictionary *trackMap in playlist ) {
                
                Track *newTrack = [[Track alloc] init];
                [newTrack setDbid: [trackMap objectForKey:@"dbid"]];
                [newTrack setArtist: [trackMap objectForKey:@"artist"]];
                [newTrack setRdioId: [trackMap objectForKey:@"rdio_id"]];
                [newTrack setSongTitle: [trackMap objectForKey:@"title"]];
                [newTrack setAlbumArt: [trackMap objectForKey:@"icon"]];
            
                [tracks addObject:newTrack];
                
            }
        }
        
        [musicViewController reloadPlaylist];   
    }
}

- (void) updateActivities: (NSArray*) activities {
    
    NSString *predicted = [activities objectAtIndex:0];
    
    // Register any flip-flopping of activities so we can prompt for feedback.
    if( ![[activityViewController currentActivity] isEqualToString:predicted] ) {
        activityChanges += 1;
        if( activityChanges >= FEEDBACK_ACTIVITY_CHANGES ) {
            NSLog(@"%d activity changes",activityChanges);
            [self promptForFeedback];
        }
    }    
        
    // Update activity view
    if( predicted != nil && [predicted length] > 0 ) {
        [activityViewController updateActivity:predicted];    
    }
    
    // Update activity button
    UIImage *activity = [UIImage imageNamed:[NSString stringWithFormat:@"indicator-%@", predicted ]];
    [musicNavController.activityButton setImage:activity forState:UIControlStateNormal];    
}

#pragma mark - Play music handler

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
    if( newView != nil ) {
//        [overviewController setView:newView];
        [[overviewController view] addSubview:newView];
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

    BOOL activeFeedback = FALSE;

    // If for some reason the feedback form wants to be shown while it's already shown,
    // just return from the function.
    if( feedbackState == kFeedbackUsing ) {
        return;
    }
    
    // Is this an active feedback event?
    if( feedbackState == kFeedbackHidden ) {
        // First check if we are already collecting data.
        // If we are, tell the user to wait before providing
        // active feedback.
        if( [sensorController isCollectingPostData] ) {

            UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Too soon!"
                                                           message: @"Please wait a bit before providing feedback again."
                                                          delegate: self
                                                 cancelButtonTitle: @"No probs"
                                                 otherButtonTitles: nil];
            [alert show];
            return;
            
        }
        
        feedbackState = kFeedbackWaiting;
        activeFeedback = TRUE;
        
    } else {
        [sensorController endHFSample];
    }
    // Start feedback sampling
    [sensorController startHFFeedbackSample];

    // If the dont bother amount is set, check to see if we should show the activity view.
    if( dontBotherStartDate != nil && !activeFeedback ) {
        NSDate *now = [NSDate date];
        NSTimeInterval delta = [now timeIntervalSinceDate: dontBotherStartDate];

        // We're still in the dont bother phase, so don't show the feedback view
        if( delta < (dontBotherAmount - 10) ) {
            NSLog( @"Pretending to submit feedback form - %f seconds left in don't bother", dontBotherAmount-delta);
            // Pretend the user has finished putting in feedback and submit the feedback
            // form again!
            [sensorController endHFSample];
            [self sendFeedback: [activityViewController feedbackValues]];
            [sensorController startHFPostSample];

            //--// Invalidate the hiding timer
            [feedBackHider invalidate];

            //--// Start up feedback timer again
            feedbackState = kFeedbackHidden;
            feedBackTimer = [NSTimer scheduledTimerWithTimeInterval: FEEDBACK_TIMER_DEFAULT
                                                             target: self
                                                           selector: @selector(promptForFeedback)
                                                           userInfo: nil
                                                            repeats: NO];
            return;
        }

        // If we're over the dont bother interval, reset the don't bother vars and
        // then show the feedback page.
        dontBotherStartDate = nil;
        dontBotherAmount    = 0;

    } else {
    
        // prompt for feedback
    [[UIApplication sharedApplication] presentLocalNotificationNow:feedNotification];
    
    }
        
    // Finally make sure that the activity view is not being shown at the moment
    if( activityViewController.parentViewController == self.window.rootViewController ) {
        return;
    }

    // Fix for iOS 4.0 not calling viewWillAppear when displaying the activity view.
    if( [self.window.rootViewController respondsToSelector:@selector( addChildViewController:)] ) {
        [activityViewController viewWillAppear:YES];
    }
    [self.window.rootViewController presentModalViewController:activityViewController animated:YES];

    feedBackHider = [NSTimer scheduledTimerWithTimeInterval: FEEDBACK_HIDE_INTERVAL 
                                                     target: self 
                                                   selector: @selector(hideActivityView) 
                                                   userInfo: nil 
                                                    repeats: NO];
}

- (void) hideActivityView {
    
    // Continue waiting for feedback if user is interacting    
    if( feedbackState == kFeedbackUsing ) {
        //--// Invalidate the hiding timer
        [feedBackHider invalidate];        
        
        feedBackHider = [NSTimer scheduledTimerWithTimeInterval: FEEDBACK_HIDE_INTERVAL
                                                         target: self 
                                                       selector: @selector(hideActivityView) 
                                                       userInfo: nil 
                                                        repeats: NO];
        
        return;

    // User hasn't interacted with the feedback prompt in the allotted time
    } else if( feedbackState == kFeedbackWaiting ) {
        
        // End sampling but don't start any new sampling
        [sensorController endHFSample];
    
    // User has completed the feedback form
    } else if( feedbackState == kFeedbackFinished ) {
    
        //--// End feedback sampling and start post sampling
        [sensorController endHFSample];
        [sensorController startHFPostSample];
        
    }
    
    [self.window.rootViewController dismissModalViewControllerAnimated:YES];
        
    //--// Invalidate the hiding timer
    [feedBackHider invalidate];
    
    //--// Start up feedback timer again
    feedbackState = kFeedbackHidden;
    feedBackTimer = [NSTimer scheduledTimerWithTimeInterval: FEEDBACK_TIMER_DEFAULT
                                                     target: self 
                                                   selector: @selector(promptForFeedback) 
                                                   userInfo: nil 
                                                    repeats: NO];
}

@end
