//
//  ActivityViewController.h
//  rockmyworld
//
//  Created by Andrew Huynh on 11/16/11.
//  Copyright (c) 2011 athlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface ActivityViewController : UIViewController<CPTPlotDataSource,CPTPlotSpaceDelegate,CPTScatterPlotDelegate> {
    CPTGraphHostingView *chartView;
    
    CPTXYGraph *scatterPlot;
    
    NSMutableArray *dataForPlot;
}

@property (nonatomic, retain) IBOutlet UIView *chartView;
@property (nonatomic, retain) NSMutableArray *dataForPlot;

-(IBAction) toggleActivityView:(id)sender;
- (void)renderScatterPlotInLayer:(CPTGraphHostingView *)layerHostingView;

@end
