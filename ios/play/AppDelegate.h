//
//  AppDelegate.h
//  rockmyworld
//
//  Created by Andrew Huynh on 11/14/11.
//  Copyright (c) 2011 athlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ActivityViewController.h"
#import "BroadcastViewController.h"
#import "FeedViewController.h"
#import "NavigationMenu.h"
#import "MusicViewController.h"
#import "RMWNavController.h"
#import "StackViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, UIAccelerometerDelegate> {
    UIViewController *overviewController;
    
    StackViewController *rootViewController;
    
    ActivityViewController  *activityViewController;
    
    BroadcastViewController *broadcastViewController;
    
    NavigationMenu          *navigationMenu;
    NSMutableDictionary     *navMap;
    
    FeedViewController      *feedViewController;
    MusicViewController     *musicViewController;
    RMWNavController        *musicNavController;
    
    UITapGestureRecognizer  *tapRecognizer;
    
    BOOL hasMusic;
    
    // Accelerometer related stuffs
    UIAccelerometer *accelerometer;
    NSMutableArray *axVals, *ayVals, *azVals;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) UIAccelerometer *accelerometer;
@property (nonatomic, readonly) NSMutableArray *axVals;
@property (nonatomic, readonly) NSMutableArray *ayVals;
@property (nonatomic, readonly) NSMutableArray *azVals;

+ (AppDelegate*)instance;

- (void) playMusic: (id) sender;

- (void) navigateTo:(NSString*)view;
- (void) showNavMenu;
- (void) hideNavMenu;

- (void) showActivityView;
- (void) hideActivityView;

@end
