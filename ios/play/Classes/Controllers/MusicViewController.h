//
//  MusicViewController.h
//  play
//
//  Created by Andrew Huynh on 11/14/11.
//  Copyright (c) 2011 athlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MusicViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
    UITableView *table;
}

@property (nonatomic,retain) IBOutlet UITableView *table;

- (void) centerCurrentlyPlaying;

@end
