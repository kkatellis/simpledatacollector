//
//  RMWSongProgress.h
//  rockmyworld
//
//  Created by Andrew Huynh on 11/14/11.
//  Copyright (c) 2011 athlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RMWSongProgress : UIProgressView {
    float current, max;
}

@property (assign) float current;
@property (assign) float max;

@end
