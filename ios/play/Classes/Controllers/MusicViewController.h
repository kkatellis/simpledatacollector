//
//  MusicViewController.h
//  rockmyworld
//
//  Created by Andrew Huynh on 11/14/11.
//  Copyright (c) 2011 athlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Track.h"
#import "TrackInfoView.h"

#import "UnifiedPlayer.h"

//--// Asynchronous download of album art handlers
#import "SDImageCache.h"
#import "SDWebImageCompat.h"
#import "SDWebImageManager.h"
#import "SDWebImageManagerDelegate.h"

@interface MusicViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UnifiedPlayerDelegate,
                                                    SDWebImageManagerDelegate> 
{
    UITableView     *table;
    TrackInfoView   *trackInfo;
    UIView          *pullToAdd;
    
    UIBarButtonItem *playpause, *pauseBtn, *playBtn;
    UIToolbar       *controls;
    NSMutableArray  *controlsList;    
                                                                                                                
    // Audio playback
    UnifiedPlayer   *audioPlayer;
    NSMutableArray  *tracks;
    Track           *currentTrack;
    BOOL            isSilent;
    
    NSTimer *progressTimer;
    
    // States
    BOOL isAdding;   // Is the adding panel being shown?
    BOOL isDragging; // Is the user dragging the table up/down?
}

@property ( nonatomic, retain ) IBOutlet UITableView *table;
@property ( nonatomic, retain ) IBOutlet TrackInfoView *trackInfo;
@property ( nonatomic, retain ) IBOutlet UIView *pullToAdd;
@property ( nonatomic, retain ) IBOutlet UIBarButtonItem *playpause;
@property ( nonatomic, retain ) IBOutlet UIToolbar *controls;

@property ( nonatomic, readonly ) int currentTrackId;
@property ( nonatomic, readonly ) BOOL paused;
@property ( nonatomic, readonly ) UnifiedPlayer *audioPlayer;
@property ( nonatomic, retain ) NSMutableArray *tracks;

- (void) centerCurrentlyPlaying;
- (void) reloadPlaylist;
- (void) setSilent:(BOOL) value;

- (IBAction) playAction;
- (IBAction) nextAction;
- (IBAction) prevAction;

@end
