//
//  RMWAlertViewController.h
//  rockmyworld
//
//  Created by Andrew Huynh on 2/21/12.
//  Copyright (c) 2012 athlabs. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    RMWMessageTypePlain,
    RMWMessageTypeError
} RMWMessageType;

@interface RMWAlertViewController : UIViewController {
    UILabel *alertMessage;
    
    UIActivityIndicatorView *activityIndicator;
    UIImageView             *iconView;
}

@property (nonatomic, retain) IBOutlet UILabel *alertMessage;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) IBOutlet UIImageView *iconView;

- (void) showWithMessage:(NSString*)message andMessageType:(RMWMessageType) type;

@end
