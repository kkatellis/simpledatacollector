//
//  NavigationMenu.m
//  rockmyworld
//
//  Created by Andrew Huynh on 11/28/11.
//  Copyright (c) 2011 athlabs. All rights reserved.
//

#import "AppDelegate.h"
#import "NavigationMenu.h"
#import "UIDevice+IdentifierAddition.h"

@implementation NavigationMenu

@synthesize navTable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        profileSection = [[NSMutableArray alloc] initWithObjects:@"Now Playing", @"Test Info", nil];
        profileSectionIcons = [[NSArray alloc] initWithObjects:@"feed-icon", @"settings-icon", nil];
        
        historySection      = [[NSMutableArray alloc] initWithObjects:@"RDIO", nil];
        
        testerSection       = [[NSMutableArray alloc] initWithObjects:[[UIDevice currentDevice] uniqueDeviceIdentifier],nil];
        
        // Setup hierarchy and section headers
        sections        = [[NSMutableArray alloc] initWithObjects: @"", @"MUSIC SETTINGS", @"TESTERS", nil];
        hierarchy       = [[NSMutableArray alloc] initWithObjects: profileSection, historySection, testerSection, nil];
        hierarchyIcons  = [[NSMutableArray alloc] initWithObjects: profileSectionIcons, nil];
        
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [navTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];    
    [navTable setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"black-linen"]]];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated {
    // Check on the status of the music services
    // TODO: Make less hacky...
    [navTable reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableView Delegate/Datasource handlers
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 1. Grab the label text for the navigation item
    // 2. Tell our app delegate to navigate to that view.
    NSString *key = [(NSArray*)[hierarchy objectAtIndex: indexPath.section] objectAtIndex: indexPath.row];
    [[AppDelegate instance] navigateTo: key];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [sections count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    // Only display section headers for sections after the first one
    if( section == 0 ) {
        return 0;
    }
    return 22;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[hierarchy objectAtIndex: section] count];
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if( section == 0 ) {
        return nil;
    }
    
    //--// Grab the section header view and initialize it
    static NSString *headerCellIdentifier = @"NavHeaderView";
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:headerCellIdentifier];
    if( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:headerCellIdentifier];
        cell.backgroundColor     = [UIColor colorWithPatternImage:[UIImage imageNamed:@"header-bg"]];
        cell.textLabel.font      = [UIFont fontWithName:@"Helvetica-Bold" size:11.0];
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    
    cell.textLabel.text = [sections objectAtIndex: section];
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
        {
            NSString *service = [historySection objectAtIndex:[indexPath row]];
            if( [service isEqualToString: @"RDIO" ] ) {

                if( [[AppDelegate rdioInstance] user] == nil ) {
                    [cell.textLabel setText:@"Login to Rdio"];
                } else {
                    [cell.textLabel setText:@"Logout from Rdio"];
                }
                
                [cell.imageView setImage: [UIImage imageNamed:@"rdio-logo"]];
            }
            break;
        }    
        case 2:
        {
            cell.textLabel.text = [testerSection objectAtIndex:[indexPath row]]; 
            cell.imageView.image = nil;
            break;
        }
    }
    
    return cell;
}


@end
