//
//  SoundWaveProcessor.h
//  Sensor_Accessor
//
//  Created by Peter Zhao on 4/5/12.
//  Copyright (c) 2012 CALab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@interface SoundWaveProcessor : NSObject {
    AVAudioRecorder *myRecorder;
    
    bool            isRecording;
    NSURL           *soundFileURL;
    NSDictionary    *recordSettings;
    
    NSTimer         *recordTimer;
    
}

@property (nonatomic, retain) AVAudioRecorder   *myRecorder;
@property (nonatomic, retain) NSURL             *soundFileURL;

-(void) startRecording;
-(void) pauseRecording;
-(void) endRecording;

@end
