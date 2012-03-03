//
//  ActivityViewController.m
//  rockmyworld
//
//  Created by Andrew Huynh on 11/16/11.
//  Copyright (c) 2011 athlabs. All rights reserved.
//

#import "ActivityViewController.h"
#import "AppDelegate.h"

@implementation ActivityViewController

@synthesize activityPickerView;
@synthesize activityHistory, activityHistoryTable;
@synthesize currentActivityButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [activityPickerView setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
        activityHistory = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (IBAction) toggleActivityView:(id)sender {
    [[AppDelegate instance] hideActivityView];
}

- (IBAction) selectActivities:(id)sender {
    //[self presentModalViewController:activityPickerView animated:YES];
}

- (IBAction) hideSelectActivities:(id)sender {
    //[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Activity History Table

- (void) updateActivity:(NSString *)activity {
    
    // Update image
    [currentActivityButton.imageView setImage:[UIImage imageNamed: [NSString stringWithFormat:@"indicator-%@", activity]]];
    [currentActivityButton.titleLabel setText: [NSString stringWithFormat:@"    %@", activity]];
    [currentActivityButton setNeedsDisplay];
        
    if( [activityHistory count] == 0 ) {
        [activityHistory addObject:activity];
        return;
    }
    
    if( ![[activityHistory objectAtIndex:0] isEqualToString:activity] ) {
        [activityHistory insertObject:activity atIndex:0]; 
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [activityHistory count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *activity = [activityHistory objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"historyCell"];
    if( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"historyCell"];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        [cell.detailTextLabel setTextColor:[UIColor darkGrayColor]];
    }
    
    [cell.imageView setImage: [UIImage imageNamed: [NSString stringWithFormat:@"indicator-%@", activity]]];
    [cell.textLabel setText: activity ];
    //[cell.detailTextLabel setText:@"43 minutes"];
    
    return cell;
}

#pragma mark - UIPickerView Delegate functions
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 3;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch ( row ) {
        case 0:
            return @"None ( Turn off activity monitor )";
        case 1:
            return @"Party";
        case 2:
            return @"Studying";
    }
    
    return @"N/A";
}

@end
