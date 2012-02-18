//
//  CalibrateViewController.h
//  Sensor_Accessor
//
//  Created by Andrew Huynh on 2/7/12.
//  Copyright (c) 2012 CALab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalibrateViewController : UIViewController {
    NSArray *tags;
    NSMutableArray *selectedTags;
}

@property (nonatomic, retain) NSMutableArray *selectedTags;

- (IBAction) toggleTag:(id)sender;
- (IBAction) stopCalibration;
@end
