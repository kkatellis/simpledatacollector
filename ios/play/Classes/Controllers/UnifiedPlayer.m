//
//  UnifiedPlayer.m
//  rockmyworld
//
//  Created by Andrew Huynh on 4/3/12.
//  Copyright (c) 2012 athlabs. All rights reserved.
//

#import <AudioToolbox/AudioServices.h>
#import "UnifiedPlayer.h"

//--// RDIO related stuff
#define RDIO_KEY @"vuzwpzmda4hwvwfhqkwqqpyh"
#define RDIO_SEC @"kHRJvWdT2t"
static Rdio *rdio = NULL;

@interface UnifiedPlayer(Private)
- (void) _playerSongEnd: (NSNotification*) notification;
- (void) _updateProgress;
@end


@implementation UnifiedPlayer

@synthesize progress, duration, delegate;

+ (Rdio *)rdioInstance {
    return rdio;
}

#pragma mark - Player actions
- (id) init {
    // Create new instance of RDIO player if it hasn't been initialized yet
    if( self = [super init] ) {

        if( audioPlayer == nil ) {
            audioPlayer = [[AVQueuePlayer alloc] init];
        }
        
        if( rdio == nil ) {
            rdio = [[Rdio alloc] initWithConsumerKey:RDIO_KEY andSecret:RDIO_SEC delegate:self];
        }
        
        // Setup AVAudioSession
        [[AVAudioSession sharedInstance] setDelegate:self];
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
        UInt32 doSetProperty = 0;
        AudioSessionSetProperty (
                                 kAudioSessionProperty_OverrideCategoryMixWithOthers,
                                 sizeof (doSetProperty),
                                 &doSetProperty
                                 );
        
        NSError *activationError = nil;
        [[AVAudioSession sharedInstance] setActive: YES error: &activationError];
    }
    
    return self;
}

- (void) _updateProgress {
    progress += 1.0;
    [delegate updateProgress:progress andDuration:duration];
}

- (void) _playerSongEnd:(NSNotification *)notification {
    [delegate songDidEnd];
}

- (BOOL) isPaused {
    
    if( currentTrack == nil ) {
        return YES;
    }
    
    // Check the specific player to see if it's paused
    if( [currentTrack isRdio] ) {
        
        return [[rdio player] state] == RDPlayerStatePaused;
        
    } else {
        
        return [audioPlayer rate] == 0.0;
    }
    
}

- (void) stop {
    [audioPlayer pause];
    [[rdio player] stop];
}

- (void) togglePause {
    
    if( [currentTrack isRdio] ) {
        [[rdio player] togglePause];
    } else {
        
        if( [self isPaused] ) {
            [audioPlayer play];
            progressTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0 
                                                             target: self 
                                                           selector: @selector(_updateProgress) 
                                                           userInfo: nil 
                                                            repeats: YES];
        } else {
            [audioPlayer pause];
            [progressTimer invalidate];
            progressTimer = nil;
            
        }
        
    }
    
}

- (void) play:(Track*)track {
    
    currentTrack = track;

    progress = 0.0;
    duration = 0.0;
    [progressTimer invalidate];    
    
    if( [currentTrack isRdio] ) {
        
        [[rdio player] playSource:[currentTrack rdioId]];
        [[rdio player] addObserver:self forKeyPath:@"position" options:NSKeyValueChangeReplacement context:nil];
        
    } else {

        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[currentTrack stream]];
        [audioPlayer replaceCurrentItemWithPlayerItem:playerItem];
        [audioPlayer play];

        duration = CMTimeGetSeconds( playerItem.duration );
        
        // Update progress bar every second
        if( progressTimer ) {
            [progressTimer invalidate];
            progressTimer = nil;
        }
        progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(_updateProgress) userInfo:nil repeats:YES];        
        
        // Get notified that the song has ended
        [[NSNotificationCenter defaultCenter] addObserver: self 
                                                 selector: @selector( _playerSongEnd: ) 
                                                     name: AVPlayerItemDidPlayToEndTimeNotification 
                                                   object: [audioPlayer currentItem]];
    }
        
}

#pragma mark - RDPlayerDelegate
- (BOOL) rdioIsPlayingElsewhere {
    // let the Rdio framework tell the user.
    return NO;
}

- (void) rdioPlayerChangedFromState:(RDPlayerState)fromState toState:(RDPlayerState)state {}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if( [keyPath isEqualToString:@"position"] ) {
        
        progress = [[rdio player] position] + 1;
        duration = [[rdio player] duration];
        
        if( duration <= 0.1 ) {
            duration = 30.0;
        }
    
        [delegate updateProgress:progress andDuration:duration];
        
        if( progress >= duration ) {
            [[rdio player] stop];
            [[rdio player] removeObserver:self forKeyPath:@"position"];
            [self _playerSongEnd:nil];
        }
    }
}

- (void) rdioDidAuthorizeUser:(NSDictionary *)user withAccessToken:(NSString *)accessToken {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setObject:accessToken forKey:@"RDIO-TOKEN"];
    [settings synchronize];
}


@end
