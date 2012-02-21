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

@implementation AppDelegate

@synthesize window = _window;

#pragma mark - Class functions

+ (AppDelegate*) instance {
    return (AppDelegate*)[[UIApplication sharedApplication] delegate];
}

#pragma mark - Instance functions

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //--// Start collecting data from sensors
    sensorController = [[SensorController alloc] initWithUUID: [[UIDevice currentDevice] uniqueDeviceIdentifier] 
                                                  andDelegate: self ];    
    [sensorController startSampling];
    
    //--// Setup initial values
    hasMusic = FALSE;
    
    //--// Setup nav map
    navMap = [[NSMutableDictionary alloc] init];
    
    // TODO: Actually create these views
    UIViewController *tmp = [[UIViewController alloc] initWithNibName:@"Settings" bundle:nil];
    [navMap setObject:tmp.view forKey:@"Settings"];
    tmp = [[UIViewController alloc] initWithNibName:@"Profile" bundle:nil];
    [navMap setObject:tmp.view forKey:@"Profile"];
    tmp = [[UIViewController alloc] initWithNibName:@"Friends" bundle:nil];
    [navMap setObject:tmp.view forKey:@"Friends"];
    tmp = [[UIViewController alloc] initWithNibName:@"Trending" bundle:nil];
    [navMap setObject:tmp.view forKey:@"Trending"];
    tmp = [[UIViewController alloc] initWithNibName:@"Friendcasts" bundle:nil];
    [navMap setObject:tmp.view forKey:@"Friendcasts"];
    
    //--// Basic initialization
    [application setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    rootViewController = [[StackViewController alloc] initWithNibName:@"StackView" bundle:nil];
    
    //--// Load tab views
    navigationMenu = [[NavigationMenu alloc] initWithNibName:@"NavigationMenu" bundle:nil];
    
    
    //--// Initialize overview area
    overviewController = [[UIViewController alloc] init];
    overviewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed:@"nav-menu-icon"]
                                                                             style: UIBarButtonItemStylePlain
                                                                            target: self
                                                                            action: @selector(showNavMenu)];        
    
    // Initialize music views
    musicViewController = [[MusicViewController alloc] initWithNibName:@"MusicViewController" bundle:nil];
    [musicViewController viewWillAppear:YES];
    
    [overviewController setView:musicViewController.view];
    [navMap setObject:musicViewController.view forKey:@"Overview"];
    
    musicNavController  = [[RMWNavController alloc] initWithRootViewController: overviewController];
    [musicViewController centerCurrentlyPlaying];
    
    broadcastViewController = [[BroadcastViewController alloc] initWithNibName:@"BroadcastViewController" bundle:nil];
    [navMap setObject:broadcastViewController.view forKey:@"Broadcasts"];
    
    // Add the nav view to the bottom
    [[rootViewController view] addSubview: [navigationMenu view]];
    
    // Add the music view on top
    [[rootViewController view] addSubview: [musicNavController view]];
    [[musicNavController view] setFrame:CGRectMake(0, -20, self.window.frame.size.width, self.window.frame.size.height)];
        
    //--// Load/Initialize activity view
    activityViewController = [[ActivityViewController alloc] initWithNibName:@"ActivityViewController" bundle:nil];
    [activityViewController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    
    //--// Show and display our root view
    self.window.rootViewController = rootViewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    
    // Pause music
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    // Unpause music
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

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark - Sensor Controller handler

- (NSArray*) calibrationTags {
    return nil;
}

- (void) error:(NSString *)errorMessage {
    NSLog( @"SENSOR ERROR: %@", errorMessage );
}

- (void) detectedTalking {
    NSLog( @"DETECTED TALKING" );
}

- (void) updatePlaylist: (NSArray*) playlist {
    if( [playlist count] > 0 ) {
        NSMutableArray *tracks = [musicViewController tracks];
        
        if( [tracks count] > 0 ) {
            return;
        }
        
        for ( NSDictionary *trackMap in playlist ) {
            Track *newTrack = [[Track alloc] init];
            [newTrack setArtist: [trackMap objectForKey:@"artist"]];
            [newTrack setRdioId: [trackMap objectForKey:@"rdio_id"]];
            [newTrack setSongTitle: [trackMap objectForKey:@"title"]];
            
            [tracks addObject:newTrack];
        }
        
        [musicViewController reloadPlaylist];
    }
}

- (void) updateActivities: (NSArray*) activities {}

#pragma mark - Play music handler!

- (void) playMusic:(id)sender {
    [musicViewController centerCurrentlyPlaying];
}

#pragma mark - Stack-esque navigation menu

- (void) navigateTo:(NSString *)view {    
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
    [UIView animateWithDuration:0.1 animations:^{
        musicNavController.view.frame = CGRectMake( 0, 
                                                   -20, 
                                                   self.window.frame.size.width, 
                                                   self.window.frame.size.height );
    }];
    
    [[musicNavController view] removeGestureRecognizer:tapRecognizer];
}

- (void) showNavMenu {
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
    [self.window.rootViewController presentModalViewController:activityViewController animated:YES];
}

- (void) hideActivityView {
    [self.window.rootViewController dismissModalViewControllerAnimated:YES];
}

//Rdio Related Methods
//-(void) startPlaying {
//    if(!isTalking) {
//        [self playClicked];
//    }
//}
//
//-(RDPlayer*)getPlayer {
//    if (player == nil) {
//        player = [_AppDelegate rdioInstance].player;
//    }
//    return player;
//}
//
//-(void) updateSong {
//    if(musicDataBase.prevIndex != musicDataBase.currentIndex) {
//        songChanged = true;
//        NSString *key = [[musicDataBase.musicData objectAtIndex:musicDataBase.currentIndex.row] objectForKey:@"rdio_id"];
//        currentSong.text = [[musicDataBase.musicData objectAtIndex:musicDataBase.currentIndex.row] objectForKey:@"title"];
//        currentArtist.text = [[musicDataBase.musicData objectAtIndex:musicDataBase.currentIndex.row] objectForKey:@"artist"];
//        //NSArray *keys = [NSArray arrayWithObject:key];
//        musicDataBase.prevIndex = musicDataBase.currentIndex;
//        NSLog(@"%@", key);
//        [[self getPlayer] playSource:key];
//    }
//    
//}
//
//
//- (IBAction) playClicked {
//    if( [musicDataBase.musicData count] == 0 ) {
//        return;
//    }
//    
//    if (!playing) {
//        NSMutableArray *keys = [[NSMutableArray alloc]init];
//        int counter = 0;
//        while (counter < [musicDataBase.musicData count]) {
//            //keys = [[NSMutableArray alloc]init];
//            [keys addObject: [[musicDataBase.musicData objectAtIndex:counter] objectForKey:@"rdio_id"]];
//            counter ++;
//        }
//        currentSong.text = [[musicDataBase.musicData objectAtIndex:0] objectForKey:@"title"];
//        currentArtist.text = [[musicDataBase.musicData objectAtIndex:0] objectForKey:@"artist"];
//        NSArray *finalKeys = [[NSArray alloc]initWithArray:keys];
//        NSLog(@"%@", finalKeys);
//        [[self getPlayer] playSources:keys];
//    } else {
//        [[self getPlayer] togglePause];
//    }
//}
//
//- (IBAction) loginClicked:(id) button {
//    if (loggedIn) {
//        [[_AppDelegate rdioInstance] logout];
//    } else {
//        [[_AppDelegate rdioInstance] authorizeFromController:self];
//    }
//}
//
//- (void) setLoggedIn:(BOOL)logged_in {
//    loggedIn = logged_in;
//    if (logged_in) {
//        [loginButton setTitle:@"Log Out" forState: UIControlStateNormal];
//    } else {
//        [loginButton setTitle:@"Log In" forState: UIControlStateNormal];
//    }
//}
//
//#pragma mark -
//#pragma mark RdioDelegate
//
//- (void) rdioDidAuthorizeUser:(NSDictionary *)user withAccessToken:(NSString *)accessToken {
//    [self setLoggedIn:YES];
//}
//
//- (void) rdioAuthorizationFailed:(NSString *)error {
//    [self setLoggedIn:NO];
//}
//
//- (void) rdioAuthorizationCancelled {
//    [self setLoggedIn:NO];
//}
//
//- (void) rdioDidLogout {
//    [self setLoggedIn:NO];
//}
//
//
//#pragma mark -
//#pragma mark RDPlayerDelegate
//
//- (BOOL) rdioIsPlayingElsewhere {
//    // let the Rdio framework tell the user.
//    return NO;
//}
//
//- (void) rdioPlayerChangedFromState:(RDPlayerState)fromState toState:(RDPlayerState)state {
//    playing = (state != RDPlayerStateInitializing && state != RDPlayerStateStopped);
//    paused = (state == RDPlayerStatePaused);
//    if (paused || !playing) {
//        [playButton setTitle:@"Play" forState:UIControlStateNormal];
//    } else {
//        [playButton setTitle:@"Pause" forState:UIControlStateNormal];
//    }
//}

@end
