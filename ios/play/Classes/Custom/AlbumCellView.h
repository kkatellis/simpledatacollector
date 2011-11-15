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
    UIImageView *albumArt;
}

@property (nonatomic, retain) IBOutlet UIView *songInfoBar;
@property (nonatomic, retain) IBOutlet UIImageView *albumArt;

@end
