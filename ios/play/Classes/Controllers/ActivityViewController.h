//
//  ActivityViewController.h
//  rockmyworld
//
//  Created by Andrew Huynh on 11/16/11.
//  Copyright (c) 2011 athlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityViewController : UIViewController<UIPickerViewDelegate,
                                                    UITableViewDelegate, UITableViewDataSource,
                                                    UIScrollViewDelegate> 
{
    //-// Activity history
    NSMutableArray *activityHistory;    
    
    //-// Activity hierarchy related vars
    NSMutableDictionary *activityHierarchy;
    NSMutableDictionary *selectedLevel;
    NSMutableArray *previousLevel;
    NSString *selectedActivity;
    
    BOOL isIncorrectActivity, isGoodSongForActivity;
    
    //--// Current activity vars
    NSString *currentActivity;
    UIImageView *currentActivityIcon;
    UILabel *currentActivityLabel;
    
    //--// Feedback related stuff
    UIView *activityQuestion, *selectActivityQuestion, *songQuestion;
    UIImageView *currentAlbumArt;
    UIPageControl *questionPage;
    UIScrollView *questionView;    
}

//--// Activity History
@property (nonatomic, retain) NSString *currentActivity;
@property (nonatomic, retain) IBOutlet UIImageView *currentActivityIcon;
@property (nonatomic, retain) IBOutlet UILabel *currentActivityLabel;

//--// Feedback questions
@property (nonatomic, retain) IBOutlet UIView *activityQuestion;
@property (nonatomic, retain) IBOutlet UIView *selectActivityQuestion;
@property (nonatomic, retain) IBOutlet UIView *songQuestion;
@property (nonatomic, retain) IBOutlet UIPageControl *questionPage;
@property (nonatomic, retain) IBOutlet UIScrollView *questionView;
@property (nonatomic, retain) IBOutlet UIImageView *currentAlbumArt;

- (void) updateActivity:(NSString*) activity;

// Button actions
- (IBAction) toggleActivityView:(id)sender;

//--// Feedback question navigation
- (IBAction) incorrectActivity:(id)sender;
- (IBAction) showSongQuestion:(id)sender;
- (IBAction) isGoodSong:(id)sender;

@end
