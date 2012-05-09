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
        
        ourSession = [AVAudioSession sharedInstance];
        [ourSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [ourSession setActive:YES error:nil];
        
        //--// Grab the user document's directory
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *dataPath = [fileManager URLForDirectory: NSDocumentDirectory 
                                              inDomain: NSUserDomainMask 
                                     appropriateForURL: nil 
                                                create: YES 
                                                 error: nil];

        soundFileURL = [NSURL fileURLWithPath:[[dataPath path] stringByAppendingPathComponent:HF_SOUND_FILE]];
        
        //--// Initialize low freq recorder
        // LF has to use uncompressed audio if we want HF to use compressed audio.
        NSDictionary *recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithFloat: 44100.0],              AVSampleRateKey,
                                        [NSNumber numberWithInt: kAudioFormatLinearPCM],  AVFormatIDKey,
                                        [NSNumber numberWithInt: 1],                      AVNumberOfChannelsKey, nil]; 
        
        NSError *lferror = nil;
        lfRecorder = [[AVAudioRecorder alloc] initWithURL: soundFileURL
                                                 settings: recordSettings 
                                                    error: &lferror];
        if( lferror != nil ) {
            NSLog( @"[SoundWaveProcessor] ERROR: %@", [lferror localizedDescription] );
        }
        
        lfRecorder = [[AVAudioRecorder alloc] initWithURL: [NSURL fileURLWithPath: LF_SOUND_FILE]
                                                 settings: recordSettings 
                                                    error: &lferror];
        
<<<<<<< HEAD
        // See here: http://developer.apple.com/library/ios/#DOCUMENTATION/AudioVideo/Conceptual/MultimediaPG/UsingAudio/UsingAudio.html
        // for why we need to use AppleIMA4 versus MPEG4AAC when recording.
        //
        // Important Excerpt: 
        //      For AAC, MP3, and ALAC (Apple Lossless) audio, decoding can take place using hardware-assisted codecs. 
        //      While efficient, this is limited to one audio stream at a time. If you need to play multiple sounds 
        //      simultaneously, store those sounds using the IMA4 (compressed) or linear PCM (uncompressed) format.
        //
        recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithFloat: 44100.0],            AVSampleRateKey,
                            [NSNumber numberWithInt: kAudioFormatAppleIMA4], AVFormatIDKey,
                            [NSNumber numberWithInt: 1],                    AVNumberOfChannelsKey,
                            [NSNumber numberWithInt: AVAudioQualityMedium], AVEncoderAudioQualityKey, nil];    
        
        NSError *error = nil;
=======
        
        //--// Initialize high freq recorder
        recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
                            [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                            [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
                            [NSNumber numberWithInt: AVAudioQualityMedium],      AVEncoderAudioQualityKey, nil];    

        NSError *hferror = nil;
>>>>>>> Recorder Bug Fix
        hfRecorder = [[AVAudioRecorder alloc] initWithURL: soundFileURL
                                                 settings: recordSettings 
                                                    error: &hferror];
        if( hferror != nil ) {
            NSLog( @"[SoundWaveProcessor] ERROR: %@", [hferror localizedDescription] );
        }
        
        [lfRecorder setDelegate:self];
        [hfRecorder setDelegate:self];
        
        lfRecorder.meteringEnabled = YES;
        hfRecorder.meteringEnabled = YES;
        
        [lfRecorder prepareToRecord];
        [hfRecorder prepareToRecord];

    }
    return self;
}

- (void) startRecording {
    [lfRecorder recordForDuration:LF_SAMPLE_LENGTH];
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
