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
        NSData *activityData = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"activities" 
                                                                                               ofType: @"json"]];

        selectedLevel = [NSJSONSerialization JSONObjectWithData: activityData 
                                                        options: NSJSONReadingMutableContainers 
                                                          error: nil];
        
        //Tracking activity entry picked frequency
        pickedActivityFrequency = [[NSMutableArray alloc]init];
        
        int counter = 0;
        for (counter = 0; counter < [selectedLevel count]; counter++) {
            [pickedActivityFrequency addObject: [NSNumber numberWithInt:0]];
        }
        
        isActivityTableUsed = NO;
        topActivities = [[NSMutableArray alloc]init];       
        previousLevel = [[NSMutableArray alloc] initWithCapacity:3];
        
        //--// Initialize Mood hierarchy
        NSData *moodData = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"moods" 
                                                                                           ofType: @"json"]];
        moodList = [NSJSONSerialization JSONObjectWithData: moodData 
                                                   options: NSJSONReadingMutableContainers 
                                                     error: nil];
        
        // Tracking Mood entry picked frequency
        pickedMoodFrequency = [[NSMutableArray alloc]init];
        
        counter = 0;
        for (counter = 0; counter < [moodList count]; counter++) {
            [pickedMoodFrequency addObject: [NSNumber numberWithInt:0]];
        }
        isMoodTableUsed = NO;
        
        topMoods = [[NSMutableArray alloc]init];
        
        //--// Initialize activity history array
        activityHistory = [[NSMutableArray alloc] initWithCapacity:10];
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
    
    //SelectedMood and ISGOODSONGFORMOOD works perfectly
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
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
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Activity List" 
                                                          message:@"Please select your activity" 
                                                         delegate:nil 
                                                cancelButtonTitle:@"OK" 
                                                otherButtonTitles:nil, nil];
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
        
        songNameActivity.hidden = NO;
        artistNameActivity.hidden = NO;
        songNameMood.hidden = NO;
        artistNameMood.hidden = NO;
        
        
    } else {
        [currentAlbumArtActivity setImage: artImage];
        [currentAlbumArtMood setImage:artImage];
        
        songNameActivity.hidden = YES;
        artistNameActivity.hidden = YES;
        songNameMood.hidden = YES;
        artistNameMood.hidden = YES;
        
    }
    
    //--// Reset activity hierarchy stack
    
    // Set the current artist/title labels
    currentSong             = [[appDelegate currentTrack] dbid];
    songNameActivity.text   = [[appDelegate currentTrack] songTitle];
    artistNameActivity.text = [[appDelegate currentTrack] artist];
    
    songNameMood.text       = [[appDelegate currentTrack] songTitle];
    artistNameMood.text     = [[appDelegate currentTrack] artist];
    
    [previousLevel  removeAllObjects];
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
        
        // Check if any entry has been selected by the user yet:
        isActivityTableUsed = [self updateUsage:pickedActivityFrequency];
        
        //Create brand new section for "recently used" only when entries have been used before
        if( isActivityTableUsed ) {
            return 2;
        } else {
            return 1;
        }
    }
    
    if (tableView == self.moodTable) {
        
        // Check if any entry has been selected by the user yet:
        isMoodTableUsed = [self updateUsage:pickedMoodFrequency];
        
        // Create brand new section for "recently used" only when entries have been used before
        if(isMoodTableUsed) {
            return 2;
        } else  {
            return 1;
        }
    }
    
    return 0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //--//Activity Table
    if( tableView == self.activityTable)
    {
        //Check if any entry has been selected by the user yet:
        isActivityTableUsed = [self updateUsage:pickedActivityFrequency];
        
        //This method gets called twice, we need two sections
        if(isActivityTableUsed)
        {
            if (section == 0) {
                [self findTopActivity];
                return [topActivities count];
            }
            else 
            {
                return [selectedLevel count];
            }
        }
        else
        {
            return [selectedLevel count];
        }
    }
    //--// Mood Table
    else  
    {
        isMoodTableUsed = [self updateUsage:pickedMoodFrequency];
        
        if(isMoodTableUsed)
        {
            if (section == 0) 
            {
                [self findTopMood];
                return [topMoods count];
            }
            else 
            {
                return [moodList count];
            }
        }
        else 
        {
            return [moodList count];
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    //--//Activity Table
    if(tableView == self.activityTable)
    {
        isActivityTableUsed = [self updateUsage:pickedMoodFrequency];
        
        //Create brand new section for "recently used" only when entries have been used before
        if(isActivityTableUsed)
        {
            if(section == 0)
            {
                return @"Top 5 Selected Tags";
            }
            else 
            {
                return @"Available Activity Tags";
            }
        }
        else    
        {
            return @"Available Activity Tags";
        }
    }
    else 
    {
        isMoodTableUsed = [self updateUsage:pickedMoodFrequency];
        
        if(isMoodTableUsed)
        {
            if (section == 0) 
            {
                return @"Top 5 Mood Tags";
            }
            else 
            {
                return @"All Available Moods";
            }
        }
        else 
        {
            return @"All Available Moods";
        }
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if( tableView == self.activityTable)
    {
        isActivityTableUsed = [self updateUsage:pickedActivityFrequency];
        
        //Check if any entries has been selected by the user yet:
        static NSString *activityCellId = @"hierarchyCell";
        
        NSString *activity;
        UITableViewCellAccessoryType accessoryType = UITableViewCellAccessoryNone;
        
        // Figure out what to display where.
        if(isActivityTableUsed)
        {
            if(indexPath.section == 0)
            {
                activity = [selectedLevel objectAtIndex: [[topActivities objectAtIndex:indexPath.row] unsignedIntegerValue]];
            }
            else 
            {
                activity = [selectedLevel objectAtIndex: indexPath.row];
            }
        }
        else 
        {
            activity = [selectedLevel objectAtIndex: indexPath.row];
        }
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: activityCellId];
        if( cell == nil ) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: activityCellId];
        }
        
        [cell.textLabel setTextColor:[UIColor darkGrayColor]];
        if( [activity isEqualToString:@"Previous"] ) {
            [cell.textLabel setTextColor:[UIColor redColor]];   
        }
        
        [cell setAccessoryType:accessoryType];    
        [cell.textLabel setText: activity];
        
        return cell;
        
    }
    else 
    {
        isMoodTableUsed = [self updateUsage:pickedMoodFrequency];
        
        //Check if any entries has been selected by the user yet:
        static NSString *moodCellId = @"hierarchyCell";
        
        NSString *mood;
        UITableViewCellAccessoryType accessoryType = UITableViewCellAccessoryNone;
        
        // Figure out what to display where.
        if(isMoodTableUsed)
        {
            if(indexPath.section == 0)
            {
                mood = [moodList objectAtIndex: [[topMoods objectAtIndex:indexPath.row] unsignedIntegerValue]];
            }
            else 
            {
                mood = [moodList objectAtIndex: indexPath.row];
            }
        }
        else 
        {
            mood = [moodList objectAtIndex: indexPath.row];
        }
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: moodCellId];
        if( cell == nil ) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: moodCellId];
        }
        
        [cell.textLabel setTextColor:[UIColor darkGrayColor]];
        if( [mood isEqualToString:@"Previous"] ) {
            [cell.textLabel setTextColor:[UIColor redColor]];   
        }
        
        [cell setAccessoryType:accessoryType];    
        [cell.textLabel setText: mood];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if( tableView == self.activityTable)
    {
        isActivityTableUsed = [self updateUsage:pickedActivityFrequency];
        
        if(isActivityTableUsed)
        {
            if(indexPath.section == 0)
            {
                selectedActivity = [[selectedLevel objectAtIndex:[[topActivities objectAtIndex:indexPath.row] unsignedIntegerValue]] uppercaseString];
            }
            else 
            {
                selectedActivity = [[selectedLevel objectAtIndex: indexPath.row] uppercaseString];
            }
        }
        else 
        {
            // Should only reach this point if there is no more hierarchy.
            selectedActivity = [[selectedLevel objectAtIndex: indexPath.row] uppercaseString];
        }
        
        //Increment the number of time this entry has been used:
        int count = [[pickedActivityFrequency objectAtIndex: indexPath.row]intValue];
        count++;
        
        [pickedActivityFrequency replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithInt:count]];
        
        // Set up the song question label and show the question.
        songQuestionLabel.text = [NSString stringWithFormat:@"GOOD SONG FOR %@?", selectedActivity];
        [self showSongQuestion:nil];
    }
    else {
        isMoodTableUsed = [self updateUsage:pickedMoodFrequency];
        
        if(isMoodTableUsed)
        {
            if (indexPath.section == 0) 
            {
                selectedMood = [[moodList objectAtIndex:[[topMoods objectAtIndex:indexPath.row]unsignedIntegerValue]] uppercaseString];
            }
            else 
            {
                selectedMood = [[moodList objectAtIndex: indexPath.row] uppercaseString];
            }
        }
        else 
        {
            selectedMood = [[moodList objectAtIndex: indexPath.row] uppercaseString];
        }
        
        //Increment the number of time this entry has been used:
        int count = [[pickedMoodFrequency objectAtIndex: indexPath.row]intValue];
        count++;
        
        [pickedMoodFrequency replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithInt:count]];
        
        // Set up the song question label and show the question.
        moodQuestionLabel.text = [NSString stringWithFormat:@"FEELING %@ WITH THIS SONG?", selectedMood];
        [self showMoodQuestion:nil];
    }
}


