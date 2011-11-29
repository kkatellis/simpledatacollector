//
//  AppDelegate.h
//  play
//
//  Created by Andrew Huynh on 11/14/11.
//  Copyright (c) 2011 athlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ActivityViewController.h"
#import "BroadcastViewController.h"
#import "HistoryViewController.h"
#import "NavigationMenu.h"
#import "MusicViewController.h"
#import "RMWNavController.h"
#import "StackViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate> {
    StackViewController *rootViewController;
    
    ActivityViewController  *activityViewController;
    
    BroadcastViewController *broadcastViewController;    
    HistoryViewController   *historyViewController;
    
    NavigationMenu          *navigationMenu;
    
    MusicViewController     *musicViewController;
    RMWNavController        *musicNavController;
    
    UITapGestureRecognizer  *tapRecognizer;
}

@property (strong, nonatomic) UIWindow *window;

- (void) showNavMenu;
- (void) hideNavMenu;

- (void) showActivityView;
- (void) hideActivityView;

@end
