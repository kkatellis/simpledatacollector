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

@synthesize chartView, dataForPlot, activityPickerView;

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
    AppDelegate *sharedDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [sharedDelegate hideActivityView];
}

- (IBAction) selectActivities:(id)sender {
    [self presentModalViewController:activityPickerView animated:YES];
}

- (IBAction) hideSelectActivities:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
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
    return [dataForPlot count];
}

- (void)renderScatterPlotInLayer:(CPTGraphHostingView *)layerHostingView {
    
    // ALlocate the plot and assign it to our view!
    scatterPlot = [[CPTXYGraph alloc] initWithFrame:self.chartView.bounds];
    chartView.hostedGraph = scatterPlot;
        
    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)scatterPlot.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(1.0) length:CPTDecimalFromFloat(2.0)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(1.0) length:CPTDecimalFromFloat(3.0)];
    
    // Axes
//    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)scatterPlot.axisSet;
//    CPTXYAxis *x = axisSet.xAxis;
//    x.majorIntervalLength = CPTDecimalFromString(@"0.5");
//    x.orthogonalCoordinateDecimal = CPTDecimalFromString(@"2");
//    x.minorTicksPerInterval = 2;
//    NSArray *exclusionRanges = [NSArray arrayWithObjects:
//                                [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(1.99) length:CPTDecimalFromFloat(0.02)], 
//                                [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.99) length:CPTDecimalFromFloat(0.02)],
//                                [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(2.99) length:CPTDecimalFromFloat(0.02)],
//                                nil];
//    x.labelExclusionRanges = exclusionRanges;
//    
//    CPTXYAxis *y = axisSet.yAxis;
//    y.majorIntervalLength = CPTDecimalFromString(@"0.5");
//    y.minorTicksPerInterval = 5;
//    y.orthogonalCoordinateDecimal = CPTDecimalFromString(@"2");
//    exclusionRanges = [NSArray arrayWithObjects:
//                       [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(1.99) length:CPTDecimalFromFloat(0.02)],
//                       [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.99) length:CPTDecimalFromFloat(0.02)],
//                       [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(3.99) length:CPTDecimalFromFloat(0.02)],
//                       nil];
//    y.labelExclusionRanges = exclusionRanges;
    
    // Create a blue plot area
    CPTScatterPlot *boundLinePlot = [[CPTScatterPlot alloc] init];
    boundLinePlot.identifier = @"Blue Plot";
    
    CPTMutableLineStyle *lineStyle = [boundLinePlot.dataLineStyle mutableCopy];
    lineStyle.miterLimit = 1.0f;
    lineStyle.lineWidth = 2.0f;
    lineStyle.lineColor = [CPTColor blueColor];
	boundLinePlot.dataLineStyle = lineStyle;
    boundLinePlot.dataSource = self;
    [scatterPlot addPlot:boundLinePlot];
    
    // Create a green plot area
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    dataSourceLinePlot.identifier = @"Green Plot";
    
    lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth = 2.0f;
    lineStyle.lineColor = [CPTColor greenColor];
	dataSourceLinePlot.dataLineStyle = lineStyle;
    dataSourceLinePlot.dataSource = self;

    // Add plot and setup background and rounded corners
    [scatterPlot addPlot:dataSourceLinePlot];
    [scatterPlot setBackgroundColor: [[UIColor blackColor] CGColor]];
    [chartView.layer setCornerRadius:10];
    [chartView.layer setMasksToBounds:YES];
    
    
    // Add some initial data
    NSMutableArray *contentArray = [NSMutableArray arrayWithCapacity:100];
    NSUInteger i;
    for ( i = 0; i < 60; i++ ) {
        id x = [NSNumber numberWithFloat:1+i*0.05];
        id y = [NSNumber numberWithFloat:1.2*rand()/(float)RAND_MAX + 1.2];
        [contentArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:x, @"x", y, @"y", nil]];
    }
    
    self.dataForPlot = contentArray;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index 
{
    NSDecimalNumber *num = nil;
    num = [[dataForPlot objectAtIndex:index] valueForKey:(fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y")];
        
    // Green plot gets shifted above the blue
    if ([(NSString *)plot.identifier isEqualToString:@"Green Plot"]) {
        if (fieldEnum == CPTScatterPlotFieldY) {
            num = (NSDecimalNumber *)[NSDecimalNumber numberWithDouble:[num doubleValue] + 1.0];
        }
    }
    return num;
}

@end
