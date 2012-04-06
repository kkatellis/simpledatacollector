//
//  SoundWaveProcessor.m
//  Sensor_Accessor
//
//  Created by Peter Zhao on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SoundWaveProcessor.h"

@implementation SoundWaveProcessor

@synthesize soundFileURL;
@synthesize mySession, myRecorder;

- (id)init
{
    self = [super init];
    if (self) {
        
        //Determine if session is recording
        isRecording = NO;
        
        //Initializing an audio session
        mySession = [AVAudioSession sharedInstance];
        [mySession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
        //Creating an available sound datapath
        NSArray *tempDirPaths;
        NSString *tempDocsDir;
        
        tempDirPaths = NSSearchPathForDirectoriesInDomains(
                                                       NSDocumentDirectory, NSUserDomainMask, YES);
        tempDocsDir = [tempDirPaths objectAtIndex:0];
        
        NSString *soundFilePath = [tempDocsDir
                                   stringByAppendingPathComponent:@"soundWave"];
        
        soundFileURL = [NSURL fileURLWithPath:soundFilePath];
        recordSettings = [NSDictionary 
                                        dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithInt:AVAudioQualityMin],
                                        AVEncoderAudioQualityKey,
                                        [NSNumber numberWithInt:16], 
                                        AVEncoderBitRateKey,
                                        [NSNumber numberWithInt: 2], 
                                        AVNumberOfChannelsKey,
                                        [NSNumber numberWithFloat:44100.0], 
                                        AVSampleRateKey,
                                        nil];
        
        //Initializing our audio recorder
        myRecorder = [[AVAudioRecorder alloc] initWithURL:soundFileURL settings:recordSettings error:nil];
        
        //ASK!!!! [myRecorder setDelegate:self];
        
        //done with initialization
    }
    return self;
}

-(void) startRecording{
    
    isRecording = YES;
    
    //start our session and start recording
    [mySession setActive:YES error:nil];
    
    [myRecorder prepareToRecord];
    [myRecorder record];
    
    //stops after 5 seconds
    recordTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(endRecording) userInfo:nil repeats:NO];
    
}

-(void) endRecording{
    [recordTimer invalidate];
    isRecording = NO;
    
    [myRecorder stop];
    
}

@end
