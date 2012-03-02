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
    return self;
}

#pragma mark - View functions

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
}

- (void) drawRect: (CGRect) rect {
    // Add padding to left and draw image.
    CGRect albumRect = CGRectMake( 10, 0, 300, 300 );
    [albumArt drawInRect:albumRect blendMode:kCGBlendModeNormal alpha:1.0];
    
    if( !isCurrentlyPlaying ) {
        CGRect playBtnRect = CGRectMake( 96, 86, 128, 128 );
        [[UIImage imageNamed:@"play_btn"] drawInRect:playBtnRect];
    }
}

@end
