//
//  ActivityViewController.m
//  rockmyworld
//
//  Created by Andrew Huynh on 11/16/11.
//  Copyright (c) 2011 athlabs. All rights reserved.
//

#import "ActivityViewController.h"
#import "AppDelegate.h"
#import "SDWebImageManager.h"

#define TOP_ACTIVITY_COUNT  5
#define TOP_MOOD_COUNT      5
#define MAX_ACT_ASSOCIATION 5

// Feedback related keys
#define IS_CORRECT_ACTIVITY @"IS_CORRECT_ACTIVITY"
#define CURRENT_ACTIVITY    @"CURRENT_ACTIVITY"
#define CURRENT_SONG        @"CURRENT_SONG"
#define IS_GOOD_ACTIVITY    @"IS_GOOD_SONG_FOR_ACTIVITY"
#define CURRENT_MOOD        @"CURRENT_MOOD"
#define IS_GOOD_MOOD        @"IS_GOOD_SONG_FOR_MOOD"

@implementation ActivityViewController

@synthesize currentActivity, currentActivityIcon;
@synthesize currentActivityLabel;

@synthesize activityQuestion, selectActivityQuestion, multipleActivities, songQuestion, multiActivityTable;
@synthesize selectMoodQuestion, songQuestionMood, moodTable;
@synthesize questionPage, questionView, currentAlbumArtActivity, currentAlbumArtMood;
@synthesize activityTable, songQuestionLabel, moodQuestionLabel;
@synthesize songNameActivity, artistNameActivity, songNameMood, artistNameMood;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        //--// Initialize activity hierarchy
        NSData *jsonData = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"activities" 
                                                                                               ofType: @"json"]];

        activityList  = [NSJSONSerialization JSONObjectWithData: jsonData 
                                                        options: NSJSONReadingMutableContainers 
                                                          error: nil];
        
        // Convert all the activity strings to be uppercase
        for( int i = 0; i < [activityList count]; i++ ) { 
            [activityList replaceObjectAtIndex:i withObject:[[activityList objectAtIndex:i] uppercaseString]];
        }
        
        recentActivities = [[NSMutableArray alloc] initWithCapacity:5];
        
        //--// Initialize associated activities "recently used" mapping.
        jsonData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"associatedActivities" 
                                                                                  ofType:@"json"]];
        assocActivityList = [NSJSONSerialization JSONObjectWithData:jsonData
                                                         options:NSJSONReadingMutableContainers
                                                           error:nil];
        
        associatedActivities = [[NSMutableDictionary alloc] initWithObjects:assocActivityList forKeys:activityList];
        
        //--// Initialize Mood hierarchy
        jsonData = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"moods" 
                                                                                   ofType: @"json"]];
        
        moodList = [NSJSONSerialization JSONObjectWithData: jsonData 
                                                   options: NSJSONReadingMutableContainers 
                                                     error: nil];
        // Convert all the mood strings to be uppercase
        for( int i = 0; i < [moodList count]; i++ ) { 
            [moodList replaceObjectAtIndex:i withObject:[[moodList objectAtIndex:i] uppercaseString]];
        }       

        recentMoods = [[NSMutableArray alloc] initWithCapacity:5];
        
        //--// Feed Back Variables
        feedback = [[NSMutableDictionary alloc] init];
        
        currentActivity = nil;
        selectedActivities = [[NSMutableArray alloc] initWithCapacity:5];
        selectedMood    = @"No Mood Selected";
    }
    return self;
}

#pragma mark - FEEDBACK QUESTIONS

- (void) _sendFeedback {
    //--// Send feedback to server    
    [[AppDelegate instance] sendFeedback: feedback];
    [[AppDelegate instance] hideActivityView];
}

- (IBAction) isGoodSong:(id)sender {
    
    [feedback setObject:[NSNumber numberWithBool:TRUE] forKey: IS_GOOD_ACTIVITY];
    
    [questionView scrollRectToVisible:CGRectMake( 320*4, 0, 320, 425 ) animated:YES];
    [questionPage setCurrentPage:4];
}

