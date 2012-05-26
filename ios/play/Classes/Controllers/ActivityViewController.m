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
#import "JSONKit.h"

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
#define IS_SILENT           @"IS_SILENT"

@implementation ActivityViewController

@synthesize isSilent, isGoogSongForMood, isGoogSongForActivity;

@synthesize activityQuestionView, moodQuestionView;
@synthesize goodSongForActivityControl, goodSongForMoodControl;
@synthesize selectedActivitiesLabel, selectedMoodLabel;

@synthesize selectActivityQuestion, selectMoodQuestion, multipleActivities, multiActivityTable, moodTable, activityTable;
@synthesize currentAlbumArt, songName, artistName, currentActivity;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        //--// Initialize activity hierarchy
        NSData *jsonData = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"activities" 
                                                                                               ofType: @"json"]];

        activityList = [jsonData mutableObjectFromJSONData];
        
        // Convert all the activity strings to be uppercase
        for( int i = 0; i < [activityList count]; i++ ) { 
            [activityList replaceObjectAtIndex:i withObject:[[activityList objectAtIndex:i] uppercaseString]];
        }
        
        recentActivities = [[NSMutableArray alloc] initWithCapacity:5];
        
        //--// Initialize associated activities "recently used" mapping.
        jsonData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"associatedActivities" 
                                                                                  ofType:@"json"]];
        
        NSMutableArray *assocActivityList = [jsonData mutableObjectFromJSONData];
        for ( NSMutableArray *array in assocActivityList ) {
            for( int i = 0; i < [array count]; i++ ) {
                [array replaceObjectAtIndex:i withObject:[[array objectAtIndex:i] uppercaseString]];
            }
        }
        
        associatedActivities = [[NSMutableDictionary alloc] initWithObjects:assocActivityList forKeys:activityList];
        
        //--// Initialize Mood hierarchy
        jsonData = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"moods" 
                                                                                   ofType: @"json"]];
        
        moodList = [jsonData mutableObjectFromJSONData];
        // Convert all the mood strings to be uppercase
        for( int i = 0; i < [moodList count]; i++ ) { 
            [moodList replaceObjectAtIndex:i withObject:[[moodList objectAtIndex:i] uppercaseString]];
        }
        
        //Sort mood array
        [moodList sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

        recentMoods = [[NSMutableArray alloc] initWithCapacity:5];
        
        //--// Feed Back Variables
        feedback = [[NSMutableDictionary alloc] init];
        
        currentActivity     = nil;
        selectedActivities  = [[NSMutableArray alloc] initWithCapacity:5];
        selectedMood        = @"NO MOOD SELECTED";
        
        isSilent                = TRUE;
        isGivingFeedback        = FALSE;
        isGoodSongForMood       = FALSE;
        isGoodSongForActivity   = FALSE;
    }
    return self;
}

#pragma mark - FEEDBACK QUESTIONS

- (void) _sendFeedback {
    
    //--// Send feedback to server    
    [[AppDelegate instance] sendFeedback: feedback];
    [[AppDelegate instance] hideActivityView];
    isGivingFeedback = FALSE;
    
}

- (IBAction) finishFeedback:(id)sender {
    
    if( selectedMood == nil || [selectedMood isEqualToString:@"NO MOOD SELECTED"] ) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Mood List" 
                                                          message:@"Please select your current Mood" 
                                                         delegate:nil 
                                                cancelButtonTitle:@"OK" 
                                                otherButtonTitles:nil, nil];
        [message show];
        return;
    }
    
    BOOL isCorrectActivity = [[selectedActivities objectAtIndex:0] isEqualToString: [self.currentActivity uppercaseString]];
        
    [feedback setObject:[NSNumber numberWithBool: isCorrectActivity]        forKey:IS_CORRECT_ACTIVITY];
    [feedback setObject:[NSNumber numberWithBool: self.isSilent]            forKey:IS_SILENT];
    [feedback setObject:[NSNumber numberWithBool: isGoodSongForActivity]    forKey:IS_GOOD_ACTIVITY];
    [feedback setObject:[NSNumber numberWithBool: isGoodSongForMood]        forKey:IS_GOOD_MOOD];
    
    [self _sendFeedback];
    
}

