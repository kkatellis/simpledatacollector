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
#import "InfoViewController.h"

#import "RMWAlertViewController.h"
#import "RMWNavController.h"

// Sensor Accessor includes
#import "SensorController.h"

// TestFlight SDK
#import "TestFlight.h"

typedef enum {
    kFeedbackHidden,        // Feedback form is hidden
    kFeedbackWaiting,       // Feedback form is waiting for user input
    kFeedbackUsing,         // User is interacting with feedback form
    kFeedbackFinished       // User has finished interacting with feedback form
} FeedbackState;


@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, SensorDelegate> {
    
    //--// Various views
    UIViewController *overviewController;
    RMWAlertViewController  *alertViewController;
        
    ActivityViewController  *activityViewController;
    
    BroadcastViewController *broadcastViewController;
    
    CalibrateViewController *calibrateViewController;
    
    // added by Kirsten
    InfoViewController      *infoViewController;
    
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
    NSTimer *feedBackTimer;      // Timer set to go off every 3 minutes ( reset after every prompt ).
    NSTimer *feedBackHider;      // Timer set to hide the feedback prompt if the user ignores it
    int activityChanges;         // # of activity changes since last prompt
    FeedbackState feedbackState; // What is the state of the feedback form?    
    
    NSTimer *waitingToKill; // waiting to kill the app
}

@property (strong, nonatomic) UIWindow *window;

+ (AppDelegate*)instance;
+ (Rdio*) rdioInstance;

- (void) showInfo;
- (void) promptForFeedback;

- (void) feedbackInitiated;
- (void) sendFeedback: (NSDictionary*) feedback;

- (void) playMusic: (id) sender;
- (Track*) currentTrack;

- (void) navigateTo:(NSString*)view;
- (void) showNavMenu;
- (void) hideNavMenu;

- (void) showActivityView;
- (void) hideActivityView;

- (void) error:(NSString *)errorMessage;

- (void) callExit;
@end
