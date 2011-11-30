//
//  ActivityViewController.m
//  rockmyworld
//
//  Created by Andrew Huynh on 11/16/11.
//  Copyright (c) 2011 athlabs. All rights reserved.
//

#import "ActivityViewController.h"
#import "AppDelegate.h"

@implementation ActivityViewController

@synthesize chartView, activityPickerView, scatterPlot;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [activityPickerView setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (IBAction) toggleActivityView:(id)sender {
    [[AppDelegate instance] hideActivityView];
}

- (IBAction) selectActivities:(id)sender {
    //[self presentModalViewController:activityPickerView animated:YES];
}

- (IBAction) hideSelectActivities:(id)sender {
    //[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self renderScatterPlotInLayer:chartView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIPickerView Delegate functions
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 3;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch ( row ) {
        case 0:
            return @"None ( Turn off activity monitor )";
        case 1:
            return @"Party";
        case 2:
            return @"Studying";
    }
    
    return @"N/A";
}

#pragma mark - Plot delegate functions
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return [[[AppDelegate instance] axVals] count];
}

- (void)renderScatterPlotInLayer:(CPTGraphHostingView *)layerHostingView {
    
    // ALlocate the plot and assign it to our view!
    scatterPlot = [[CPTXYGraph alloc] initWithFrame:self.chartView.bounds];
    chartView.hostedGraph = scatterPlot;
        
    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)scatterPlot.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat( 0.0) length:CPTDecimalFromFloat(20.0)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-1.0) length:CPTDecimalFromFloat(2.0)];
        
    // Hide the axis
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)scatterPlot.axisSet;
    axisSet.xAxis.hidden = TRUE;
    axisSet.yAxis.hidden = TRUE;
        
    // Create a blue plot area
    CPTScatterPlot *boundLinePlot = [[CPTScatterPlot alloc] init];
    boundLinePlot.identifier = @"Blue Plot";
    
    CPTMutableLineStyle *lineStyle = [boundLinePlot.dataLineStyle mutableCopy];
    lineStyle.miterLimit = 1.0f;
    lineStyle.lineWidth = 2.0f;
    lineStyle.lineColor = [CPTColor blueColor];
	boundLinePlot.dataLineStyle = lineStyle;
    boundLinePlot.dataSource = self;
    
    // Create a green plot area
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    dataSourceLinePlot.identifier = @"Green Plot";
    
    lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
    lineStyle.miterLimit = 1.0f;
    lineStyle.lineWidth = 2.0f;    
    lineStyle.lineColor = [CPTColor greenColor];
	dataSourceLinePlot.dataLineStyle = lineStyle;
    dataSourceLinePlot.dataSource = self;
    
    // Create a red plot area
    CPTScatterPlot *dataSourceLinePlot2 = [[CPTScatterPlot alloc] init];
    dataSourceLinePlot2.identifier = @"Red Plot";
    
    lineStyle = [dataSourceLinePlot2.dataLineStyle mutableCopy];
    lineStyle.miterLimit = 1.0f;
    lineStyle.lineWidth = 2.0f;    
    lineStyle.lineColor = [CPTColor redColor];
	dataSourceLinePlot2.dataLineStyle = lineStyle;
    dataSourceLinePlot2.dataSource = self;    
    
    // Add plot and setup background and rounded corners
    [scatterPlot addPlot:boundLinePlot];
    [scatterPlot addPlot:dataSourceLinePlot];
    [scatterPlot addPlot:dataSourceLinePlot2];
    
    [scatterPlot setBackgroundColor: [[UIColor blackColor] CGColor]];
    [chartView.layer setCornerRadius:10];
    [chartView.layer setMasksToBounds:YES];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index  {
    if( fieldEnum == CPTScatterPlotFieldX ) {
        return [[NSNumber alloc] initWithInteger:index];
    }
    
    // Green plot gets shifted above the blue
    if( [(NSString *)plot.identifier isEqualToString:@"Green Plot"] ) {
        return [[[AppDelegate instance] axVals] objectAtIndex:index];
    } else if( [(NSString *)plot.identifier isEqualToString:@"Red Plot"] ) {
        return [[[AppDelegate instance] ayVals] objectAtIndex:index];
    } else {
        return [[[AppDelegate instance] azVals] objectAtIndex:index];
    }
    
//    NSDecimalNumber *num = nil;
//    num = [[dataForPlot objectAtIndex:index] valueForKey:(fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y")];
//        
//    // Green plot gets shifted above the blue
//    if ([(NSString *)plot.identifier isEqualToString:@"Green Plot"]) {
//        if (fieldEnum == CPTScatterPlotFieldY) {
//            num = (NSDecimalNumber *)[NSDecimalNumber numberWithDouble:[num doubleValue] + 1.0];
//        }
//    }
//    return num;
}

@end
