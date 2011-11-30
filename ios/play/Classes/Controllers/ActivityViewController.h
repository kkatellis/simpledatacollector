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
                                                     CPTPlotDataSource, CPTPlotSpaceDelegate, CPTScatterPlotDelegate>  {
    
    // Objects used to host fancy chart
    CPTGraphHostingView *chartView;
    CPTXYGraph *scatterPlot;
    
}

@property (nonatomic, retain) IBOutlet UIViewController *activityPickerView;
@property (nonatomic, retain) IBOutlet CPTGraphHostingView *chartView;
@property (nonatomic, readonly) CPTXYGraph *scatterPlot;

- (void)renderScatterPlotInLayer:(CPTGraphHostingView *)layerHostingView;

// Button actions
- (IBAction) toggleActivityView:(id)sender;

- (IBAction) selectActivities:(id)sender;
- (IBAction) hideSelectActivities:(id)sender;

@end
