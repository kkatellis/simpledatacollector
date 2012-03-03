//
//  ActivityViewController.h
//  rockmyworld
//
//  Created by Andrew Huynh on 11/16/11.
//  Copyright (c) 2011 athlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface ActivityViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource,
                                                     UITableViewDelegate, UITableViewDataSource>  
{
    NSMutableArray *activityHistory;
    UITableView *activityHistoryTable;
    
    UIButton *currentActivityButton;
}

@property (nonatomic, retain) IBOutlet UIViewController *activityPickerView;

@property (nonatomic, retain) IBOutlet UIButton *currentActivityButton;

//--// Activity History
@property (nonatomic, retain) IBOutlet NSMutableArray *activityHistory;
@property (nonatomic, retain) IBOutlet UITableView *activityHistoryTable;

- (void) updateActivity:(NSString*) activity;

// Button actions
- (IBAction) toggleActivityView:(id)sender;

- (IBAction) selectActivities:(id)sender;
- (IBAction) hideSelectActivities:(id)sender;

@end
