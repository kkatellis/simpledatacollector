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

@synthesize alertMessage, activityIndicator, iconView, parent, isVisible;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        isVisible = NO;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) dismiss {
    // Fade out and remove from view
    [UIView animateWithDuration:0.5 animations:^{
        self.view.alpha = 0.0;
    } completion:^(BOOL finished){
        [self.view removeFromSuperview];
        isVisible = NO;
    }];
}

- (void) showWithMessage:(NSString *)message andMessageType:(RMWMessageType)type {
    // Set message
    [self.alertMessage setText:message];
    
    // Hide activity indicator & icon
    [activityIndicator setHidden:YES];
    [iconView setHidden:YES];
    
    switch (type) {
        case RMWMessageTypeLoading:
            [self.view setBackgroundColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5]];
            [activityIndicator setHidden:NO];
            break;
        
        case RMWMessageTypeError:
            [self.view setBackgroundColor:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.5]];            
            [iconView setImage:[UIImage imageNamed:@"network"]];
            [iconView setHidden:NO];
            break;
        default:
            break;
    }
    
    // Add to view and fade in
    [self.parent addSubview:self.view];
    [UIView animateWithDuration:0.5 animations:^{
        self.view.alpha += 1.0;
    } completion:^(BOOL finished) {
        
        // Loading dialog requires manual dismissal
        if( type != RMWMessageTypeLoading ) {
            [self performSelector:@selector(dismiss) withObject:nil afterDelay:5];
        }
        
    }];

    isVisible = YES;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Round the corners
    CALayer *layer = [self.view layer];
    [layer setMasksToBounds:NO];
    [layer setCornerRadius:10.0];
    
    // Set to be transparent
    [self.view setAlpha:0.0];
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
