//
//  RMWNavController.m
//  rockmyworld
//
//  Created by Andrew Huynh on 11/14/11.
//  Copyright (c) 2011 athlabs. All rights reserved.
//

#import "RMWNavController.h"
#import "ActivityButton.h"

#import "AppDelegate.h"

@implementation RMWNavController

@synthesize activityButton;

- (id)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    [[self navigationBar] setBarStyle:UIBarStyleBlack];
    
    activityButton = [[ActivityButton alloc] init];
    
    AppDelegate *sharedDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];    
    [activityButton addTarget:sharedDelegate action:@selector(showActivityView) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *buttonImage = [UIImage imageNamed:@"activity_button"];
    
    activityButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    activityButton.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    [activityButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    CGFloat heightDifference = buttonImage.size.height - self.navigationBar.frame.size.height;
    if (heightDifference < 0) {
        activityButton.center = self.navigationBar.center;
    } else {
        CGPoint center = self.navigationBar.center;
        center.y = center.y - heightDifference/2.0 - 6;
        activityButton.center = center;
    }
    
    [self.navigationBar addSubview:activityButton];
    
    // Add sexy shadow ( seen when this is slid aside for the nav menu ).
    self.view.layer.masksToBounds = NO;
    self.view.layer.shadowOffset  = CGSizeMake( -4, 0 );
    self.view.layer.shadowRadius  = 4;
    self.view.layer.shadowOpacity = 0.8;
    
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
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

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

@end
