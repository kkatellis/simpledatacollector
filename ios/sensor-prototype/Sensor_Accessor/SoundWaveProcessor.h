//
//  SoundWaveProcessor.h
//  Sensor_Accessor
//
//  Created by Peter Zhao on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@interface SoundWaveProcessor : NSObject
{
    AVAudioSession  *mySession;
    AVAudioRecorder *myRecorder;
    
    bool            isRecording;
    NSURL           *soundFileURL;
    NSDictionary    *recordSettings;
    
    NSTimer         *recordTimer;
    
}

@property (nonatomic, retain) AVAudioSession    *mySession;
@property (nonatomic, retain) AVAudioRecorder   *myRecorder;

@property (nonatomic, retain) NSURL             *soundFileURL;

-(void) startRecording;
-(void) endRecording;

@end
