//
//  MusicViewController.m
//  rockmyworld
//
//  Created by Andrew Huynh on 11/14/11.
//  Copyright (c) 2011 athlabs. All rights reserved.
//

#import "AppDelegate.h"

#import "MusicViewController.h"
#import "AlbumCellView.h"

@implementation MusicViewController

@synthesize table;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Set up tabbar stuffs
        self.tabBarItem.title = NSLocalizedString(@"Music", @"Music");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];

        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"black-linen"]];
        self.table.backgroundColor = [UIColor clearColor];
        self.table.opaque = NO;
        
    }
    return self;
    
}
							
- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - MusicViewController specific functions

- (void) centerCurrentlyPlaying {
    // Select the currently playing song.
    [self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];    
}

#pragma mark - Table View Delegate Functions
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 310.0;
}

- (void)scrollViewDidEndDecelerating:(UITableView *)tableView {
    // Center the row that has the highest area visible.
    
    NSArray *visibleCells = [tableView indexPathsForVisibleRows];
    
    // Grab some dimension values we'll need to calculate the areas
    CGRect tableFrame = [tableView frame];
    CGPoint pt = [tableView contentOffset];
    
    NSIndexPath *path = nil;
    float largestArea = 0;
    
    for( NSIndexPath *cellPath in visibleCells ) {
        // Grab the cell frame
        CGRect rect = [[tableView cellForRowAtIndexPath:cellPath] frame];
        
        // Take into account partially visible cells
        float height = 0;
        if( rect.origin.y < pt.y ) {
            // Cells that are hidden from above
            height = ( rect.origin.y + rect.size.height ) - pt.y;
        } else {
            // Cells that are hidden from below
            height = ( pt.y + tableFrame.size.height ) - rect.origin.y;
        }
        
        float cellArea = height * rect.size.width;
        
        if( cellArea > largestArea ) {
            largestArea = cellArea;
            path = cellPath;
        }
    }
    
    [tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void)scrollViewDidEndDragging:(UITableView *)scrollView willDecelerate:(BOOL)decelerate {
    if(decelerate) {
        return;
    }
    [self scrollViewDidEndDecelerating:scrollView];
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
