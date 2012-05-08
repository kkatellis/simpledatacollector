//
//  SoundWaveProcessor.m
//  Sensor_Accessor
//
//  Created by Peter Zhao on 4/5/12.
//  Copyright (c) 2012 CALab. All rights reserved.
//

#import "SoundWaveProcessor.h"

#define HF_SOUND_FILE   @"HF_SOUNDWAVE"
#define LF_SOUND_FILE   @"/dev/null"

// In seconds
#define LF_SAMPLE_LENGTH    5 

@implementation SoundWaveProcessor

@synthesize soundFileURL;
@synthesize lfRecorder, hfRecorder;

+ (NSString*) hfSoundFileName {
    return HF_SOUND_FILE;
}

- (id)init {
    self = [super init];

    if (self) {
        //--// Initializing an audio session & start our session
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        
        //--// Grab the user document's directory
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *dataPath = [fileManager URLForDirectory: NSDocumentDirectory 
                                              inDomain: NSUserDomainMask 
                                     appropriateForURL: nil 
                                                create: YES 
                                                 error: nil];

        soundFileURL = [NSURL fileURLWithPath:[[dataPath path] stringByAppendingPathComponent:HF_SOUND_FILE]];
        
        //--// Initialize low and high freq recorders
        // LF has to use uncompressed audio if we want HF to use compressed audio.
        NSDictionary *recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithFloat: 44100.0],              AVSampleRateKey,
                                        [NSNumber numberWithInt: kAudioFormatLinearPCM],  AVFormatIDKey,
                                        [NSNumber numberWithInt: 1],                      AVNumberOfChannelsKey, nil]; 
        
        lfRecorder = [[AVAudioRecorder alloc] initWithURL: [NSURL fileURLWithPath: LF_SOUND_FILE]
                                                 settings: recordSettings 
                                                    error: nil];
        
        recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithFloat: 44100.0],            AVSampleRateKey,
                            [NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                            [NSNumber numberWithInt: 1],                    AVNumberOfChannelsKey,
                            [NSNumber numberWithInt: AVAudioQualityMedium], AVEncoderAudioQualityKey, nil];    

        NSError *error = nil;
        hfRecorder = [[AVAudioRecorder alloc] initWithURL: soundFileURL
                                                 settings: recordSettings 
                                                    error: &error];
        if( error != nil ) {
            NSLog( @"[SoundWaveProcessor] ERROR: %@", [error localizedDescription] );
        }
        
        lfRecorder.meteringEnabled = YES;
        hfRecorder.meteringEnabled = YES;
        [lfRecorder prepareToRecord];
        [hfRecorder prepareToRecord];

    }
    return self;
}

- (void) startRecording {
    [lfRecorder recordForDuration: LF_SAMPLE_LENGTH];
}

- (void) pauseRecording {
    [lfRecorder stop];
}

- (void) startHFRecording {   
    
    if( ![hfRecorder isRecording] ) {
        [hfRecorder record];
    }
    
}

- (void) pauseHFRecording {
    [hfRecorder stop];
}

@end
