//
//  MoodController.m
//  rockmyworld
//
//  Created by Peter Zhao on 5/3/12.
//  Copyright (c) 2012 athlabs. All rights reserved.
//

#import "MoodController.h"

@implementation MoodController

@synthesize currentMood;

- (id) init
{
    //--//Initialize Mood Hiearchy Tree
    NSData *activityData = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"moods" 
                                                                                           ofType: @"json"]];
    
    NSError *Error = nil;
    
    moodList = [NSJSONSerialization JSONObjectWithData: activityData 
                                                    options: NSJSONReadingMutableContainers 
                                                      error: &Error];
    if(Error != nil)
    {
        NSLog(@"Activity Table not properly converted: %@", [Error localizedDescription]);
    }
    return self;
}

@end
