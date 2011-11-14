//
//  ActivityBar.m
//  rockmyworld
//
//  Created by Andrew Huynh on 11/14/11.
//  Copyright (c) 2011 athlabs. All rights reserved.
//

#import "ActivityBar.h"

@implementation ActivityBar

#pragma mark - View lifecycle

- (void)viewDidLoad {
    self.topItem.title = @"TESTING";
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
