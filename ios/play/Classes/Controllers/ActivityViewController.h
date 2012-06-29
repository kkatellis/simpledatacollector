//
//  ActivityViewController.h
//  rockmyworld
//
//  Created by Andrew Huynh on 11/16/11.
//  Copyright (c) 2011 athlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVSegmentedControl.h"

@interface ActivityViewController : UIViewController<UIPickerViewDelegate, 
                                                     UITableViewDelegate, 
                                                     UITableViewDataSource,
                                                     UIScrollViewDelegate> 
{
    //--// Feedback parameters
    BOOL            isGoodSongForActivity;          // Is the current song a good match for the user's current activity?
    BOOL            isGoodSongForMood;              // Is the current song a good match for the user's current mood?
    NSString        *selectedMood;                  // Mood selected by the user
    NSMutableArray  *selectedActivities;            // Activities selected by the user
 
    //-// Activity list related vars
    NSMutableArray      *activityList;              // All activities
    NSMutableArray      *recentActivities;          // Recently selected activities
    NSMutableDictionary *associatedActivities;      // "Cold Start" list for associated activites
    NSMutableDictionary *recentAssociatedActivities;// "Recent Associated Activity" list for multi-select page
        
    //-// Mood list related
    NSMutableArray  *moodList;                      // List of all moods
    NSMutableArray  *recentMoods;                   // Recently selected moods
    
    NSString        *currentActivity;               // The current predicted activity
    NSString        *currentSong;                   // The title of the current song playing
    UIImageView     *currentAlbumArt;               // The album art of the current song playing.
    UILabel         *songName, *artistName;
    
    UITableView     *activityTable, *moodTable, *multiActivityTable;

    UISlider        *dontBotherSlider;
    UILabel         *dontBotherAmount;
    
    //--// Feedback related stuff
    BOOL               isSilent, isGivingFeedback;
    UIView             *activityQuestionView, *moodQuestionView;
    UIView             *goodSongForActivityControl, *goodSongForMoodControl;
    SVSegmentedControl *activityControl, *moodControl;
    
    UIView  *selectActivityQuestion, *selectMoodQuestion;
    UILabel *selectedActivitiesLabel, *selectedMoodLabel;
    
    NSMutableDictionary *feedback;
}

@property (nonatomic, assign) BOOL isSilent;

@property (nonatomic, retain) IBOutlet UISlider     *dontBotherSlider;
@property (nonatomic, retain) IBOutlet UILabel      *dontBotherAmount;

//--// Current activity setters/getters
@property (nonatomic, copy) NSString* currentActivity;
@property (nonatomic, retain) IBOutlet UIImageView  *currentAlbumArt;
@property (nonatomic, retain) IBOutlet UILabel      *songName;
@property (nonatomic, retain) IBOutlet UILabel      *artistName;

//--// Activity/mood tables
@property (nonatomic, retain) IBOutlet UITableView *activityTable;
@property (nonatomic, retain) IBOutlet UITableView *moodTable;
@property (nonatomic, retain) IBOutlet UITableView *multiActivityTable;

//--// Feedback question views
@property (nonatomic, retain) IBOutlet UIView *goodSongForActivityControl;
@property (nonatomic, retain) IBOutlet UIView *goodSongForMoodControl;
@property (nonatomic, retain) IBOutlet UIView *activityQuestionView;
@property (nonatomic, retain) IBOutlet UIView *moodQuestionView;

@property (nonatomic, retain) IBOutlet UILabel *selectedActivitiesLabel;
@property (nonatomic, retain) IBOutlet UILabel *selectedMoodLabel;

@property (nonatomic, retain) IBOutlet UIView *selectActivityQuestion;
@property (nonatomic, retain) IBOutlet UIView *multipleActivities;
@property (nonatomic, retain) IBOutlet UIView *selectMoodQuestion;

- (void) updateActivity:(NSString*) activity;

- (NSDictionary*) feedbackValues;

- (IBAction) dontBotherTimerUpdated:(UISlider*)sender;

//--// Feedback question navigation
- (IBAction) finishFeedback:(id)sender;
- (IBAction) showActivitiesSelector:(id)sender;
- (IBAction) finishedSelectingActivities:(id)sender;
- (IBAction) showMoodSelector:(id)sender;

@end
