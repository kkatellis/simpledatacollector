//
//  AlbumCellView.m
//  rockmyworld
//
//  Created by Andrew Huynh on 11/14/11.
//  Copyright (c) 2011 athlabs. All rights reserved.
//

#import "AlbumCellView.h"
#import "QuartzCore/CALayer.h"

@implementation AlbumCellView

@synthesize songInfoBar, albumArt, isCurrentlyPlaying;

- (void) awakeFromNib {
    [self setOpaque:YES];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

#pragma mark - Asynchronous Album Art loading

- (void) loadAlbumArt:(NSString *)url {
    if( url == nil ) {
        [self setAlbumArt:[UIImage imageNamed:@"album-art"]];
        return;
    }
    
    NSURL *artURL = [NSURL URLWithString:url];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];        
    [manager cancelForDelegate:self];
    
    // Check if the image is cached
    UIImage *image = [manager imageWithURL:artURL];
    if( image != nil ) {
        [self setAlbumArt:image];
    } else {
        [manager downloadWithURL:artURL delegate:self];
    }
    
}

- (void) webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image {
    if( self.albumArt == nil ) {
        [self setAlbumArt:image];
    }
}

#pragma mark - View functions

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
}

- (void) drawRect: (CGRect) rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetShadow(context, CGSizeMake(2, 2), 1.0 );
    
    // Add padding to left and draw image.
    CGRect albumRect = CGRectMake( 10, 0, 300, 300 );

    if( isCurrentlyPlaying ) {
        [albumArt drawInRect:albumRect blendMode:kCGBlendModeNormal alpha:1.0];
    } else {
        [albumArt drawInRect:albumRect blendMode:kCGBlendModeNormal alpha:0.5];
    }
}

@end
