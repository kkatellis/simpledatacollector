//
//  NavigationMenu.m
//  rockmyworld
//
//  Created by Andrew Huynh on 11/28/11.
//  Copyright (c) 2011 athlabs. All rights reserved.
//

#import "AppDelegate.h"
#import "NavigationMenu.h"

@implementation NavigationMenu

@synthesize navTable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        profileSection = [[NSMutableArray alloc] initWithObjects:@"Profile", @"Friends", @"Settings", nil];
        profileSectionIcons = [[NSArray alloc] initWithObjects:@"profile-icon", @"settings-icon", @"settings-icon", nil];
        
        historySection    = [[NSMutableArray alloc] initWithObjects:@"Anarchy in the Bakery", 
                                                                    @"Don't Stop Believin'",
                                                                    @"Blah", 
                                                                    @"Blah", 
                                                                    @"More...", nil];

        feedSection    = [[NSMutableArray alloc] initWithObjects:@"Overview",
                                                                 @"Trending", 
                                                                 @"Friendcasts",
                                                                 @"Broadcasts", nil];
        feedSectionIcons = [[NSArray alloc] initWithObjects:@"feed-icon", @"trending-icon", @"feed-icon", @"feed-icon", nil];
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    [navTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];    
    [navTable setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"black-linen"]]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableView Delegate/Datasource handlers
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView: tableView cellForRowAtIndexPath:indexPath];
    [[AppDelegate instance] navigateTo:[[cell textLabel]text]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // 1: Profile/Settings
    // 2: Playlists/Feeds
    // 3: History ( last 5 + show all )
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if( section == 0 ) {
        return 0;
    }
    
    return 22;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch ( section ) {
        case 0:
            return [profileSection count];
        case 1:
            return [feedSection count];
        case 2:
            return [historySection count];
        default:
            break;
    }
    return 0;
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *headerCellIdentifier = @"NavHeaderView";
    
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:headerCellIdentifier];
    if( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:headerCellIdentifier];
        cell.backgroundColor     = [UIColor colorWithPatternImage:[UIImage imageNamed:@"header-bg"]];
        cell.textLabel.font      = [UIFont fontWithName:@"Helvetica-Bold" size:11.0];
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    
    switch( section ) {
        case 0:
            return nil;
        case 1:
            cell.textLabel.text = @"MUSIC FEEDS"; break;            
        case 2:
            cell.textLabel.text = @"LISTENING HISTORY"; break;            
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *navCellIdentifier = @"NavCellView";
    
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:navCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:navCellIdentifier];
        cell.imageView.frame = CGRectMake( 4, 4, 36, 36 );
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"table-bg"]];
        cell.textLabel.font              = [UIFont fontWithName:@"Helvetica" size:16.0];
        cell.textLabel.backgroundColor   = [UIColor clearColor];
        cell.textLabel.textColor         = [UIColor colorWithRed:.8 green:.8 blue:.8 alpha:1.0];
        
        cell.detailTextLabel.font        = [UIFont fontWithName:@"Helvetica-Bold" size:12.0];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.textColor   = [UIColor colorWithRed:22.0/255 green:145.0/255 blue:216.0/255 alpha:1.0];
    }
    
    cell.textLabel.text = nil;
    cell.detailTextLabel.text = nil;
    cell.imageView.image = nil;
    
    switch( [indexPath section] ) {
        case 0:
            cell.textLabel.text = [profileSection objectAtIndex:[indexPath row]]; 
            cell.imageView.image = [UIImage imageNamed:[profileSectionIcons objectAtIndex:[indexPath row]]];
            break;
        case 1:
            cell.textLabel.text = [feedSection objectAtIndex:[indexPath row]]; 
            cell.imageView.image = [UIImage imageNamed:[feedSectionIcons objectAtIndex:[indexPath row]]];
            break;
        case 2:
            cell.textLabel.text = [historySection objectAtIndex:[indexPath row]]; 
            if( [indexPath row] != 4 ) {
                cell.imageView.image = [UIImage imageNamed:@"album-art-small"];
                cell.detailTextLabel.text = @"Justice";
            }
            break;
            
    }
    

    return cell;
}


@end
