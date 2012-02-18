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
#import "FeedViewController.h"
#import "NavigationMenu.h"
#import "MusicViewController.h"
#import "RMWNavController.h"
#import "StackViewController.h"

// Sensor Accessor includes
#import "Sensor-Accesor/SensorController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, SensorDelegate> {
    
    //--// Various views
    UIViewController *overviewController;
        
    ActivityViewController  *activityViewController;
    
    BroadcastViewController *broadcastViewController;
    
    NavigationMenu          *navigationMenu;
    NSMutableDictionary     *navMap;
    
    MusicViewController     *musicViewController;
    RMWNavController        *musicNavController;

    //--// Used for the sliding view
    UITapGestureRecognizer  *tapRecognizer;
    StackViewController     *rootViewController;
    
    //--// Music playing?
    BOOL hasMusic;
        
    //--// Sensor accessors
    SensorController *sensorController;
}

@property (strong, nonatomic) UIWindow *window;

+ (AppDelegate*)instance;
+ (Rdio*)rdioInstance;

- (void) playMusic: (id) sender;

- (void) navigateTo:(NSString*)view;
- (void) showNavMenu;
- (void) hideNavMenu;

- (void) showActivityView;
- (void) hideActivityView;

@end
