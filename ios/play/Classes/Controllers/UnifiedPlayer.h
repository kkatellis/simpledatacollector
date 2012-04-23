//
//  UnifiedPlayer.h
//  rockmyworld
//
//  Created by Andrew Huynh on 4/3/12.
//  Copyright (c) 2012 athlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>
#import <Rdio/Rdio.h>

#import "Track.h"

@protocol UnifiedPlayerDelegate
- (void) updateProgress:(double)progress andDuration:(double)duration;
- (void) songDidEnd;
@end

@interface UnifiedPlayer : NSObject< AVAudioSessionDelegate, AVAudioPlayerDelegate, RdioDelegate>  {
    
    id<UnifiedPlayerDelegate> delegate;
    
    Track *currentTrack;
    BOOL isPlayingLocal;
    
    AVPlayer *audioPlayer;
    NSTimer *progressTimer;
    
    double duration, progress;
    
    BOOL interruptedWhilePlaying;
}

+ (Rdio*) rdioInstance;

- (BOOL) isPaused;

- (void) play:(Track*)track;
- (void) stop;
- (void) togglePause;

@property (nonatomic, retain) id<UnifiedPlayerDelegate> delegate;
@property (nonatomic, assign) double duration;
@property (nonatomic, assign) double progress;

@property (nonatomic, assign) BOOL isPlayingLocal;

@end
