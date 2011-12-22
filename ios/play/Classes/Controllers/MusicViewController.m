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
#import "Track.h"

static CGFloat ALBUM_CELL_HEIGHT = 310.0;

static CGFloat PULLTOADD_HEIGHT = 70.0;

@interface MusicViewController(Private)
- (void) _drawTrackInfo:(NSArray*) visibleCells;
- (void) _loadNewTrack;
- (void) _playerSongEnd: (NSNotification*) notification;
- (void) _updateProgress;
@end

@implementation MusicViewController

@synthesize controls, table, trackInfo, audioPlayer, playpause, pullToAdd;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Set up tabbar stuffs
        self.tabBarItem.title = NSLocalizedString(@"Music", @"Music");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];        

        // Set up initial values
        progressTimer = nil;
        paused      = NO;
        isAdding    = NO;
        isDragging  = NO;

        // NOTE: Play the first song in our playlist on startup
        currentTrackId = 0; 
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
    
    //--// Set up tracks list
    // Hard code tracks
    tracks = [[NSMutableArray alloc] initWithCapacity:1];
    Track *track = [[Track alloc] init];
    [track setArtist:@"The Black Keys"];
    [track setAlbumArt:[UIImage imageNamed:@"el-camino"]];
    [track setSongTitle:@"Lonely Boy"];
    [track setStream:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/test.mp3", [[NSBundle mainBundle] resourcePath]]]];
    [tracks addObject:track];
    
    // Set up background pattern for the view & table
    self.view.backgroundColor  = [UIColor colorWithPatternImage:[UIImage imageNamed:@"black-linen"]];
    self.table.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"black-linen"]];    
    
    //--// Add pull to add view to table
    // Set up rect!
    CGRect tableRect = [self.table frame];
    CGRect oldRect   = [pullToAdd frame];
    pullToAdd.frame = CGRectMake( 0, tableRect.size.height, 320, oldRect.size.height );    
    [self.table addSubview:pullToAdd];
    
    //--// Initialize play/pause buttons
    controlsList = [NSMutableArray arrayWithArray:[controls items]];
    playBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playAction)];
    pauseBtn = self.playpause;

}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Create a new instance of the audio player if it hasn't been initialized yet
    if( self.audioPlayer == nil ) {
        self.audioPlayer = [[AVQueuePlayer alloc] init];
        [self _loadNewTrack];
    }
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
    [self.table scrollToRowAtIndexPath: [NSIndexPath indexPathForRow:currentTrackId inSection:0] 
                      atScrollPosition: UITableViewScrollPositionMiddle 
                              animated: YES];
}

#pragma mark - Player actions

- (void) _updateProgress {
    trackInfo.progress.current += 1;
    [[trackInfo progress] setNeedsDisplay];
}

- (void) _playerSongEnd:(NSNotification *)notification {
    [self nextAction];
}

- (void) _loadNewTrack {
    currentTrack = [tracks objectAtIndex:currentTrackId];

    // Update track info view
    trackInfo.artist.text = [currentTrack artist];
    trackInfo.songTitle.text = [currentTrack songTitle];
    
    // Play next track
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[currentTrack stream]];
    [self.audioPlayer replaceCurrentItemWithPlayerItem:playerItem];
    [self.audioPlayer play];

    // Setup progress bar update
    trackInfo.progress.current = 0;
    trackInfo.progress.max = CMTimeGetSeconds( playerItem.duration );
    
    if( progressTimer ) {
        [progressTimer invalidate];
        progressTimer = nil;
    }
    progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(_updateProgress) userInfo:nil repeats:YES];
    
    // Ensure that we're not in the paused state
    paused = NO;
    [controlsList replaceObjectAtIndex:3 withObject:pauseBtn];
    [controls setItems:controlsList];
    
    [[NSNotificationCenter defaultCenter] addObserver: self 
                                             selector: @selector( _playerSongEnd: ) 
                                                 name: AVPlayerItemDidPlayToEndTimeNotification 
                                               object: [self.audioPlayer currentItem]];
    [self centerCurrentlyPlaying];
    [table reloadData];
}

- (IBAction) prevAction {
    if( currentTrackId > 0 ) {
        currentTrackId -= 1;
        [self _loadNewTrack];
    }
}

- (IBAction) nextAction {
    if( currentTrackId < [tracks count]-1 ) {
        currentTrackId += 1;
        [self _loadNewTrack];
    }
}

