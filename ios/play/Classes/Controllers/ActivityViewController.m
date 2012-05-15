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
        recentActivities = [[NSMutableArray alloc] initWithCapacity:5];
        
        associatedAct = [[NSMutableArray alloc]init];
        while ([associatedAct count] < [activityList count]) {
            
            //Put place holder in associatedAct for each activity
            [associatedAct addObject:[NSNumber numberWithInt:0]];
        }

        associatedActivities = [[NSMutableDictionary alloc]initWithObjects:associatedAct forKeys:activityList];
        NSLog(@"Finished Dictionary Initialization!");
                
        //--// Initialize Mood hierarchy
        jsonData = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"moods" 
                                                                                   ofType: @"json"]];
        
        moodList = [NSJSONSerialization JSONObjectWithData: jsonData 
                                                   options: NSJSONReadingMutableContainers 
                                                     error: nil];

        recentMoods = [[NSMutableArray alloc] initWithCapacity:5];
        
        
        //--// Feed Back Variables
        feedback = [[NSMutableDictionary alloc] init];
        
        correctActivity = nil;
        currentActivity = nil;
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

- (IBAction) showSongQuestion:(id)sender {
    
    [[AppDelegate instance] feedbackInitiated];
    
    if( isIncorrectActivity && selectedActivity == nil ) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle: @"Activity List" 
                                                          message: @"Please select your activity" 
                                                         delegate: nil 
                                                cancelButtonTitle: @"OK" 
                                                otherButtonTitles: nil, nil];
        [message show];
        return;
    }
    
    //--// Scroll to song question page, first checks if there are associated activities with the root one selected
    
    correctActivity = currentActivity;
    
    if([associatedActivities objectForKey:correctActivity] == 0) {
        
        hasAssociatedActivities = NO;
    
    }
    else {
        
        hasAssociatedActivities = YES;
    
    }
    
    [questionView scrollRectToVisible:CGRectMake( 320*2, 0, 320, 425 ) animated:YES];
    [questionPage setCurrentPage:2];
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
    
    [questionView scrollRectToVisible:CGRectMake( 320*4, 0, 320, 425 ) animated:YES];
    [questionPage setCurrentPage:4];
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
    
    // Set the current artist/title labels
    currentSong             = [[appDelegate currentTrack] dbid];
    [feedback setObject: currentSong forKey: CURRENT_SONG];
    
    songNameActivity.text   = [[appDelegate currentTrack] songTitle];
    artistNameActivity.text = [[appDelegate currentTrack] artist];
    
    songNameMood.text       = [[appDelegate currentTrack] songTitle];
    artistNameMood.text     = [[appDelegate currentTrack] artist];
    
    [activityTable      reloadData];
    [moodTable          reloadData];
    [multiActivityTable reloadData];
    
    // Reset feedback questions    
    selectedActivity        = [currentActivity uppercaseString];
    selectedMood            = nil;
    songQuestionLabel.text  = [NSString stringWithFormat:@"GOOD SONG FOR %@?", selectedActivity];
    moodQuestionLabel.text  = [NSString stringWithFormat:@"GOOD SONG FOR %@?", selectedMood];
    isIncorrectActivity     = NO;
    
    // Reset feedback form to first page
    [questionPage setCurrentPage:0];
    [questionView scrollRectToVisible:CGRectMake( 0, 0, 320, 425) animated:NO];
    
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
    [feedback setObject: self.currentActivity forKey: CURRENT_ACTIVITY];
    
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
    if(tableView == self.multiActivityTable) {
            
        // Show the previously picked associated Activities if users choose it before.
        return ( hasAssociatedActivities ) ? 2 : 1;
        
    
    //--// Mood Table View
    } else {
        
        // Show a recently used section if we actually have "recently" used selections.
        return ( [recentMoods count] > 0 ) ? 2 : 1;
    }
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
        
        if(hasAssociatedActivities && section == 0 ){
            return [[associatedActivities objectForKey:correctActivity] count];
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
    if(tableView == self.activityTable) {
        
        // Do we have any recently used selections?        
        if( [recentActivities count] > 0 && section == 0 ) {
            return @"Recently Used Activities";
        }
        
        return @"Activity Tags";
    }
    
    //--// Multiple Activity Table
    if(tableView == self.multiActivityTable) {
        
        // Do we have any other associated activities?
        if( hasAssociatedActivities && section == 0) {
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
    }

    //--// Activity Table
    if( tableView == self.activityTable ) {
        
        // Figure out what to show in what section
        NSString *activity = nil;
        if( [recentActivities count] > 0 && indexPath.section == 0 ) {
            
            activity = [recentActivities objectAtIndex: indexPath.row];
            
        } else {
            
            activity = [activityList objectAtIndex: indexPath.row];
            
        }
        
        // Set the cell color and cell text label
        [cell.textLabel setTextColor:[UIColor darkGrayColor]];
        [cell.textLabel setText: activity];
    }    
        
    //--// Multiple Activity Table
    if(tableView == self.multiActivityTable ) {
        
        NSString *associatedActivity = nil;
        if( hasAssociatedActivities && indexPath.section == 0 ) {
            
            associatedActivity = [[associatedActivities objectForKey:correctActivity] objectAtIndex: indexPath.row];
            
        } else {
            associatedActivity = [activityList objectAtIndex:indexPath.row];
        }
        
        [cell.textLabel setTextColor:[UIColor darkGrayColor]];
        [cell.textLabel setText: associatedActivity];
        
    //--// Mood Table
    } else  {
            
        // Figure out what to show in what section
        NSString *mood = nil;
        if( [recentMoods count] > 0 && indexPath.section == 0 ) {
            
            mood = [recentMoods objectAtIndex: indexPath.row];
            
        } else {
            
            mood = [moodList objectAtIndex: indexPath.row];
            
        }

        [cell.textLabel setTextColor:[UIColor darkGrayColor]];
        [cell.textLabel setText: mood];
        
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if( tableView == self.activityTable) {
        
        //--// Figure out which activity was selected
        
        // Was it in the "recently used" section?
        if( [recentActivities count] > 0 && indexPath.section == 0 ) {
            
            selectedActivity = [recentActivities objectAtIndex: indexPath.row];
        
        // Otherwise, just grab it from the activity list
        } else {
            
            selectedActivity = [activityList objectAtIndex: indexPath.row];
            
        }
        
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
        selectedActivity = [selectedActivity uppercaseString];
        [feedback setObject: selectedActivity forKey:CURRENT_ACTIVITY];
        songQuestionLabel.text = [NSString stringWithFormat:@"GOOD SONG FOR %@?", selectedActivity];
        correctActivity = selectedActivity;
        [self showSongQuestion:nil];
    }    
    
    //--// Multiple Activity Table
    if( tableView == self.multiActivityTable)
    {
         UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        
        if(hasAssociatedActivities) {
            
            //Figure out if user is selecting from previously used section, if yes, we only animate and put it in array for Feedback ONLY, don't need to add it to NSmutabledictionary
            if(indexPath.section == 0) {
                if ([selectedCell accessoryType] == UITableViewCellAccessoryNone) {
                    [selectedCell setAccessoryType:UITableViewCellAccessoryCheckmark];
                    
                } 
                else {
                    [selectedCell setAccessoryType:UITableViewCellAccessoryNone];
                    
                }
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                
                //Lacking feedback code
            
            
            // This is when user has decided to add something from the bottom, more complete act list, we add it to array also
            } else {
                if ([selectedCell accessoryType] == UITableViewCellAccessoryNone) {
                    [selectedCell setAccessoryType:UITableViewCellAccessoryCheckmark];
                    
                    //directly adds object from original activity list
                    [[associatedActivities objectForKey:correctActivity] addObject: [activityList objectAtIndex:indexPath.row]];        
                } 
                else {
                    [selectedCell setAccessoryType:UITableViewCellAccessoryNone];
                    
                    //removes object again when user changes his mind
                    [[associatedActivities objectForKey:correctActivity] removeObject: [activityList objectAtIndex:indexPath.row]];
                    
                }
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }

        // No new activity has ever been associated with previously selected activity before, we create new array and associated with the dictionary key!
        } else {
            
            //Clear the associated array of dummy variables first!
            [[associatedActivities objectForKey:correctActivity] removeAllObjects];
            
            if ([selectedCell accessoryType] == UITableViewCellAccessoryNone) {
                [selectedCell setAccessoryType:UITableViewCellAccessoryCheckmark];
                
                //Adds object when user checks it
                [[associatedActivities objectForKey:correctActivity] addObject: [activityList objectAtIndex:indexPath.row]];       
            } 
            else {
                [selectedCell setAccessoryType:UITableViewCellAccessoryNone];
                
                //removes object again when user changes his mind
                [[associatedActivities objectForKey:correctActivity] removeObject: [activityList objectAtIndex:indexPath.row]];

            }
            [tableView deselectRowAtIndexPath:indexPath animated:YES];

        }
        
    } else {
        
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
        selectedMood = [selectedMood uppercaseString];
        [feedback setObject: selectedMood forKey:CURRENT_MOOD];
        moodQuestionLabel.text = [NSString stringWithFormat:@"FEELING %@ WITH THIS SONG?", selectedMood];
        [self showMoodQuestion:nil];
        
    }
}

@end
