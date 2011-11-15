//
//  MusicViewController.m
//  play
//
//  Created by Andrew Huynh on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MusicViewController.h"
#import "AlbumCellView.h"

@implementation MusicViewController

@synthesize table;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.title = NSLocalizedString(@"Music", @"Music");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
        //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"black-linen"]];
    }
    return self;
}
							
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Select the currently playing song.
    [self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Table View Delegate Functions
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 310.0;
}

#pragma mark - Table View Datasource Functions
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"AlbumCellView";
    
    AlbumCellView *cell = nil;
    cell = (AlbumCellView*)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        UIViewController *tvc = [[UIViewController alloc] initWithNibName:@"AlbumCellView" bundle:nil];
        cell = (AlbumCellView*)tvc.view;
    }
    
    if ( indexPath.row == 5 ) {
        [cell.songInfoBar setHidden :NO];
        [cell setNeedsDisplay];
    }
    
    return cell;
}

@end
