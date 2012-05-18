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
    //--// Feedback parameters
    BOOL            isIncorrectActivity;            // Did we guess the activity wrong?
    BOOL            isGoodSongForActivity;          // Is the current song a good match for the user's current activity?
    NSString        *selectedMood;                  // Mood selected by the user
    NSMutableArray  *selectedActivities;            // Activities selected by the user
 
    //-// Activity list related vars
    NSMutableArray      *activityList;              // All activities
    NSMutableArray      *recentActivities;          // Recently selected activities
    NSMutableArray      *assocActivityList;         // Array of Associated Activities for each key activity
    NSMutableDictionary *associatedActivities;      // "Recents" list for associated activites.
        
    //-// Mood list related
    NSMutableArray  *moodList;                      // List of all moods
    NSMutableArray  *recentMoods;                   // Recently selected moods
    
    //--// Current activity/song vars
    NSString        *currentActivity;               // The predicted activity
    UIImageView     *currentActivityIcon;           // The icon for the predicted activity
    UILabel         *currentActivityLabel;          // The label for the predicted activity
    
    NSString        *currentSong;                   // The title of the current song playing
    UIImageView     *currentAlbumArtActivity, *currentAlbumMood;    // The album art of the current song playing.
    
    UITableView     *activityTable, *moodTable, *multiActivityTable;
    
    //--// Feedback related stuff
    UIView *activityQuestion, *selectActivityQuestion, *songQuestion;
    NSMutableDictionary *feedback;
    
    UIPageControl   *questionPage;
    UIScrollView    *questionView;  
    
    UILabel         *songQuestionLabel, *moodQuestionLabel;
    UILabel         *songNameActivity, *artistNameActivity;
    UILabel         *songNameMood, *artistNameMood;
}

//--// Current activity setters/getters
@property (nonatomic, copy) NSString* currentActivity;
@property (nonatomic, retain) IBOutlet UIImageView  *currentActivityIcon;
@property (nonatomic, retain) IBOutlet UILabel      *currentActivityLabel;
@property (nonatomic, retain) IBOutlet UIImageView  *currentAlbumArtActivity;
@property (nonatomic, retain) IBOutlet UIImageView  *currentAlbumArtMood;

//--// Activity/mood tables
@property (nonatomic, retain) IBOutlet UITableView *activityTable;
@property (nonatomic, retain) IBOutlet UITableView *moodTable;
@property (nonatomic, retain) IBOutlet UITableView *multiActivityTable;

//--// Feedback question views
@property (nonatomic, retain) IBOutlet UIView *activityQuestion;
@property (nonatomic, retain) IBOutlet UIView *selectActivityQuestion;
@property (nonatomic, retain) IBOutlet UIView *multipleActivities;
@property (nonatomic, retain) IBOutlet UIView *songQuestion;
@property (nonatomic, retain) IBOutlet UIView *selectMoodQuestion;
@property (nonatomic, retain) IBOutlet UIView *songQuestionMood;

@property (nonatomic, retain) IBOutlet UIPageControl *questionPage;
@property (nonatomic, retain) IBOutlet UIScrollView *questionView;

@property (nonatomic, retain) IBOutlet UILabel *songQuestionLabel;
@property (nonatomic, retain) IBOutlet UILabel *moodQuestionLabel;
@property (nonatomic, retain) IBOutlet UILabel *songNameActivity;
@property (nonatomic, retain) IBOutlet UILabel *artistNameActivity;
@property (nonatomic, retain) IBOutlet UILabel *songNameMood;
@property (nonatomic, retain) IBOutlet UILabel *artistNameMood;

- (void) updateActivity:(NSString*) activity;

//--// Feedback question navigation
- (IBAction) incorrectActivity:(id)sender;

- (IBAction) showAssociatedActivitiesQuestion:(id)sender;
- (IBAction) showSongQuestion:(id)sender;
- (IBAction) showMoodQuestion:(id)sender;

- (IBAction) isGoodSong:(id)sender;
- (IBAction) isBadSong:(id)sender;
- (IBAction) isGoodSongMood:(id)sender;
- (IBAction) isBadSongMood:(id)sender;

@end
