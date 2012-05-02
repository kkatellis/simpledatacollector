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

#define TOP_ACTIVITY_COUNT 5

@implementation ActivityViewController

@synthesize currentActivity, currentActivityIcon;
@synthesize currentActivityLabel;

@synthesize activityQuestion, selectActivityQuestion, songQuestion;
@synthesize questionPage, questionView, currentAlbumArt, activityTable, songQuestionLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //--// Initialize activity hierarchy
        NSData *activityData = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"activities" 
                                                                                               ofType: @"json"]];
        
        NSError *Error = nil;
        
        selectedLevel = [NSJSONSerialization JSONObjectWithData: activityData 
                                                            options: NSJSONReadingMutableContainers 
                                                              error: &Error];
        if(Error != nil)
        {
            NSLog(@"This is the error description: %@", [Error localizedDescription]);
        }
        
        //NSLog(@"The number used to initialize is %@", [selectedLevel count]);
        //Initial a different array with the same capacity that keeps track of the activity being selected
        //Then we populate the array with 0's
        pickedActivityFrequency = [[NSMutableArray alloc]init];
        
        int counter = 0;
        for (counter = 0; counter < [selectedLevel count]; counter++) {
            [pickedActivityFrequency addObject: [NSNumber numberWithInt:0]];
        }
        
        NSLog(@"The initialized PAF array size is %d", [pickedActivityFrequency count]);
        
        isTableUsed = NO;
        
        topActivities = [[NSMutableArray alloc]init];
        
        
        previousLevel = [[NSMutableArray alloc] initWithCapacity:3];
        
        //--// Initialize activity history array
        activityHistory = [[NSMutableArray alloc] initWithCapacity:10];
        currentActivity = nil;
    }
    return self;
}

- (void) _sendFeedback {
    // NOTE: Only logs output on simulator
#if TARGET_IPHONE_SIMULATOR
    NSLog( @"Incorrect Activity: %d", isIncorrectActivity );
    NSLog( @"Selected Activity: %@", selectedActivity );
    NSLog( @"Good song?: %d", isGoodSongForActivity );    
#endif
    
    //--// Send feedback to server    
    AppDelegate *appDelegate = [AppDelegate instance];
    [appDelegate sendFeedback: isIncorrectActivity 
                 withActivity: selectedActivity 
                     withSong: currentSong 
                   isGoodSong: isGoodSongForActivity];
    [[AppDelegate instance] hideActivityView];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (IBAction) isGoodSong:(id)sender {
    isGoodSongForActivity = TRUE;
    [self _sendFeedback];    
}

- (IBAction) isBadSong:(id)sender {
    isGoodSongForActivity = FALSE;
    [self _sendFeedback];
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
        [currentAlbumArt setImage: [UIImage imageNamed:@"album-art"]];
    } else {
        [currentAlbumArt setImage: artImage];
    }

    // Reset activity hierarchy stack
    currentSong = [[appDelegate currentTrack] dbid];
    [previousLevel removeAllObjects];
    [activityTable reloadData];
    
    // Reset feedback questions    
    selectedActivity = [currentActivity uppercaseString];
    songQuestionLabel.text = [NSString stringWithFormat:@"GOOD SONG FOR %@?", selectedActivity];
    isIncorrectActivity = NO;
    isGoodSongForActivity = NO;
    [questionPage setCurrentPage:0];
    [questionView scrollRectToVisible:CGRectMake( 0, 0, 320, 425) animated:NO];
    
    [activityTable scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [questionView setContentSize:CGSizeMake( 320*3, 425 )];
    
    // Add questions to scrollview
    CGRect rect = CGRectMake( 0, 0, activityQuestion.frame.size.width, activityQuestion.frame.size.height );
    [activityQuestion setFrame:rect];
    [questionView addSubview:activityQuestion];
    
    rect.origin.x += rect.size.width;
    [selectActivityQuestion setFrame:rect];
    [questionView addSubview:selectActivityQuestion];
    
    rect.origin.x += rect.size.width;
    [songQuestion setFrame:rect];
    [questionView addSubview:songQuestion];
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
    
    //Check if any entry has been selected by the user yet:
    [self updateUsage];
    
    //Create brand new section for "recently used" only when entries have been used before
    if(isTableUsed)
    {
        return 2;
    }
    else 
    {
        return 1;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //Check if any entry has been selected by the user yet:
    [self updateUsage];
    
    //This method gets called twice, we need two sections
    if(isTableUsed)
    {
        if (section == 0) {
            [self findTop];
            return [topActivities count];
            NSLog(@"The designated top section size is %d", [topActivities count]);
            
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    [self updateUsage];
    
    //Create brand new section for "recently used" only when entries have been used before
    if(isTableUsed)
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [self updateUsage];
    
    //Check if any entries has been selected by the user yet:
    static NSString *activityCellId = @"hierarchyCell";
    
    NSString *activity;
    UITableViewCellAccessoryType accessoryType = UITableViewCellAccessoryNone;
    
    // Figure out what to display where.
    if(isTableUsed)
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self updateUsage];
    
    if(isTableUsed)
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


// Internal Methods

- (void)findTop{
    
    //Reset the all the top activity category, past user inputs are saved in pickedactivityfrequency anyway
    [topActivities removeAllObjects];
    
    //First define an arbitrarily large value so none can surpass it
    NSNumber *roofValue = [NSNumber numberWithInt:10000];
    
    while ([topActivities count] < TOP_ACTIVITY_COUNT) {
        NSNumber *highestNumber = [NSNumber numberWithInt:0];
        NSNumber *numberIndex   = [NSNumber numberWithInt:0];
        
        //First loop checks for the highest possible value
        for (NSNumber *theNumber in pickedActivityFrequency)
        {
            if ([theNumber intValue] > [highestNumber intValue] && [theNumber intValue] < [roofValue intValue]) {
                highestNumber = [NSNumber numberWithInt:[theNumber intValue]];
                numberIndex = [NSNumber numberWithUnsignedInteger:[pickedActivityFrequency indexOfObject:theNumber]];
            }
        }
        
        //Meaning there are no more true high values, we just jump out.
        if([highestNumber intValue] == 0)
        {
            return;
        }
        [topActivities addObject:numberIndex];
        
        //Second loop checks for duplicates
        int counter = 0;
        for (counter = 0;counter < [pickedActivityFrequency count]; counter++)
        {
            NSNumber *temp = [pickedActivityFrequency objectAtIndex:counter];
            if([highestNumber intValue] == [temp intValue])
            {
                if(counter != [numberIndex intValue])
                {
                    if([topActivities count] < TOP_ACTIVITY_COUNT)
                    {
                        [topActivities addObject:[NSNumber numberWithInt:counter]];
                    }
                }
            }
        }
        
        roofValue = highestNumber;
    }
    
    NSLog(@"So far the top activity size is %d", [topActivities count]);
}

- (void) updateUsage
{
    isTableUsed = NO;
    int counter = 0;
    for (counter = 0; counter < [pickedActivityFrequency count]; counter++) {
        if ([[pickedActivityFrequency objectAtIndex:counter]intValue] > 0) {
            isTableUsed = YES;
            NSLog(@"FEEDBACK DETECTED FROM USERS");
        }
    }
}
@end
