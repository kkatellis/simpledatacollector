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
@end

@implementation MusicViewController

@synthesize controls, table, trackInfo, tracks, playpause, pullToAdd, paused, currentTrackId, audioPlayer;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Set up tabbar stuffs
        self.tabBarItem.title = NSLocalizedString(@"Music", @"Music");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];        

        // Set up initial values
        progressTimer = nil;
        isAdding    = NO;
        isDragging  = NO;
        isSilent    = NO;

        currentTrackId = -1; 
        currentTrack   = nil;
        tracks = [[NSMutableArray alloc] initWithCapacity:10];
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

    //--// Respond to remote play/pause events.
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
    trackInfo.artist.text       = @"";
    trackInfo.songTitle.text    = @"";
    
    // Set up background pattern for the view & table
    self.view.backgroundColor  = [UIColor colorWithPatternImage:[UIImage imageNamed:@"black-linen"]];
    self.table.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"black-linen"]];    
    [self.table setAllowsSelection:YES];
    
    //--// Add pull to add view to table
    // Set up rect!
    //    CGRect tableRect = [self.table frame];
    //    CGRect oldRect   = [pullToAdd frame];
    //    pullToAdd.frame = CGRectMake( 0, tableRect.size.height, 320, oldRect.size.height );    
    //    [self.table addSubview:pullToAdd];
    
    //--// Initialize play/pause buttons
    controlsList = [NSMutableArray arrayWithArray:[controls items]];
    playBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playAction)];
    pauseBtn = self.playpause;
    
    [self _loadNewTrack];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Create a new instance of the audio player if it hasn't been initialized yet
    if( audioPlayer == nil ) {
        audioPlayer = [[UnifiedPlayer alloc] init];
        [audioPlayer setDelegate:self];
    }    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - MusicViewController specific functions

- (void) centerCurrentlyPlaying {
    // Select the currently playing song.
    if( currentTrack != nil ) {
        [self.table scrollToRowAtIndexPath: [NSIndexPath indexPathForRow:currentTrackId inSection:0] 
                          atScrollPosition: UITableViewScrollPositionMiddle 
                                  animated: YES];
    }
}

#pragma mark - UnifiedPlayer delegate methods

- (void) updateProgress:(double)progress andDuration:(double)duration {
    trackInfo.progress.current = progress;
    trackInfo.progress.max = duration;
    [[trackInfo progress] setNeedsDisplay];
}

- (void) songDidEnd {
    [self nextAction];
}

- (void) _loadNewTrack {
    if( currentTrackId == -1 ) {
        return;
    }
    
    //--// Ensure that we're not in the paused state
    [controlsList replaceObjectAtIndex:3 withObject:pauseBtn];
    [controls setItems:controlsList];    
    
    //--// Select and center on the new track
    NSLog( @"[MusicViewController] LOADING TRACK: %d", currentTrackId );
    currentTrack = [tracks objectAtIndex:currentTrackId];
    [self centerCurrentlyPlaying];
    
    //--// Update track info view
    trackInfo.artist.text = [currentTrack artist];
    trackInfo.songTitle.text = [currentTrack songTitle];
    
    //--// Reset progress bar
    trackInfo.progress.current = 0;
    trackInfo.progress.max = 100;
    
    //--// Play next track
    [audioPlayer play:currentTrack];
    
    [table reloadData];
}

- (void) reloadPlaylist {
    [self.table reloadData];
    
    if( currentTrack == nil ) {
        currentTrackId = 0;
        currentTrack = [tracks objectAtIndex:0];
        [self _loadNewTrack];
    }
}

- (void) setSilent:(BOOL)value {
    
    isSilent = value;
    
    // If user wants silence and we're playing, we pause
    if (value) {
        
        if ( ![audioPlayer isPaused] ) {
    
            [controlsList replaceObjectAtIndex:3 withObject:playBtn];
            [audioPlayer togglePause];    
            [controls setItems:controlsList];
        }
    }
    
    // If user wants sound again and we're paused, we play
    else {
        
        if ( [audioPlayer isPaused] ) {
            
            [controlsList replaceObjectAtIndex:3 withObject:pauseBtn];
            [audioPlayer togglePause];    
            [controls setItems:controlsList];
        }
    }
}

- (IBAction) prevAction {
    
    if (isSilent) {
        
        UIAlertView *noInteraction = [[UIAlertView alloc]initWithTitle:@"Silent Mode is On"
                                                               message:@"Please disable silent mode to activate music controls" 
                                                              delegate:self 
                                                     cancelButtonTitle:@"Ok"
                                                     otherButtonTitles:nil, nil];
        [noInteraction show];
        return;
        
    }
    if( currentTrackId > 0 ) {
        currentTrackId -= 1;
        [self _loadNewTrack];
    }
}

