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

@synthesize songInfoBar, albumArt, isCurrentlyPlaying, artist, title;

- (void) awakeFromNib {
    [self setOpaque:YES];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if( self != nil ) {
            
        artist = nil;
        title  = nil;
        
    }
    
    return self;
}

#pragma mark - View functions

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
}

- (void) drawRect: (CGRect) rect {
    // Add padding to left and draw image.
    CGRect albumRect = CGRectMake( 10, 0, 300, 300 );
    
    if( albumArt ) {
        [albumArt drawInRect:albumRect blendMode:kCGBlendModeNormal alpha:1.0];
    } else {
        [[UIImage imageNamed:@"album-art"] drawInRect:albumRect];
    }
    
    if( !isCurrentlyPlaying ) {
        [[UIImage imageNamed:@"play_btn"] drawInRect:albumRect];
    }    
    
    
    if( artist && title && !isCurrentlyPlaying ) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGRect infoRect = CGRectMake( 10, 0, 300, 70 );
        
        CGContextFillRect( context, infoRect );
        
        CGContextSetFillColorWithColor( context, [UIColor whiteColor].CGColor );
        
        infoRect.origin.x += 10;
        infoRect.origin.y += 10;
        
        UIFont *font = [UIFont fontWithName:@"Helvetica" size:16.0];
        
        [artist drawInRect:infoRect withFont:font];
        
        CGContextSetFillColorWithColor( context, [UIColor colorWithRed:0 green:0.5 blue:1.0 alpha:1.0].CGColor );
        infoRect.origin.y += 24;
        [title drawInRect:infoRect withFont:font];
        
    }
}

@end
