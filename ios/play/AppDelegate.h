//
//  AppDelegate.h
//  rockmyworld
//
//  Created by Andrew Huynh on 11/14/11.
//  Copyright (c) 2011 athlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Rdio/Rdio.h>

#import "ActivityViewController.h"
#import "BroadcastViewController.h"
#import "CalibrateViewController.h"
#import "FeedViewController.h"
#import "NavigationMenu.h"
#import "MusicViewController.h"

#import "RMWAlertViewController.h"
#import "RMWNavController.h"

// Sensor Accessor includes
#import "SensorController.h"

// TestFlight SDK
#import "TestFlight.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, SensorDelegate> {
    
    //--// Various views
    UIViewController *overviewController;
    RMWAlertViewController  *alertViewController;
        
    ActivityViewController  *activityViewController;
    
    BroadcastViewController *broadcastViewController;
    
    CalibrateViewController *calibrateViewController;
    
    NavigationMenu          *navigationMenu;
    NSMutableDictionary     *navMap;
    
    MusicViewController     *musicViewController;
    RMWNavController        *musicNavController;

    //--// Used for the sliding view
    UITapGestureRecognizer  *tapRecognizer;
    UIViewController        *rootViewController;
            
    //--// Sensor accessors
    SensorController *sensorController;
    
    //--// Popup the feedback screen according to these specifications by whichever happens first:
    // 1. Every 3 minutes
    // 2. After 2 changes of activity
    NSTimer *feedBackTimer;     // Timer set to go off every 3 minutes ( reset after every prompt ).
    int activityChanges;        // # of activity changes since last prompt
    BOOL waitingForFeedback;    // Are we waiting for feedback?
}

@property (strong, nonatomic) UIWindow *window;

+ (AppDelegate*)instance;
+ (Rdio*) rdioInstance;

- (void) calibrate;
- (void) promptForFeedback;
- (void) sendFeedback: (BOOL) isIncorrectActivity 
         withActivity: (NSString*)correctActivity 
             withSong: (NSString*) songId 
           isGoodSong: (BOOL) isGoodSong;

- (void) playMusic: (id) sender;
- (Track*) currentTrack;

- (void) navigateTo:(NSString*)view;
- (void) showNavMenu;
- (void) hideNavMenu;

- (void) showActivityView;
- (void) hideActivityView;

- (void) error:(NSString *)errorMessage;

@end
