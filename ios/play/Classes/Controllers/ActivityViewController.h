//
//  ActivityViewController.h
//  rockmyworld
//
//  Created by Andrew Huynh on 11/16/11.
//  Copyright (c) 2011 athlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface ActivityViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource, 
                                                     CPTPlotDataSource, CPTPlotSpaceDelegate, CPTScatterPlotDelegate> 
{
    
    // Objects used to host fancy chart
    CPTGraphHostingView *chartView;
    CPTXYGraph *scatterPlot;
    NSMutableArray *dataForPlot;
    
}

@property (nonatomic, retain) IBOutlet UIViewController *activityPickerView;
@property (nonatomic, retain) IBOutlet UIView *chartView;

@property (nonatomic, retain) NSMutableArray *dataForPlot;

- (void)renderScatterPlotInLayer:(CPTGraphHostingView *)layerHostingView;

// Button actions
- (IBAction) toggleActivityView:(id)sender;

- (IBAction) selectActivities:(id)sender;
- (IBAction) hideSelectActivities:(id)sender;

@end
