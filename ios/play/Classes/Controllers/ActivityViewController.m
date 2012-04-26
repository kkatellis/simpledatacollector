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
        selectedLevel = [NSJSONSerialization JSONObjectWithData: activityData 
                                                            options: NSJSONReadingMutableContainers 
                                                              error: nil];
        
        previousLevel = [[NSMutableArray alloc] initWithCapacity:3];
        
        //--// Initialize activity history array
        activityHistory = [[NSMutableArray alloc] initWithCapacity:10];
        currentActivity = nil;
    }
    return self;
}

- (void) _sendFeedback {
    // NOTE: Only logs output on simulator
#ifdef TARGET_IPHONE_SIMULATOR
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
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (IBAction) toggleActivityView:(id)sender {
    [self _sendFeedback];    
    [[AppDelegate instance] hideActivityView];    
}

- (IBAction) isGoodSong:(id)sender {
    isGoodSongForActivity = [sender tag] == 1;
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
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Remember to make room for the "Previous" button when not on the root hierarchy level.
    return [selectedLevel count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *activityCellId = @"hierarchyCell";
    
    NSString *activity;
    UITableViewCellAccessoryType accessoryType = UITableViewCellAccessoryNone;
    
    // Figure out what to display where.
    activity = [selectedLevel objectAtIndex: indexPath.row];
    
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

    // Should only reach this point if there is no more hierarchy.
    selectedActivity = [[selectedLevel objectAtIndex: indexPath.row] uppercaseString];
    
    // Set up the song question label and show the question.
    songQuestionLabel.text = [NSString stringWithFormat:@"GOOD SONG FOR %@?", selectedActivity];
    [self showSongQuestion:nil];
}

@end