- (IBAction) nextAction {
    
    if (isSilent) {
        
        UIAlertView *noInteraction = [[UIAlertView alloc]initWithTitle:@"Silent Mode is On"
                                                               message:@"Please disable silent mode to activate music controls" 
                                                              delegate:self 
                                                     cancelButtonTitle:@"Ok"
                                                     otherButtonTitles:nil, nil];
        [noInteraction show];
        return;
        
    }
    if( currentTrackId < [tracks count]-1 ) {
        currentTrackId += 1;
        [self _loadNewTrack];
    }
}

- (IBAction) playAction {
    // 1. Start playing song again in AudioPlayer.
    // 2. Swap out the pause button with play button.
    if( currentTrackId == -1 ) return;
    
    // Prevent User interatction during silent mode to prevent confusion
    if (isSilent) {
            
        UIAlertView *noInteraction = [[UIAlertView alloc]initWithTitle:@"Silent Mode is On"
                                                                message:@"Please disable silent mode to activate music controls" 
                                                              delegate:self 
                                                     cancelButtonTitle:@"Ok"
                                                     otherButtonTitles:nil, nil];
        [noInteraction show];
        return;
        
    }
    
    if( [audioPlayer isPaused] ) {
        
        [controlsList replaceObjectAtIndex:3 withObject:pauseBtn];
        
    } else {
        
        [controlsList replaceObjectAtIndex:3 withObject:playBtn];
        
    }    
    
    [audioPlayer togglePause];    
    [controls setItems:controlsList];
}

- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        
        switch (receivedEvent.subtype) {
                
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [self playAction];
                break;
                
            case UIEventSubtypeRemoteControlPreviousTrack:
                [self prevAction];
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                [self nextAction];
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - Table View Delegate Functions

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // If we're already playing this track, pause the player.
    if( currentTrackId == [indexPath row] ) {
        [self playAction];
        return;
    }

    // Otherwise select the next track and start playing!
    // Prevent User interatction during silent mode to prevent confusion
    if (isSilent) {
        
        UIAlertView *noInteraction = [[UIAlertView alloc]initWithTitle:@"Silent Mode is On"
                                                               message:@"Please disable silent mode to activate music controls" 
                                                              delegate:self 
                                                     cancelButtonTitle:@"Ok"
                                                     otherButtonTitles:nil, nil];
        [noInteraction show];
        return;
        
    }
    
    currentTrackId = [indexPath row];
    [self _loadNewTrack];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ALBUM_CELL_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return (currentTrackId >= 0 ) ? 70 : 0;
}

- (UIView*) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return ( currentTrackId >= 0 ) ? trackInfo : nil;
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
    /*
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
    }*/
    
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
    static NSString *AlbumRowIdentifier = @"AlbumCellView";

    //--// Load table view cell
    AlbumCellView *cell = (AlbumCellView*)[tableView dequeueReusableCellWithIdentifier:AlbumRowIdentifier];
    if (cell == nil) {
        UIViewController *tvc = [[UIViewController alloc] initWithNibName:@"AlbumCellView" bundle:nil];
        cell = (AlbumCellView*)tvc.view;
    }

    //--// Load album art
    Track *rowTrack = [tracks objectAtIndex:indexPath.row];
    NSString *albumArt = nil; //[rowTrack albumArt];
    UIImage *rowImage = nil;
    
    if( albumArt ) {
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        NSURL *artURL = [NSURL URLWithString:albumArt];
        
        // Check if image is in the cache
        rowImage = [manager imageWithURL:artURL];
        if( !rowImage ) {
            // Begin download if we don't already have the image
            [manager downloadWithURL:artURL delegate:self];
        }
        
    }
    
    [cell setArtist: rowTrack.artist];
    [cell setTitle: rowTrack.songTitle];
    
    [cell setAlbumArt:rowImage];
    [cell setIsCurrentlyPlaying: (indexPath.row == currentTrackId)];
    
    return cell;    
}

- (void) webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(SDImageInfo *)info {
    // Find the track with the same url
    for( int i = 0; i < [tracks count]; i++ ) {
        Track *track = [tracks objectAtIndex:i];
        
        NSURL *artURL = [NSURL URLWithString:[track albumArt]];
        
        if( [[artURL absoluteString] isEqualToString:[info.imageURL absoluteString]] ) {
            
            AlbumCellView *cell = (AlbumCellView*)[table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            [cell setAlbumArt: info.image];
            
            [cell setNeedsDisplay];
            return;
        }
    }
}

@end
