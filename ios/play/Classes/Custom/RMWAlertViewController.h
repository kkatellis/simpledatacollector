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
    RMWMessageTypeLoading,
    RMWMessageTypeError
} RMWMessageType;

@interface RMWAlertViewController : UIViewController {
    UILabel *alertMessage;
    UIView  *parent;
    
    UIActivityIndicatorView *activityIndicator;
    UIImageView             *iconView;
    
    BOOL    isVisible;
}

@property (nonatomic, retain) IBOutlet UILabel *alertMessage;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) IBOutlet UIImageView *iconView;

@property (nonatomic, retain) UIView *parent;
@property (nonatomic, readonly) BOOL isVisible;

- (void) showWithMessage:(NSString*)message andMessageType:(RMWMessageType) type;
- (void) dismiss;

@end
