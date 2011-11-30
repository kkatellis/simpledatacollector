//
//  MusicViewController.h
//  rockmyworld
//
//  Created by Andrew Huynh on 11/14/11.
//  Copyright (c) 2011 athlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface MusicViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate> {
    UITableView *table;
    
    // Audio playback
    NSArray *tracks;
    int currentTrackId;
    AVQueuePlayer *audioPlayer;
    
    BOOL paused;
}

@property ( nonatomic,retain ) IBOutlet UITableView *table;
@property ( nonatomic, retain ) AVQueuePlayer *audioPlayer;

- (void) centerCurrentlyPlaying;

- (void) playAction;
- (void) nextAction;
- (void) prevAction;

@end