// Internal Methods

- (void)findTopActivity{
    
    // Reset the all the top activity category, past user inputs are saved in pickedactivityfrequency anyway
    [topActivities removeAllObjects];
    
    // First define an arbitrarily large value so none can surpass it
    NSNumber *roofValue = [NSNumber numberWithInt:10000];
    
    while ([topActivities count] < TOP_ACTIVITY_COUNT) {
        
        NSNumber *highestNumber = [NSNumber numberWithInt:0];
        NSNumber *numberIndex   = [NSNumber numberWithInt:0];
        
        // First loop checks for the highest possible value
        for (NSNumber *theNumber in pickedActivityFrequency) {
            
            if ([theNumber intValue] > [highestNumber intValue] && [theNumber intValue] < [roofValue intValue]) {
                
                highestNumber = [NSNumber numberWithInt:[theNumber intValue]];
                numberIndex = [NSNumber numberWithUnsignedInteger:[pickedActivityFrequency indexOfObject:theNumber]];
                
            }
        }
        
        //Meaning there are no more true high values, we just jump out.
        if([highestNumber intValue] == 0) {
            return;
        }
        
        [topActivities addObject:numberIndex];
        
        //Second loop checks for duplicates
        int counter = 0;
        for (counter = 0;counter < [pickedActivityFrequency count]; counter++) {
            
            NSNumber *temp = [pickedActivityFrequency objectAtIndex:counter];
            if( [highestNumber intValue] == [temp intValue] ) {
                
                if( counter != [numberIndex intValue] ) {
                    
                    if( [topActivities count] < TOP_ACTIVITY_COUNT ) {
                        
                        [topActivities addObject:[NSNumber numberWithInt:counter]];
                        
                    }
                }
            }
        }
        
        roofValue = highestNumber;
    }
}

