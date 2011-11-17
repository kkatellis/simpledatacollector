//
//  AppDelegate.h
//  play
//
//  Created by Andrew Huynh on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ActivityViewController.h"
#import "BroadcastViewController.h"
#import "HistoryViewController.h"
#import "MusicViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate> {
    ActivityViewController  *activityViewController;
    BroadcastViewController *broadcastViewController;    
    HistoryViewController   *historyViewController;
    MusicViewController     *musicViewController;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;

- (void) showActivityView;
- (void) hideActivityView;

@end
