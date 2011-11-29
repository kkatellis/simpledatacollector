//
//  FeedViewController.h
//  rockmyworld
//
//  Created by Andrew Huynh on 11/28/11.
//  Copyright (c) 2011 athlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedViewController : UIViewController<UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource> {
    
    UITableView *activityFeed, *popularFeed, *friendFeed;
}

@property (nonatomic,retain) IBOutlet UITableView *activityFeed;
@property (nonatomic,retain) IBOutlet UITableView *popularFeed;
@property (nonatomic,retain) IBOutlet UITableView *friendFeed;

@end
