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
    NSArray             *selectedLevel;
    NSMutableArray      *pickedActivityFrequency;
    NSMutableArray      *topActivities;
    NSMutableArray      *previousLevel;
    NSString            *selectedActivity;
    
    BOOL isIncorrectActivity, isGoodSongForActivity, isActivityTableUsed;
    
    UITableView *activityTable;
    
    //--// Current activity vars
    NSString    *currentActivity;
    UIImageView *currentActivityIcon;
    UILabel     *currentActivityLabel;
    
    //-// Mood Table and Feedback Related Variables
    NSArray         *moodList;
    NSMutableArray  *pickedMoodFrequency;
    NSMutableArray  *topMoods;
    NSString        *selectedMood;
    
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

- (void) updateActivity:(NSString*) activity;

//--// Feedback question navigation
- (IBAction) incorrectActivity:(id)sender;
- (IBAction) showSongQuestion:(id)sender;
- (IBAction) showMoodQuestion:(id)sender;
- (IBAction) isGoodSong:(id)sender;
- (IBAction) isBadSong:(id)sender;
- (IBAction) isGoodSongMood:(id)sender;
- (IBAction) isBadSongMood:(id)sender;

//--// Activit Data Update
- (void) findTopActivity;
- (void) findTopMood;
- (BOOL) updateUsage: (NSMutableArray*)frequencyTable;


@end
