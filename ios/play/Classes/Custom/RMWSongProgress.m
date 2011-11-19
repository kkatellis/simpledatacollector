//
//  RMWSongProgress.m
//  rockmyworld
//
//  Created by Andrew Huynh on 11/14/11.
//  Copyright (c) 2011 athlabs. All rights reserved.
//

#import "RMWSongProgress.h"

@implementation RMWSongProgress
- (void)drawRect:(CGRect)rect {	    
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
            
    CGRect progressRect = rect;
    progressRect.size.height = 5;
    progressRect.size.width *= [self progress];
    
    CGContextSetFillColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
    CGContextFillRect(ctx, progressRect);    
}
@end
