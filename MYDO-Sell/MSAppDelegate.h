//
//  MSAppDelegate.h
//  MYDO-Sell
//
//  Created by liu vincent on 7/1/13.
//  Copyright (c) 2013 PersonalOffice. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MSRootViewController;

@interface MSAppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) MSRootViewController *rootViewController;

@end
