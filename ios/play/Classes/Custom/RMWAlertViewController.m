//
//  RMWAlertViewController.m
//  rockmyworld
//
//  Created by Andrew Huynh on 2/21/12.
//  Copyright (c) 2012 athlabs. All rights reserved.
//

#import "QuartzCore/CALayer.h"
#import "RMWAlertViewController.h"

@implementation RMWAlertViewController

@synthesize alertMessage, activityIndicator, iconView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) showWithMessage:(NSString *)message andMessageType:(RMWMessageType)type {
    // Set message
    [self.alertMessage setText:message];
    
    // Hide activity indicator & icon
    [activityIndicator setHidden:YES];
    [iconView setHidden:YES];
    
    switch (type) {
        case RMWMessageTypePlain:
            [self.view setBackgroundColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5]];
            break;
        
        case RMWMessageTypeError:
            [self.view setBackgroundColor:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.5]];            
            break;
        default:
            break;
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Round the corners
    CALayer *layer = [self.view layer];
    [layer setMasksToBounds:NO];
    [layer setCornerRadius:10.0];
    
    // Set to be a little transparent
    [self.view setAlpha:0.8];
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

@end
