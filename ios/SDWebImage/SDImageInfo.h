//
//  SDImageInfo.h
//  SDWebImage
//
//  Created by Andrew Huynh on 3/2/12.
//  Copyright (c) 2012 athlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIImage;

@interface SDImageInfo : NSObject {
    UIImage *image;
    NSURL *imageURL;
}

@property (nonatomic,retain) UIImage *image;
@property (nonatomic,retain) NSURL *imageURL;

- (id) initWithImage:(UIImage*)img andURL:(NSURL*) url;

@end
