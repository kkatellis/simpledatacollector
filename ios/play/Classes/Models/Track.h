//
//  Track.h
//  rockmyworld
//
//  Created by Andrew Huynh on 11/30/11.
//  Copyright (c) 2011 athlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Track : NSObject {
    UIImage *albumArt;
    
    NSString *artist, *songTitle;
    
    NSURL *stream;
}

@property (nonatomic, retain) UIImage *albumArt;
@property (nonatomic, copy) NSString *artist;
@property (nonatomic, copy) NSString *songTitle;
@property (nonatomic, retain) NSURL *stream;

@end
