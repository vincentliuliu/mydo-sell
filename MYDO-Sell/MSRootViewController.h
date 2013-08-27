//
//  MSRootViewController.h
//  MYDO-Sell
//
//  Created by liu vincent on 7/1/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MSLoginViewController;
@class MSMainViewController;

@interface MSRootViewController : UIViewController
{
    MSLoginViewController *loginViewController;
    MSMainViewController *mainViewController;
}

- (void)loadMainViewController;
- (void)lockSystem;
- (void)unlockSystem;

@end
