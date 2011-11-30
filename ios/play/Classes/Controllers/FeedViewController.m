//
//  FeedViewController.m
//  rockmyworld
//
//  Created by Andrew Huynh on 11/28/11.
//  Copyright (c) 2011 athlabs. All rights reserved.
//

#import "AppDelegate.h"
#import "FeedViewController.h"
#import "QuartzCore/CALayer.h"

static NSUInteger kX_Padding = 8;
static NSUInteger kY_Padding = 8;

static NSUInteger kAlbumSize = 80;

@implementation FeedViewController

@synthesize activityFeed, popularFeed, friendFeed;

- (void) rotateTable:(UITableView*)table {
    
    // Rotate table to be horizontal
    CGAffineTransform rotateTable = CGAffineTransformMakeRotation(-M_PI_2);
    CGRect oldRect = [table frame];
    [table setTransform:rotateTable];
    [table setFrame:oldRect];    
    
    // Setup table
    [table setAllowsSelection:YES];
    [table setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"black-linen"]]];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed:@"nav-menu-icon"]
                                                                                 style: UIBarButtonItemStylePlain
                                                                                target: [AppDelegate instance]
                                                                                action: @selector(showNavMenu)];        
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
    
    // Initialize and setup tables to be horizontally scrolling
    [self rotateTable: activityFeed];
    [self rotateTable: friendFeed];
    [self rotateTable: popularFeed];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UISearchBar delegate handlers

- (void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void) searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar endEditing:YES];
}

#pragma mark - UITableView delegate/datasource handlers

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Detect which feed the action is coming from and act accordingly
    [[AppDelegate instance] playMusic:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kAlbumSize + kX_Padding + kY_Padding;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *feedCell = @"ActivityFeedCell";
    
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:feedCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:feedCell];
        
        // Rotate to offset the rotation done to the table
        CGAffineTransform rotateImage = CGAffineTransformMakeRotation(M_PI_2);
        [cell.imageView setTransform:rotateImage];
        
        // No selection highlight
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // Subtle drop shadow on the imageview
        cell.imageView.layer.shadowColor = [UIColor blackColor].CGColor;
        cell.imageView.layer.shadowOffset = CGSizeMake(2, 2);
        cell.imageView.layer.shadowOpacity = .8;
        cell.imageView.layer.shadowRadius = 1.0;
        cell.imageView.clipsToBounds = NO;

    }
    cell.imageView.image = [UIImage imageNamed:@"album-art-small"];
    return cell;
}

@end
