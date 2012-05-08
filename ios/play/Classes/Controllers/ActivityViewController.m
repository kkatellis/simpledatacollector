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

@implementation ActivityViewController

@synthesize currentActivity, currentActivityIcon;
@synthesize currentActivityLabel;

@synthesize activityQuestion, selectActivityQuestion, songQuestion;
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
                
        //--// Initialize Mood hierarchy
        jsonData = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"moods" 
                                                                                   ofType: @"json"]];
        
        moodList = [NSJSONSerialization JSONObjectWithData: jsonData 
                                                   options: NSJSONReadingMutableContainers 
                                                     error: nil];

        recentMoods = [[NSMutableArray alloc] initWithCapacity:5];
        
        currentActivity = nil;
        selectedMood    = @"No Mood Selected";
    }
    return self;
}

- (void) _sendFeedback {
    // NOTE: Only logs output on simulator
#if TARGET_IPHONE_SIMULATOR
    NSLog( @"Incorrect Activity: %d", isIncorrectActivity );
    NSLog( @"Selected Activity: %@", selectedActivity );
    NSLog( @"Selected Mood: %@", selectedMood );
    NSLog( @"Good song?: %d", isGoodSongForActivity );    
#endif
    
    //--// Send feedback to server    
    AppDelegate *appDelegate = [AppDelegate instance];
    [appDelegate sendFeedback: isIncorrectActivity 
                 withActivity: selectedActivity 
                     withSong: currentSong 
                   isGoodSong: isGoodSongForActivity
                     withMood: selectedMood
               isGoodSongMood: isGoodSongForMood];
    
    [[AppDelegate instance] hideActivityView];
    
    // SelectedMood and ISGOODSONGFORMOOD works perfectly
}

- (IBAction) isGoodSong:(id)sender {
    isGoodSongForActivity = TRUE;
    [questionView scrollRectToVisible:CGRectMake( 320*3, 0, 320, 425 ) animated:YES];
    [questionPage setCurrentPage:3];
}

- (IBAction) isBadSong:(id)sender {
    isGoodSongForActivity = FALSE;
    [questionView scrollRectToVisible:CGRectMake( 320*3, 0, 320, 425 ) animated:YES];
    [questionPage setCurrentPage:3];
}

- (IBAction) isGoodSongMood:(id)sender {
    isGoodSongForMood = TRUE;
    [self _sendFeedback];
}

- (IBAction) isBadSongMood:(id)sender {
    isGoodSongForMood = FALSE;
    [self _sendFeedback];
    //SEND OUT WHEN MOOD PAGE IS DONE!
}

- (IBAction) incorrectActivity:(id)sender {
    
    isIncorrectActivity = YES;
    
    //--// Scroll to select activity page and update page control
    [questionView scrollRectToVisible:CGRectMake( 320, 0, 320, 425 ) animated:YES];
    [questionPage setCurrentPage:1];
}

- (IBAction) showSongQuestion:(id)sender {
    
    if( isIncorrectActivity && selectedActivity == nil ) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle: @"Activity List" 
                                                          message: @"Please select your activity" 
                                                         delegate: nil 
                                                cancelButtonTitle: @"OK" 
                                                otherButtonTitles: nil, nil];
        [message show];
        return;
    }
    
    //--// Scroll to song question page
    [questionView scrollRectToVisible:CGRectMake( 320*2, 0, 320, 425 ) animated:YES];
    [questionPage setCurrentPage:2];
}

- (IBAction) showMoodQuestion:(id)sender {
    
    if( selectedMood == @"No Mood Selected") {
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
    //--// Scroll to mood question page
    
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
    songNameActivity.text   = [[appDelegate currentTrack] songTitle];
    artistNameActivity.text = [[appDelegate currentTrack] artist];
    
    songNameMood.text       = [[appDelegate currentTrack] songTitle];
    artistNameMood.text     = [[appDelegate currentTrack] artist];
    
    [activityTable  reloadData];
    [moodTable      reloadData];
    
    // Reset feedback questions    
    selectedActivity        = [currentActivity uppercaseString];
    songQuestionLabel.text  = [NSString stringWithFormat:@"GOOD SONG FOR %@?", selectedActivity];
    moodQuestionLabel.text  = [NSString stringWithFormat:@"GOOD SONG FOR %@?", selectedMood];
    isIncorrectActivity     = NO;
    isGoodSongForActivity   = NO;
    isGoodSongForMood       = NO;
    
    // Reset feedback form to first page
    [questionPage setCurrentPage:0];
    [questionView scrollRectToVisible:CGRectMake( 0, 0, 320, 425) animated:NO];
    
    // Scroll activity/mood table back to the top.
    [activityTable  scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    [moodTable      scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

#define NUMBER_OF_PAGES 5

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

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Activity Hierarchy Table

- (void) updateActivity:(NSString *)activity {
    
    // Update image
    [self setCurrentActivity:[NSString stringWithString:activity]];
    [currentActivityIcon setImage: [UIImage imageNamed: currentActivity]];
    [currentActivityLabel setText: [activity uppercaseString]];
    
    if( [activityHistory count] == 0 ) {
        [activityHistory addObject:activity];
        return;
    }
    
    if( ![[activityHistory objectAtIndex:0] isEqualToString:activity] ) {
        [activityHistory insertObject:activity atIndex:0]; 
    }
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
    
    //--// Activity Table View
    if( tableView == self.activityTable ) {
        
        // Show a recently used section if we actually have "recently" used selections.
        return ( [recentActivities count] > 0 ) ? 2 : 1;
        
    }
    
    //--// Mood Table view
    if (tableView == self.moodTable) {
        
        // Show a recently used section if we actually have "recently" used selections.
        return ( [recentMoods count] > 0 ) ? 2 : 1;
    }
    
    return 0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Activity Table
    if( tableView == self.activityTable) {

        // Do we have any recently used selections?
        if( [recentActivities count] > 0 && section == 0 ) {
            return [recentActivities count];
        }
        
        // Otherwise simply return the # of activities
        return [activityList count];
      
    // Mood Table
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
    
    // Activity Table
    if(tableView == self.activityTable) {
        
        // Do we have any recently used selections?        
        if( [recentActivities count] > 0 && section == 0 ) {
            return @"Recently Used Activities";
        }
        
        return @"Activity Tags";
        
    // Mood Table
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
        songQuestionLabel.text = [NSString stringWithFormat:@"GOOD SONG FOR %@?", selectedActivity];
        [self showSongQuestion:nil];
        
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
        moodQuestionLabel.text = [NSString stringWithFormat:@"FEELING %@ WITH THIS SONG?", selectedMood];
        [self showMoodQuestion:nil];
        
    }
}

@end
