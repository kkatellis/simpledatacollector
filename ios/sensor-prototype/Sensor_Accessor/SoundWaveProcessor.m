//
//  SoundWaveProcessor.m
//  Sensor_Accessor
//
//  Created by Peter Zhao on 4/5/12.
//  Copyright (c) 2012 CALab. All rights reserved.
//

#import "SoundWaveProcessor.h"

@implementation SoundWaveProcessor

@synthesize soundFileURL;
@synthesize myRecorder;

- (id)init {
    self = [super init];

    if (self) {
        
        //Determine if session is recording
        isRecording = NO;
        
        //Initializing an audio session & start our session
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        
        //Creating an available sound datapath
        NSArray *tempDirPaths;
        NSString *tempDocsDir;
        
        tempDirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        tempDocsDir = [tempDirPaths objectAtIndex:0];
        
        NSString *soundFilePath = [tempDocsDir stringByAppendingPathComponent:@"soundWave"];
        
        soundFileURL = [NSURL fileURLWithPath:soundFilePath];
        recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
                          [NSNumber numberWithInt: kAudioFormatMPEG4AAC],      AVFormatIDKey,
                          [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
                          [NSNumber numberWithInt: AVAudioQualityMedium],         AVEncoderAudioQualityKey,
                          nil];    
        
        //Initializing our audio recorder
        myRecorder = [[AVAudioRecorder alloc] initWithURL:soundFileURL settings:recordSettings error:nil];
        myRecorder.meteringEnabled = YES;
        
        if( ![myRecorder prepareToRecord] ) {
            NSLog( @"FAILED PREPARATION" );
        }        
    }
    return self;
}

-(void) startRecording{
    
    isRecording = YES;
                
    [myRecorder prepareToRecord];
    [myRecorder record];
    
    // Stops after 5 seconds
    recordTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(endRecording) userInfo:nil repeats:NO];    
}

-(void) pauseRecording {
    [recordTimer invalidate];
    isRecording = NO;
    [myRecorder stop];
}

-(void) endRecording {
    [recordTimer invalidate];
    isRecording = NO;
    [myRecorder stop];
}

@end
