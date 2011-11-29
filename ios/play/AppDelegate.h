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
#import "HistoryViewController.h"
#import "FeedViewController.h"
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
    
    FeedViewController      *feedViewController;
    MusicViewController     *musicViewController;
    RMWNavController        *musicNavController;
    
    UITapGestureRecognizer  *tapRecognizer;
}

@property (strong, nonatomic) UIWindow *window;

+ (AppDelegate*)instance;

- (void) playMusic: (id) sender;

- (void) showNavMenu;
- (void) hideNavMenu;

- (void) showActivityView;
- (void) hideActivityView;

@end