- (IBAction) pauseAction {
    [audioPlayer pause];
    paused = YES;
}

- (IBAction) playAction {
    // 1. Start playing song again in AudioPlayer.
    // 2. Swap out the pause button with play button.
    if( paused ) {
        [audioPlayer play];
        [controlsList replaceObjectAtIndex:3 withObject:pauseBtn];
        progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(_updateProgress) userInfo:nil repeats:YES];
    } else {
        [audioPlayer pause];
        [controlsList replaceObjectAtIndex:3 withObject:playBtn];
        [progressTimer invalidate];
        progressTimer = nil;
    }    
    
    [controls setItems:controlsList];    
    paused = !paused;
}

#pragma mark - Table View Delegate Functions

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ALBUM_CELL_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 70;
}

- (UIView*) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return trackInfo;
}

- (void)scrollViewDidEndDecelerating:(UITableView *)tableView {
    /**
     *  Center the row that has the highest area visible.
     * 
     *  1. Goes through each cell row and calculates the area visible on screen.
     *  2. Scrolls ( with animation ) to the cell with the highest visible area.
     *
     */
    if( isAdding ) {
        return;
    }
    NSLog( @"CALLED" );
    
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
        
        // Calculate area and check to see if it's the biggest so far
        float cellArea = height * rect.size.width;
        if( cellArea > largestArea ) {
            largestArea = cellArea;
            path = cellPath;
        }
    }
    
    [tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void)scrollViewDidScroll:(UITableView *)scrollView {
    
    if( isAdding ) {

        // Update the content inset, good for section headers
        if( scrollView.contentOffset.y < PULLTOADD_HEIGHT ) {
            self.table.contentInset = UIEdgeInsetsZero;
        } else if( scrollView.contentOffset.y >= PULLTOADD_HEIGHT ) {
            self.table.contentInset = UIEdgeInsetsMake(0, 0, PULLTOADD_HEIGHT, 0);
        }
        
    } else if( isDragging && scrollView.contentOffset.y > PULLTOADD_HEIGHT ) {
        // Update the arrow direction and label
        [UIView beginAnimations:nil context:NULL];
        if (scrollView.contentOffset.y > PULLTOADD_HEIGHT) {
            // User is scrolling above the header
            //refreshLabel.text = self.textRelease;
            //[refreshArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
        } else { // User is scrolling somewhere within the header
            //refreshLabel.text = self.textPull;
            //[refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
        }
        [UIView commitAnimations];
    }
}

- (void)scrollViewWillBeginDragging:(UITableView *)scrollView {
    if( isAdding ) { 
         return; 
    }
    isDragging = YES;
}

- (void)scrollViewDidEndDragging:(UITableView *)scrollView willDecelerate:(BOOL)decelerate {
    if( isAdding ) { 
        return; 
    }
    
    isDragging = NO;
    if( scrollView.contentOffset.y >= PULLTOADD_HEIGHT ) {
        // Released above the 
        NSLog( @"WOOOO" );
        isAdding = YES;

        // Show the footer
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        self.table.contentInset = UIEdgeInsetsMake( 0, 0, PULLTOADD_HEIGHT, 0 );
        [UIView commitAnimations];
        
        [self performSelector:@selector(stopLoading) withObject:nil afterDelay:2.0];

        return;
    }
    
    if(decelerate) {
        return;
    }
    [self scrollViewDidEndDecelerating:scrollView];
}

- (void)stopLoading {
    isAdding = NO;
    
    // Hide the header
    [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.3];
        self.table.contentInset = UIEdgeInsetsZero;
    [UIView commitAnimations];
}

#pragma mark - Table View Datasource Functions

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tracks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"AlbumCellView";
    
    AlbumCellView *cell = nil;
    cell = (AlbumCellView*)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        UIViewController *tvc = [[UIViewController alloc] initWithNibName:@"AlbumCellView" bundle:nil];
        cell = (AlbumCellView*)tvc.view;
    }
    
    [cell setIsCurrentlyPlaying:NO];
    [cell setAlbumArt:[[tracks objectAtIndex:indexPath.row] albumArt]];
    if ( indexPath.row == currentTrackId ) {
        [cell setIsCurrentlyPlaying:YES];
    }
    
    [cell setNeedsDisplay];
    [cell setNeedsLayout];
    return cell;
}

@end