- (void)findTopMood{
    
    // Reset the all the top activity category, past user inputs are saved in pickedactivityfrequency anyway
    [topMoods removeAllObjects];
    
    // First define an arbitrarily large value so none can surpass it
    NSNumber *roofValue = [NSNumber numberWithInt:10000];
    
    while ([topMoods count] < TOP_MOOD_COUNT) {
        NSNumber *highestNumber = [NSNumber numberWithInt:0];
        NSNumber *numberIndex   = [NSNumber numberWithInt:0];
        
        //First loop checks for the highest possible value
        for (NSNumber *theNumber in pickedMoodFrequency)
        {
            if ([theNumber intValue] > [highestNumber intValue] && [theNumber intValue] < [roofValue intValue]) {
                highestNumber = [NSNumber numberWithInt:[theNumber intValue]];
                numberIndex = [NSNumber numberWithUnsignedInteger:[pickedMoodFrequency indexOfObject:theNumber]];
            }
        }
        
        //Meaning there are no more true high values, we just jump out.
        if([highestNumber intValue] == 0)
        {
            return;
        }
        [topMoods addObject:numberIndex];
        
        //Second loop checks for duplicates
        int counter = 0;
        for (counter = 0;counter < [pickedMoodFrequency count]; counter++)
        {
            NSNumber *temp = [pickedMoodFrequency objectAtIndex:counter];
            if([highestNumber intValue] == [temp intValue])
            {
                if(counter != [numberIndex intValue])
                {
                    if([topMoods count] < TOP_ACTIVITY_COUNT)
                    {
                        [topMoods addObject:[NSNumber numberWithInt:counter]];
                    }
                }
            }
        }
        
        roofValue = highestNumber;
    }
}

- (BOOL) updateUsage: (NSMutableArray*)frequencyTable {

    BOOL usage = NO;
    int counter = 0;
    for (counter = 0; counter < [frequencyTable count]; counter++) {
        if ([[frequencyTable objectAtIndex:counter]intValue] > 0) {
            usage = YES;
        }
    }
    
    return usage;
}
@end
