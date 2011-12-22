//
//  MusicViewController.h
//  rockmyworld
//
//  Created by Andrew Huynh on 11/14/11.
//  Copyright (c) 2011 athlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "Track.h"
#import "TrackInfoView.h"

@interface MusicViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate> {
    UITableView *table;
    TrackInfoView *trackInfo;
    UIView *pullToAdd;
    
    UIBarButtonItem *playpause, *pauseBtn, *playBtn;
    UIToolbar *controls;
    NSMutableArray *controlsList;
    
    // Audio playback
    NSMutableArray *tracks;
    Track *currentTrack;
    int currentTrackId;
    AVQueuePlayer *audioPlayer;
    
    NSTimer *progressTimer;
    
    // States
    BOOL paused;     // Is the player paused?
    BOOL isAdding;   // Is the adding panel being shown?
    BOOL isDragging; // Is the user dragging the table up/down?
}

@property ( nonatomic, retain ) IBOutlet UITableView *table;
@property ( nonatomic, retain ) IBOutlet TrackInfoView *trackInfo;
@property ( nonatomic, retain ) IBOutlet UIView *pullToAdd;
@property ( nonatomic, retain ) IBOutlet UIBarButtonItem *playpause;
@property ( nonatomic, retain ) IBOutlet UIToolbar *controls;
@property ( nonatomic, retain ) AVQueuePlayer *audioPlayer;

- (void) centerCurrentlyPlaying;

- (void) playAction;
- (void) nextAction;
- (void) prevAction;

@end
