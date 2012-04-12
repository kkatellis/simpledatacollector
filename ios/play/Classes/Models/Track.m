//
//  Track.m
//  rockmyworld
//
//  Created by Andrew Huynh on 11/30/11.
//  Copyright (c) 2011 athlabs. All rights reserved.
//

#import "Track.h"

@implementation Track

@synthesize dbid, artist, songTitle, stream, albumArt, rdioId;

- (id) init {
    self = [super init];
    
    if( self != nil ) {
        dbid = nil;
        rdioId = nil;
        artist = nil;
        songTitle = nil;
        stream = nil;
        albumArt = nil;
    }
    
    return self;
}

- (BOOL) isRdio {
    return rdioId != nil;
}

@end
