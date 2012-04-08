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
    
    //UIApplication    *myApp = (UIApplication *)sharedApplication;
}

@property (strong, nonatomic) UIWindow *window;

+ (AppDelegate*)instance;
+ (Rdio*) rdioInstance;

- (void) calibrate;

- (void) playMusic: (id) sender;
- (Track*) currentTrack;

- (void) navigateTo:(NSString*)view;
- (void) showNavMenu;
- (void) hideNavMenu;

- (void) showActivityView;
- (void) hideActivityView;

- (void) error:(NSString *)errorMessage;

@end