- (IBAction) isBadSong:(id)sender {
    
    [feedback setObject:[NSNumber numberWithBool:FALSE] forKey: IS_GOOD_ACTIVITY];
    
    [questionView scrollRectToVisible:CGRectMake( 320*4, 0, 320, 425 ) animated:YES];
    [questionPage setCurrentPage:4];
}

- (IBAction) isGoodSongMood:(id)sender {
    
    [feedback setObject: [NSNumber numberWithBool:TRUE] forKey: IS_GOOD_MOOD];
    
    [self _sendFeedback];
}

- (IBAction) isBadSongMood:(id)sender {
    
    [feedback setObject: [NSNumber numberWithBool:FALSE] forKey: IS_GOOD_MOOD];
    
    [self _sendFeedback];
}

- (IBAction) incorrectActivity:(id)sender {
    
    [[AppDelegate instance] feedbackInitiated];
    
    [feedback setObject: [NSNumber numberWithBool: FALSE] forKey: IS_CORRECT_ACTIVITY];
    isIncorrectActivity = YES;
    
    //--// Scroll to select activity page and update page control
    [questionView scrollRectToVisible:CGRectMake( 320, 0, 320, 425 ) animated:YES];
    [questionPage setCurrentPage:1];
}

- (IBAction) showAssociatedActivitiesQuestion:(id)sender {    
    
    [[AppDelegate instance] feedbackInitiated];
    
    [feedback setObject: [NSNumber numberWithBool: TRUE] forKey: IS_CORRECT_ACTIVITY];
    isIncorrectActivity = NO;    
    
    //--// Scroll to select activity page and update page control
    [self.multiActivityTable reloadData];
    [questionView scrollRectToVisible:CGRectMake( 320*2, 0, 320, 425 ) animated:YES];
    [questionPage setCurrentPage:2];
}

- (IBAction) showSongQuestion:(id)sender {

    // Add activity to list of recent activities for the associated activity
    // Remove from list if already on it
    NSString *mainActivity = [selectedActivities objectAtIndex:0];
    
    // Initialize array with ONLY secondary activities without mainActivity
    NSMutableArray *secondaryActivities = [[NSMutableArray alloc]initWithArray:selectedActivities];
    [secondaryActivities removeObjectAtIndex:0];
    
    NSMutableIndexSet *dupes = [[NSMutableIndexSet alloc] init];
    
    // Find duplicates
    NSMutableArray *recent = [associatedActivities objectForKey:mainActivity];
    for( int i = 0; i < [secondaryActivities count]; i++ ) {
        for( int j = 0; j < [recent count]; j++ ) {
            if( [[recent objectAtIndex:j] isEqualToString:[secondaryActivities objectAtIndex:i]] ) {
                [dupes addIndex:j];
            }
        }
    }
    
    // Remove duplicates from list
    [recent removeObjectsAtIndexes:dupes];
    
    // Add activities to recents list
    while( [recent count] < MAX_ACT_ASSOCIATION && [secondaryActivities count] > 0 ) {
        [recent addObject:[secondaryActivities objectAtIndex:0]];
        [secondaryActivities removeObjectAtIndex:0];
    }
    
    [questionView scrollRectToVisible:CGRectMake( 320*3, 0, 320, 425 ) animated:YES];
    [questionPage setCurrentPage:3];
}

- (IBAction) showMoodQuestion:(id)sender {
    
    if( selectedMood == nil ) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Mood List" 
                                                          message:@"Please select your current Mood" 
                                                         delegate:nil 
                                                cancelButtonTitle:@"OK" 
                                                otherButtonTitles:nil, nil];
        [message show];
        return;
    }
    
    [questionView scrollRectToVisible:CGRectMake( 320*5, 0, 320, 425 ) animated:YES];
    [questionPage setCurrentPage:5];
}

#pragma mark - View lifecycle

