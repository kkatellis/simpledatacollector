//
//  FeedViewController.h
//  rockmyworld
//
//  Created by Andrew Huynh on 11/28/11.
//  Copyright (c) 2011 athlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedViewController : UIViewController<UISearchBarDelegate> {
    UIScrollView *activityFeed, *popularFeed, *friendFeed;
}

@property (nonatomic,retain) IBOutlet UIScrollView *activityFeed;
@property (nonatomic,retain) IBOutlet UIScrollView *popularFeed;
@property (nonatomic,retain) IBOutlet UIScrollView *friendFeed;

@end
