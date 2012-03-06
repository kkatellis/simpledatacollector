//
//  CalibrateViewController.m
//  Sensor_Accessor
//
//  Created by Andrew Huynh on 2/7/12.
//  Copyright (c) 2012 athlabs. All rights reserved.
//

#import "CalibrateViewController.h"

@implementation CalibrateViewController

@synthesize selectedTags;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // List of tags ( in order of button tags )
        tags = [[NSArray alloc] initWithObjects:@"talking", @"housework", @"walking",
                                                @"eating", @"exercising", @"running",
                                                @"sitting", @"driving", @"biking", 
                                                @"bus", @"showering", @"phone using", nil];        
        // Tags that the user has selected
        selectedTags = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Calibrate functions
- (IBAction) stopCalibration {
    // Clear selected tags
    [selectedTags removeAllObjects];
    
    // Set button opacities back to original values
    for (UIView *element in [self.view subviews] ) {
        if( [element isMemberOfClass:[UIButton class]] ) {
            [element setAlpha:0.2];
        }
    }
    
    // Dimiss ourselves from the screen.
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction) toggleTag:(id)sender {
    UIButton *button = (UIButton*)sender;
    
    // Untoggle
    if( [button isSelected] ) {
        // Remove tag from array
        [selectedTags removeObject:[tags objectAtIndex:[button tag]]];
        
        // Set button as unselected and reset opacity
        [button setSelected:NO];
        [button setAlpha:0.2];
    } else {
        // Add tag to array
        [selectedTags addObject: [tags objectAtIndex:[button tag]]];
        
        // Set button as selected and set to full opacity
        [button setSelected:YES];
        [button setAlpha:1.0];
    }
}
@end
