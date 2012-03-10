//
//  SDImageInfo.m
//  SDWebImage
//
//  Created by Andrew Huynh on 3/2/12.
//  Copyright (c) 2012 Dailymotion. All rights reserved.
//

#import "SDImageInfo.h"

@implementation SDImageInfo

@synthesize image, imageURL;

- (id) initWithImage:(UIImage*)img andURL:(NSURL*) url {
    
    if( self = [super init] ) {
        
        [self setImage:img];
        [self setImageURL:url];
        return self;
    }
    
    return nil;
}

@end
