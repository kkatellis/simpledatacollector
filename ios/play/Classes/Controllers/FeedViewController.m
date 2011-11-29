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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAdd 
                                                                                              target: [[UIApplication sharedApplication] delegate]
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
    
    [activityFeed   setContentSize:CGSizeMake( 10*kAlbumSize, kAlbumSize )];
    [friendFeed     setContentSize:CGSizeMake( 10*kAlbumSize, kAlbumSize )];    
    [popularFeed    setContentSize:CGSizeMake( 10*kAlbumSize, kAlbumSize )];
    
    [activityFeed   setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"black-linen"]]];
    [friendFeed     setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"black-linen"]]];
    [popularFeed    setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"black-linen"]]];
    
    int xOffset = kX_Padding;
    for( int i = 0; i < 10; i++ ) {
        UIButton *albumView = [UIButton buttonWithType:UIButtonTypeCustom];
        [albumView setImage:[UIImage imageNamed:@"album-art-small"] forState:UIControlStateNormal];
        [albumView addTarget: [[UIApplication sharedApplication] delegate] 
                      action: @selector(playMusic:) 
            forControlEvents: UIControlEventTouchUpInside];
        
        [activityFeed addSubview:albumView];
        [albumView setFrame:CGRectMake( xOffset, kY_Padding, kAlbumSize, kAlbumSize )];
        
        albumView.layer.shadowColor = [UIColor blackColor].CGColor;
        albumView.layer.shadowOffset = CGSizeMake(2, 2);
        albumView.layer.shadowOpacity = .8;
        albumView.layer.shadowRadius = 1.0;
        albumView.clipsToBounds = NO;
        
        xOffset += kAlbumSize + kX_Padding;
    }    

    xOffset = kX_Padding;
    for( int i = 0; i < 10; i++ ) {
        UIButton *albumView = [UIButton buttonWithType:UIButtonTypeCustom];
        [albumView setImage:[UIImage imageNamed:@"album-art-small"] forState:UIControlStateNormal];
        [albumView addTarget: [[UIApplication sharedApplication] delegate] 
                      action: @selector(playMusic:) 
            forControlEvents: UIControlEventTouchUpInside];

        
        [friendFeed addSubview:albumView];
        [albumView setFrame:CGRectMake( xOffset, kY_Padding, kAlbumSize, kAlbumSize )];
        
        albumView.layer.shadowColor = [UIColor blackColor].CGColor;
        albumView.layer.shadowOffset = CGSizeMake(2, 2);
        albumView.layer.shadowOpacity = .8;
        albumView.layer.shadowRadius = 1.0;
        albumView.clipsToBounds = NO;
        
        xOffset += kAlbumSize + kX_Padding;
    }    

    xOffset = kX_Padding;
    for( int i = 0; i < 10; i++ ) {
        UIButton *albumView = [UIButton buttonWithType:UIButtonTypeCustom];
        [albumView setImage:[UIImage imageNamed:@"album-art-small"] forState:UIControlStateNormal];
        [albumView addTarget: [[UIApplication sharedApplication] delegate] 
                      action: @selector(playMusic:) 
            forControlEvents: UIControlEventTouchUpInside];

        
        [popularFeed addSubview:albumView];
        [albumView setFrame:CGRectMake( xOffset, kY_Padding, kAlbumSize, kAlbumSize )];
        
        albumView.layer.shadowColor = [UIColor blackColor].CGColor;
        albumView.layer.shadowOffset = CGSizeMake(2, 2);
        albumView.layer.shadowOpacity = .8;
        albumView.layer.shadowRadius = 1.0;
        albumView.clipsToBounds = NO;
        
        xOffset += kAlbumSize + kX_Padding;
    }    

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

@end
