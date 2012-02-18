//
//  TrackInfo.h
//  rockmyworld
//
//  Created by Andrew Huynh on 11/30/11.
//  Copyright (c) 2011 athlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RMWSongProgress.h"

@interface TrackInfoView : UIView {
    UILabel *artist, *songTitle;
    
    RMWSongProgress * progress;
}

@property ( nonatomic, retain ) IBOutlet UILabel *artist;
@property ( nonatomic, retain ) IBOutlet UILabel *songTitle;
@property ( nonatomic, retain ) IBOutlet RMWSongProgress *progress;

@end
