//
//  StackViewController.h
//  rockmyworld
//
//  Created by Andrew Huynh on 11/28/11.
//  Copyright (c) 2011 athlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewExt.h"

@interface StackViewController : UIViewController {
    UIViewExt *topView, *bottomView;
}

@property (nonatomic, retain) IBOutlet UIViewExt *topView;
@property (nonatomic, retain) IBOutlet UIViewExt *bottomView;

@end