- (IBAction) showActivitiesSelector:(id)sender {
    
    isGivingFeedback = TRUE;
    [[AppDelegate instance] feedbackInitiated];

    [selectedActivities removeAllObjects];
    [activityTable reloadData];
    
    UIViewController *viewController = [[UIViewController alloc] init];
    [viewController setView:selectActivityQuestion];
    [self presentModalViewController:viewController animated:YES];
    
}

- (void) showAssociatedActivitiesQuestion {
    
    [multiActivityTable reloadData];
    [self dismissModalViewControllerAnimated:NO];
    
    UIViewController *viewController = [[UIViewController alloc] init];
    [viewController setView:multipleActivities];
    [self presentModalViewController:viewController animated:NO];
    
}

- (IBAction) finishedSelectingActivities:(id)sender {

    // Add activity to list of recent activities for the associated activity
    // Remove from list if already on it
    NSString *mainActivity = [selectedActivities objectAtIndex:0];
    
    // Initialize array with ONLY secondary activities without mainActivity
    NSMutableArray *secondaryActivities = [[NSMutableArray alloc]initWithArray:selectedActivities];
    [secondaryActivities removeObjectAtIndex:0];
    
    // Update recently associated tags
    if( [secondaryActivities count] > 0 ) {
        
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
        
    }
    
    [feedback setObject:selectedActivities forKey:CURRENT_ACTIVITY];
    [selectedActivitiesLabel setText: [selectedActivities componentsJoinedByString:@", "]];
    
    [self dismissModalViewControllerAnimated:YES];    
}

- (IBAction) showMoodSelector:(id)sender {
    
    isGivingFeedback = TRUE;    
    [[AppDelegate instance] feedbackInitiated];    
    
    [moodTable reloadData];
    
    UIViewController *viewController = [[UIViewController alloc] init];
    [viewController setView:selectMoodQuestion];
    [self presentModalViewController:viewController animated:YES    ];
    
}

- (void) finishedSelectingMood {
    
    [selectedMoodLabel setText: selectedMood];
    [feedback setObject: selectedMood forKey:CURRENT_MOOD];
    [self dismissModalViewControllerAnimated:YES];
    
}

#pragma mark - View lifecycle

