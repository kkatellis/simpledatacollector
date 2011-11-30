//
//  AlbumCellView.h
//  rockmyworld
//
//  Created by Andrew Huynh on 11/14/11.
//  Copyright (c) 2011 athlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumCellView : UITableViewCell {
    UIView *songInfoBar;
    UIImage *albumArt;
    
    BOOL isCurrentlyPlaying;
}

@property (nonatomic, retain) IBOutlet UIView *songInfoBar;
@property (nonatomic, retain) UIImage *albumArt;

@property (nonatomic, assign) BOOL isCurrentlyPlaying;

@end
