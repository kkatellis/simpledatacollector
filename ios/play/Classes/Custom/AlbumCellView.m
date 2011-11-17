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

@synthesize songInfoBar, albumArt;

- (void) awakeFromNib {
        
    // Setup the drop shadow
    self.albumArt.layer.shadowColor = [UIColor blackColor].CGColor;
    self.albumArt.layer.shadowOffset = CGSizeMake(2, 2);
    self.albumArt.layer.shadowOpacity = .8;
    self.albumArt.layer.shadowRadius = 1.0;
    self.albumArt.clipsToBounds = NO;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
}

@end