- (void) viewWillAppear:(BOOL)animated {
    
    // This method is also called when we dismiss modal views ( not what we want ).
    if( isGivingFeedback ) {
        return;
    }
    
    // Grab album art of currently playing track from shared cache
    AppDelegate *appDelegate = [AppDelegate instance];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    UIImage *artImage = [manager imageWithURL: [NSURL URLWithString: [[appDelegate currentTrack] albumArt]]];
    
    if( artImage == nil ) {
        [currentAlbumArt setImage: [UIImage imageNamed:@"Album Art"]];        
    } else {
        [currentAlbumArt setImage: artImage];
    }
    
    //--// Reset activity hierarchy stack
    [songName   setText: @""];
    [artistName setText: @""];
    
    // Hide song questions if we're in silent mode.
    for ( UIView *view in [activityQuestionView subviews] ) {
        [view setHidden:isSilent];
    }
    
    for ( UIView *view in [moodQuestionView subviews] ) {
        [view setHidden:isSilent];
    }
    
    [songName        setHidden: isSilent];
    [artistName      setHidden: isSilent];
    [currentAlbumArt setHidden: isSilent];
    
    if( !isSilent ) {

        [activityControl setSelectedIndex: ( isGoodSongForActivity ? 0 : 1 )];
        activityControl.thumb.tintColor = ( isGoodSongForActivity ? [UIColor greenColor] : [UIColor redColor] );
        
        [moodControl setSelectedIndex: ( isGoodSongForMood ? 0 : 1 )];
        moodControl.thumb.tintColor = ( isGoodSongForMood ? [UIColor greenColor] : [UIColor redColor] );
        
        // Set the current artist/title labels
        currentSong = [[appDelegate currentTrack] dbid];
        if( currentSong == nil ) {
            
            [feedback setObject:@"" forKey: CURRENT_SONG];
            
        } else {
            
            [feedback setObject: currentSong forKey: CURRENT_SONG];
            [songName setText:      [[appDelegate currentTrack] songTitle]];
            [artistName setText:    [[appDelegate currentTrack] artist]];
            
        }
        
        [activityControl setNeedsDisplay];    
        [moodControl     setNeedsDisplay];
    }
    
    // Reset feedback questions
    if( [selectedActivities count] == 0 ) { 
        [selectedActivities addObject: [currentActivity uppercaseString]];
    } else {
        [selectedActivitiesLabel setText: [selectedActivities componentsJoinedByString:@", "]];
    }
    [selectedMoodLabel setText: selectedMood];
    
    // Scroll activity/mood table back to the top.
    [activityTable      scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [moodTable          scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [multiActivityTable scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    
}

#define NUMBER_OF_PAGES 6

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create segmented control for Good Song For Activity question
    activityControl = [[SVSegmentedControl alloc] initWithSectionTitles:[NSArray arrayWithObjects: @"YES", @"NO", nil]];
    activityControl.font = [UIFont boldSystemFontOfSize:12.0];
    [activityControl setSelectedIndex: ( isGoodSongForActivity ? 0 : 1 )];
    activityControl.thumb.tintColor = ( isGoodSongForActivity ? [UIColor greenColor] : [UIColor redColor] );
    
    // Using self within a block is dangerous and can lead to retain cycles ( and thus memory leakage ).
    // We use this weakSelf reference to prevent this from happening.
    // http://amattn.com/2011/12/07/arc_best_practices.html for more info.
    ActivityViewController *weakSelf = self;
    activityControl.changeHandler = ^(NSUInteger newIndex) {
        [[AppDelegate instance] feedbackInitiated];
        [weakSelf setIsGoogSongForActivity:( newIndex == 0 )];
        
        if( newIndex == 0 ) {
            activityControl.thumb.tintColor = [UIColor greenColor];        
        } else {
            activityControl.thumb.tintColor = [UIColor redColor];
        }
    };
    
    [self.goodSongForActivityControl addSubview:activityControl];
    activityControl.center = CGPointMake( activityControl.frame.size.width/2, self.goodSongForActivityControl.frame.size.height/2 );
    
    // Create segmented control for Good Song For Mood question
    moodControl = [[SVSegmentedControl alloc] initWithSectionTitles:[NSArray arrayWithObjects: @"YES", @"NO", nil]];
    
    moodControl.font = [UIFont boldSystemFontOfSize:12.0];
    [moodControl setSelectedIndex: ( isGoodSongForMood ? 0 : 1 )];
    moodControl.thumb.tintColor = ( isGoodSongForMood ? [UIColor greenColor] : [UIColor redColor] );    
    
    moodControl.changeHandler = ^(NSUInteger newIndex) {
        [[AppDelegate instance] feedbackInitiated];
        [weakSelf setIsGoogSongForMood: ( newIndex == 0 )];
        
        if( newIndex == 0 ) {
            moodControl.thumb.tintColor = [UIColor greenColor];        
        } else {
            moodControl.thumb.tintColor = [UIColor redColor];
        }        
    };
    
    [self.goodSongForMoodControl addSubview:moodControl];
    moodControl.center = CGPointMake( moodControl.frame.size.width/2, self.goodSongForMoodControl.frame.size.height/2 );
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
    if( tableView == self.multiActivityTable ) {
        
        if( [selectedActivities count] > 0 ) {
            NSString *selectedActivity = [selectedActivities objectAtIndex:0];
            if( [[associatedActivities objectForKey:selectedActivity] count] > 0 && section == 0 ){
                return [[associatedActivities objectForKey:selectedActivity] count];
            }
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
        if( [selectedActivities count] > 0 ) {
            NSString *selectedActivity = [selectedActivities objectAtIndex:0];
            if( [[associatedActivities objectForKey:selectedActivity] count] > 0 && section == 0 ){
                return @"Associated Activities";
            }
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
        [selectedActivities addObject: selectedActivity];
        
        //--// Move activity to the top of the recently used list
        // Remove from list if already on it
        for ( int i = 0; i < [recentActivities count]; i++ ) {
            if( [[recentActivities objectAtIndex: i] isEqualToString: selectedActivity] ) {
                [recentActivities removeObjectAtIndex: i];
                break;
            }
        }
        
        // Insert activity at top of recent list
        [recentActivities insertObject:selectedActivity atIndex:0];
        
        //--// Set up the song question label and show the question.
        [self showAssociatedActivitiesQuestion];
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
        [self finishedSelectingMood];
    }
}

@end
