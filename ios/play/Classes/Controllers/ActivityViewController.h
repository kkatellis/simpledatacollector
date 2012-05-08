//
//  ActivityViewController.h
//  rockmyworld
//
//  Created by Andrew Huynh on 11/16/11.
//  Copyright (c) 2011 athlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityViewController : UIViewController<UIPickerViewDelegate, 
                                                     UITableViewDelegate, 
                                                     UITableViewDataSource,
                                                     UIScrollViewDelegate> 
{
    //-// Activity history
    NSMutableArray *activityHistory;    
    
    //-// Activity list related vars
    NSMutableArray  *activityList;
    NSMutableArray  *recentActivities;
    NSString        *selectedActivity;
    
    //-// Mood list related
    NSMutableArray  *moodList;
    NSMutableArray  *recentMoods;
    NSString        *selectedMood;
    
    BOOL isIncorrectActivity, isGoodSongForActivity, isActivityTableUsed;
    
    UITableView *activityTable;
    
    //--// Current activity vars
    NSString    *currentActivity;
    UIImageView *currentActivityIcon;
    UILabel     *currentActivityLabel;
        
    UITableView     *moodTable;
    
    BOOL isGoodSongForMood, isMoodTableUsed;
    
    //--// Feedback related stuff
    UIView *activityQuestion, *selectActivityQuestion, *songQuestion;
    NSString *currentSong;
    UIImageView *currentAlbumArtActivity;
    UIImageView *currentAlbumArtMood;
    UIPageControl *questionPage;
    UIScrollView *questionView;  
    UILabel *songQuestionLabel;
    UILabel *moodQuestionLabel;
    UILabel *songNameActivity;
    UILabel *artistNameActivity;
    UILabel *songNameMood;
    UILabel *artistNameMood;
}

//--// Activity History
@property (nonatomic, retain) NSString *currentActivity;
@property (nonatomic, retain) IBOutlet UIImageView *currentActivityIcon;
@property (nonatomic, retain) IBOutlet UILabel *currentActivityLabel;

//--// Feedback questions
@property (nonatomic, retain) IBOutlet UITableView *activityTable;
@property (nonatomic, retain) IBOutlet UITableView *moodTable;
@property (nonatomic, retain) IBOutlet UIView *activityQuestion;
@property (nonatomic, retain) IBOutlet UIView *selectActivityQuestion;
@property (nonatomic, retain) IBOutlet UIView *songQuestion;
@property (nonatomic, retain) IBOutlet UIView *selectMoodQuestion;
@property (nonatomic, retain) IBOutlet UIView *songQuestionMood;
@property (nonatomic, retain) IBOutlet UIPageControl *questionPage;
@property (nonatomic, retain) IBOutlet UIScrollView *questionView;
@property (nonatomic, retain) IBOutlet UIImageView *currentAlbumArtActivity;
@property (nonatomic, retain) IBOutlet UIImageView *currentAlbumArtMood;
@property (nonatomic, retain) IBOutlet UILabel *songQuestionLabel;
@property (nonatomic, retain) IBOutlet UILabel *moodQuestionLabel;
@property (nonatomic, retain) IBOutlet UILabel *songNameActivity;
@property (nonatomic, retain) IBOutlet UILabel *artistNameActivity;
@property (nonatomic, retain) IBOutlet UILabel *songNameMood;
@property (nonatomic, retain) IBOutlet UILabel *artistNameMood;

- (void) updateActivity:(NSString*) activity;

//--// Feedback question navigation
- (IBAction) incorrectActivity:(id)sender;
- (IBAction) showSongQuestion:(id)sender;
- (IBAction) showMoodQuestion:(id)sender;
- (IBAction) isGoodSong:(id)sender;
- (IBAction) isBadSong:(id)sender;
- (IBAction) isGoodSongMood:(id)sender;
- (IBAction) isBadSongMood:(id)sender;

@end
