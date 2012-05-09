//
//  SoundWaveProcessor.h
//  Sensor_Accessor
//
//  Created by Peter Zhao on 4/5/12.
//  Copyright (c) 2012 CALab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@interface SoundWaveProcessor : NSObject <AVAudioRecorderDelegate> {
    
    AVAudioSession  *ourSession;
    AVAudioRecorder *lfRecorder, *hfRecorder;
    NSURL           *soundFileURL;
}

@property (nonatomic, retain) AVAudioRecorder   *lfRecorder;
@property (nonatomic, retain) AVAudioRecorder   *hfRecorder;
@property (nonatomic, retain) NSURL             *soundFileURL;

+ (NSString*) hfSoundFileName;

- (void) startRecording;
- (void) pauseRecording;

- (void) startHFRecording;
- (void) pauseHFRecording;

@end
