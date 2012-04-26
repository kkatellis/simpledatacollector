//
//  UnifiedPlayer.m
//  rockmyworld
//
//  Created by Andrew Huynh on 4/3/12.
//  Copyright (c) 2012 athlabs. All rights reserved.
//

#import <AudioToolbox/AudioServices.h>
#import <MediaPlayer/MediaPlayer.h>
#import "UnifiedPlayer.h"

//--// RDIO related stuff
#define RDIO_KEY @"vuzwpzmda4hwvwfhqkwqqpyh"
#define RDIO_SEC @"kHRJvWdT2t"
static Rdio *rdio = NULL;

@interface UnifiedPlayer(Private)
- (void) _playerSongEnd: (NSNotification*) notification;
- (void) _updateProgress;
@end

#pragma mark - Private methods

/// Private methods for the UnifiedPlayer class
@implementation UnifiedPlayer(Private)

/// Notify delegates that the current song has progressed ~1 sec.
- (void) _updateProgress {
    progress += 1.0;
    [delegate updateProgress:progress andDuration:duration];
}

/// Notify delegates that the current song has ended.
- (void) _playerSongEnd:(NSNotification *)notification {
    [delegate songDidEnd];
}
@end

#pragma mark - Public methods

@implementation UnifiedPlayer

@synthesize progress, duration, delegate;
@synthesize isPlayingLocal;

+ (Rdio *)rdioInstance {
    return rdio;
}

- (id) init {
    // Create new instance of RDIO player if it hasn't been initialized yet
    if( self = [super init] ) {

        if( audioPlayer == nil ) {
            audioPlayer = [[AVQueuePlayer alloc] init];
        }
        
        if( rdio == nil ) {
            rdio = [[Rdio alloc] initWithConsumerKey:RDIO_KEY andSecret:RDIO_SEC delegate:self];
        }
        
        isPlayingLocal = NO;
        
        // Setup AVAudioSession
        [[AVAudioSession sharedInstance] setDelegate:self];
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error: nil];
        UInt32 doSetProperty = 0;
        AudioSessionSetProperty (
                                 kAudioSessionProperty_OverrideCategoryMixWithOthers,
                                 sizeof (doSetProperty),
                                 &doSetProperty
                                 );
        
        NSError *activationError = nil;
        [[AVAudioSession sharedInstance] setActive:YES error: &activationError];
    }
    
    return self;
}

#pragma mark - Player actions/status

- (BOOL) isPaused {
    
    if( currentTrack == nil ) {
        return YES;
    }
    
    // Check the specific player to see if it's paused
    if( [currentTrack isRdio] && !isPlayingLocal ) {
        
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
    
    if( [currentTrack isRdio] && !isPlayingLocal ) {
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
    
    isPlayingLocal = NO;
    currentTrack = track;
    
    // Stop playing the current song.
    [self stop];

    progress = 0.0;
    duration = 0.0;
    [progressTimer invalidate];
    
    //--// First check if the user has this track on their iPod.
    MPMediaQuery *query = [MPMediaQuery songsQuery];
    
    // Query for artist and song title
    // NOTE: MUST BE AN EXACT MATCH FOR IT TO WORK
    [query addFilterPredicate: [MPMediaPropertyPredicate predicateWithValue: [currentTrack artist]
                                                                forProperty: MPMediaItemPropertyArtist]];
    [query addFilterPredicate: [MPMediaPropertyPredicate predicateWithValue: [currentTrack songTitle]
                                                                forProperty: MPMediaItemPropertyTitle]];
    
    NSArray *songs = [query items];
    BOOL inUserLibrary = [songs count] > 0;
    
    if( !inUserLibrary ) {
        NSLog( @"[UnifiedPlayer] COULD NOT FIND %@ - %@", [currentTrack artist], [currentTrack songTitle] );
    }
    
    //--// If the song exists in the user's library, play the song from the library
    if( inUserLibrary ) {
        
        MPMediaItem *song = [songs objectAtIndex:0];
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL: [song valueForProperty: MPMediaItemPropertyAssetURL]];
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
        
        isPlayingLocal = YES;
    
    //--// Otherwise attempt to stream from RDIO/another location.
    } else if( [currentTrack isRdio] && [currentTrack rdioId] != nil && 
              ![[currentTrack rdioId] isEqual: [NSNull null]] && [[currentTrack rdioId] length] > 0 ) {
        
        [[rdio player] playSource:[currentTrack rdioId]];
        [[rdio player] addObserver:self forKeyPath:@"position" options:NSKeyValueChangeReplacement context:nil];
    
    //--// Finally, attempt to stream from a local stream (if available). Different from the local file check above.
    //--// This will eventually point to cached copies, etc.
    } else if( [currentTrack stream] ) {
        
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
    } else {
        // If for some reason we can't play this song, pretend the song ended so that the playlist can continue
        // to the next song on the playlist.
        [self _playerSongEnd:nil];
    }
}

#pragma mark - AVAudioSessionDelegate methods
- (void) beginInterruption {
    // Handle music session interruption ( phone call, etc ).
    if( ![self isPaused] ) {
        
        [self togglePause];
        interruptedWhilePlaying = TRUE;
        
    } else {
        
        interruptedWhilePlaying = FALSE;
        
    }
}

- (void) endInterruption {
    
    if( interruptedWhilePlaying ) {
        [self togglePause];
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
