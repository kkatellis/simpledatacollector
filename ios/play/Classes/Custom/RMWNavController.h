//
//  RMWNavController.h
//  rockmyworld
//
//  Created by Andrew Huynh on 11/14/11.
//  Copyright (c) 2011 athlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivityButton.h"

@interface RMWNavController : UINavigationController {
    ActivityButton *activityButton;
}

@property (retain, nonatomic) ActivityButton *activityButton;

@end

