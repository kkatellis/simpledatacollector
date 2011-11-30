//
//  NavigationMenu.h
//  rockmyworld
//
//  Created by Andrew Huynh on 11/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavigationMenu : UIViewController<UITableViewDelegate, UITableViewDataSource> {
    UITableView *navTable;
    
    NSMutableArray *profileSection, *historySection, *feedSection;
    
    NSArray *profileSectionIcons, *feedSectionIcons;
}

@property (nonatomic,retain) IBOutlet UITableView *navTable;

@end