- (void) viewWillAppear:(BOOL)animated {
        
    // Update current activity button to show latest activity
    [currentActivityIcon setImage:[UIImage imageNamed: currentActivity]];
    [currentActivityLabel setText: [currentActivity uppercaseString]];
    
    // Grab album art of currently playing track from shared cache
    AppDelegate *appDelegate = [AppDelegate instance];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    UIImage *artImage = [manager imageWithURL: [NSURL URLWithString: [[appDelegate currentTrack] albumArt]]];
    
    if( artImage == nil ) {
        [currentAlbumArtActivity setImage: [UIImage imageNamed:@"Album Art"]];
        [currentAlbumArtMood setImage: [UIImage imageNamed:@"Album Art"]];
        
        songNameActivity.hidden     = NO;
        artistNameActivity.hidden   = NO;
        songNameMood.hidden         = NO;
        artistNameMood.hidden       = NO;
        
        
    } else {
        [currentAlbumArtActivity setImage: artImage];
        [currentAlbumArtMood setImage:artImage];
        
        songNameActivity.hidden     = YES;
        artistNameActivity.hidden   = YES;
        songNameMood.hidden         = YES;
        artistNameMood.hidden       = YES;
        
    }
    
    //--// Reset activity hierarchy stack
    [songNameActivity   setText: @""];
    [artistNameActivity setText: @""];
    [songNameMood       setText: @""];
    [artistNameMood     setText: @""];
    
    // Set the current artist/title labels
    currentSong             = [[appDelegate currentTrack] dbid];
    if( currentSong == nil ) {
        
        [feedback setObject:@"" forKey: CURRENT_SONG];
        
    } else {
        
        [feedback setObject: currentSong forKey: CURRENT_SONG];
        songNameActivity.text   = [[appDelegate currentTrack] songTitle];
        artistNameActivity.text = [[appDelegate currentTrack] artist];
        
        songNameMood.text       = [[appDelegate currentTrack] songTitle];
        artistNameMood.text     = [[appDelegate currentTrack] artist];
        
    }
    
    // Reset feedback questions
    [selectedActivities removeAllObjects];
    [selectedActivities addObject: [currentActivity uppercaseString]];
    
    selectedMood            = nil;
    songQuestionLabel.text  = [NSString stringWithFormat:@"GOOD SONG FOR %@?", [currentActivity uppercaseString]];
    moodQuestionLabel.text  = [NSString stringWithFormat:@"GOOD SONG FOR %@?", selectedMood];
    isIncorrectActivity     = NO;
    
    // Reset feedback form to first page
    [questionPage setCurrentPage:0];
    [questionView scrollRectToVisible:CGRectMake( 0, 0, 320, 425) animated:NO];

    // Reload tables
    [activityTable      reloadData];
    [moodTable          reloadData];
    [multiActivityTable reloadData];

    // Scroll activity/mood table back to the top.
    [activityTable      scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    [moodTable          scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    [multiActivityTable scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

#define NUMBER_OF_PAGES 6

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [questionView setContentSize:CGSizeMake( 320 * NUMBER_OF_PAGES, 425 )];
    
    // Activity Questions
    CGRect rect = CGRectMake( 0, 0, activityQuestion.frame.size.width, activityQuestion.frame.size.height );
    [activityQuestion setFrame:rect];
    [questionView addSubview:activityQuestion];
    
    rect.origin.x += rect.size.width;
    [selectActivityQuestion setFrame:rect];
    [questionView addSubview:selectActivityQuestion];
    
    rect.origin.x += rect.size.width;
    [multipleActivities setFrame:rect];
    [questionView addSubview:multipleActivities];
    
    rect.origin.x += rect.size.width;
    [songQuestion setFrame:rect];
    [questionView addSubview:songQuestion];
    
    //Mood Question
    rect.origin.x += rect.size.width;
    [selectMoodQuestion setFrame:rect];
    [questionView addSubview:selectMoodQuestion];
    
    rect.origin.x += rect.size.width;
    [songQuestionMood setFrame:rect];
    [questionView addSubview:songQuestionMood];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Activity & Mood Table Methods

- (void) updateActivity:(NSString *)activity {
    
    // Update image of activity
    [self setCurrentActivity:[NSString stringWithString:activity]];
    [feedback setObject:selectedActivities forKey:CURRENT_ACTIVITY];
    
    [currentActivityIcon setImage: [UIImage imageNamed: currentActivity]];
    [currentActivityLabel setText: [activity uppercaseString]];

}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
    
    //--// Activity Table View
    if( tableView == self.activityTable ) {
        // Show a recently used section if we actually have "recently" used selections.
        return ( [recentActivities count] > 0 ) ? 2 : 1;
    }        
    
    //--// Multiple Activity Table View
    if( tableView == self.multiActivityTable ) {
        
        // Show the previously picked associated Activities if users choose it before.
        NSString *selectedActivity = [selectedActivities objectAtIndex:0];
        return ( [[associatedActivities objectForKey:selectedActivity] count] > 0 ) ? 2 : 1;
        
    }
    
    if( tableView == self.moodTable ) {
        // Show a recently used section if we actually have "recently" used selections.
        return ( [recentMoods count] > 0 ) ? 2 : 1;
    }
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //--// Activity Table View
    if( tableView == self.activityTable) {

        // Do we have any recently used selections?
        if( [recentActivities count] > 0 && section == 0 ) {
            return [recentActivities count];
        }
        
        // Otherwise simply return the # of activities
        return [activityList count];
    
    } 
    
    //--// Multiple Activity Table View
    if( tableView == self.multiActivityTable) {
        
        NSString *selectedActivity = [selectedActivities objectAtIndex:0];
        if( [[associatedActivities objectForKey:selectedActivity] count] > 0 && section == 0 ){
            return [[associatedActivities objectForKey:selectedActivity] count];
        }
        
        return [activityList count];
    
    //--// Mood Table View    
    } else { 

        // Do we have any recently used selections?
        if( [recentMoods count] > 0 && section == 0 ) {
            return [recentMoods count];
        }
        
        // Otherwise simply return the # of moods
        return [moodList count];

    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    //--// Activity Table
    if( tableView == self.activityTable ) {
        
        // Do we have any recently used selections?        
        if( [recentActivities count] > 0 && section == 0 ) {
            return @"Recently Used Activities";
        }
        
        return @"Activity Tags";
    }
    
    //--// Multiple Activity Table
    if( tableView == self.multiActivityTable ) {
        
        // Do we have any other associated activities?
        NSString *selectedActivity = [selectedActivities objectAtIndex:0];
        if( [[associatedActivities objectForKey:selectedActivity] count] > 0 && section == 0 ){
            return @"Associated Activities";
        }
        
        return @"Activity Tags";
        
    //--// Mood Table
    } else {
        
        // Do we have any recently used selections?
        if( [recentMoods count] > 0 && section == 0 ) {
            return @"Recently Used Moods";
        }
        
        return @"Mood Tags";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *tagCellId = @"TagCell";

    // Create the UITableViewCell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: tagCellId];
    if( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: tagCellId];
        [cell.textLabel setTextColor:[UIColor darkGrayColor]];
    }

    NSString *cellLabel = nil;
    
    //--// Activity Table
    if( tableView == self.activityTable ) {
        
        // Figure out what to show in what section
        if( [recentActivities count] > 0 && indexPath.section == 0 ) {
            
            cellLabel = [recentActivities objectAtIndex: indexPath.row];
            
        } else {
            
            cellLabel = [activityList objectAtIndex: indexPath.row];
            
        }
    }    
        
    //--// Multiple Activity Table
    if( tableView == self.multiActivityTable ) {
        
        // Figure out what to show in what section
        NSString *selectedActivity = [selectedActivities objectAtIndex:0];
        
        if( [[associatedActivities objectForKey:selectedActivity] count] > 0 && indexPath.section == 0 ){
            
            cellLabel = [[associatedActivities objectForKey:selectedActivity] objectAtIndex: indexPath.row];
            
        } else {
            
            cellLabel = [activityList objectAtIndex:indexPath.row];
            
        }
        
        // Set the checkmark if the user has selected this activity already.
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        for( NSString* activity in selectedActivities ) {
            
            if( [activity isEqualToString: cellLabel] ) {
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
                break;
            }
        }
    }
    
    //--// Mood Table
    if( tableView == self.moodTable ) {
            
        // Figure out what to show in what section
        if( [recentMoods count] > 0 && indexPath.section == 0 ) {
            
            cellLabel = [recentMoods objectAtIndex: indexPath.row];
            
        } else {
            
            cellLabel = [moodList objectAtIndex: indexPath.row];
            
        }
    }
    
    [cell.textLabel setText: cellLabel];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if( tableView == self.activityTable) {
        
        //--// Figure out which activity was selected
        NSString *selectedActivity = nil;
        
        // Was it in the "recently used" section?
        if( [recentActivities count] > 0 && indexPath.section == 0 ) {
            
            selectedActivity = [recentActivities objectAtIndex: indexPath.row];
        
        // Otherwise, just grab it from the activity list
        } else {
            
            selectedActivity = [activityList objectAtIndex: indexPath.row];
            
        }
        
        // Set the main activity as the one the user selected.
        [selectedActivities replaceObjectAtIndex:0 withObject: selectedActivity];
        
        //--// Move activity to the top of the recently used list
        // Remove from list if already on it
        for ( int i = 0; i < [recentActivities count]; i++ ) {
            if( [[recentActivities objectAtIndex: i] isEqualToString: selectedActivity] ) {
                [recentActivities removeObjectAtIndex: i];
                break;
            }
        }
        
        // Insert at the top of the list
        [recentActivities insertObject:selectedActivity atIndex:0];
        
        //--// Set up the song question label and show the question.
        [feedback setObject:selectedActivities forKey:CURRENT_ACTIVITY];
        songQuestionLabel.text = [NSString stringWithFormat:@"GOOD SONG FOR %@?", selectedActivity];
        [self showAssociatedActivitiesQuestion:nil];
    }

    //--// Multiple Activity Table
    if( tableView == self.multiActivityTable ) {
        
        UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        // Check if we're removing this from the list of selected activities
        BOOL isRemoving = (selectedCell.accessoryType == UITableViewCellAccessoryCheckmark);
        
        // Also make sure this is a valid activity to choose ( no duplicates, etc ).
        BOOL isValidActivity = TRUE;
         
        // Activity that was tapped on.
        NSString *tappedActivity = nil;

        // Figure out if user is selecting from previously used section
        NSString *mainActivity = [selectedActivities objectAtIndex:0];        
        if( [[associatedActivities objectForKey:mainActivity] count] > 0 && indexPath.section == 0 ) {
            
            tappedActivity = [[associatedActivities objectForKey:mainActivity] objectAtIndex: indexPath.row];
            
        } else {
            
            tappedActivity = [activityList objectAtIndex: indexPath.row];
            
        }
        
        // Can't de-select main activity!!
        if( [mainActivity isEqualToString: tappedActivity] ) {
            
            isValidActivity = FALSE;
            
        }
        
        
        if( isValidActivity ) {
                
            // Place/remove the checkmark
            if( !isRemoving ) {
                
                //Place most recent at top
                [selectedCell setAccessoryType:UITableViewCellAccessoryCheckmark];
                [selectedActivities insertObject:tappedActivity atIndex:1];
                
                
            } else {
                
                [selectedCell setAccessoryType:UITableViewCellAccessoryNone];
                [selectedActivities removeObject: tappedActivity];
                
            }
        }
        [feedback setObject:selectedActivities forKey:CURRENT_ACTIVITY];

    }
    
    if( tableView == self.moodTable ) {
        
        //--// Figure out which mood was selected
        
        // Was it in the "recently used" section?
        if( [recentMoods count] > 0 && indexPath.section == 0 ) {
            
            selectedMood = [recentMoods objectAtIndex: indexPath.row];
        
        // Otherwise, just grab it from the mood list
        } else {
            
            selectedMood = [moodList objectAtIndex: indexPath.row];
            
        }
        
        //--// Move mood to the top of the recently used list
        // Remove from list if already on it
        for( int i = 0; i < [recentMoods count]; i++ ) {
            if( [[recentMoods objectAtIndex: i] isEqualToString: selectedMood] ) {
                [recentMoods removeObjectAtIndex: i];
                break;
            }
        }
        
        // Insert at the top of the list
        [recentMoods insertObject: selectedMood atIndex:0];
        
        // Set up the song question label and show the question.
        [feedback setObject: selectedMood forKey:CURRENT_MOOD];
        moodQuestionLabel.text = [NSString stringWithFormat:@"FEELING %@ WITH THIS SONG?", selectedMood];
        [self showMoodQuestion:nil];
    }
}

@end
