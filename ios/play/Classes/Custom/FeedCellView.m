//
//  FeedCellView.m
//  rockmyworld
//
//  Created by Andrew Huynh on 11/30/11.
//  Copyright (c) 2011 athlabs. All rights reserved.
//

#import "FeedCellView.h"

@implementation FeedCellView

@synthesize albumArt;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) drawRect: (CGRect) rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetShadow(context, CGSizeMake(2, 2), 1.0 );
    
    // Add padding to left and draw image.
    CGRect albumRect = CGRectMake( 4, 4, 80, 80 );
    [albumArt drawInRect:albumRect];
}

@end
